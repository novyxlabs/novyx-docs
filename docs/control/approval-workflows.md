---
sidebar_position: 2
title: "Approval Workflows — Human-in-the-Loop for Novyx Control"
description: "Action statuses, rule outcomes, and the three approval modes (Solo, Team, Enterprise). Endpoints for the approval queue and decision API."
---

# Approval Workflows

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

When a policy rule fires with `on_violation: require_approval`, the action is held in a pending state and routed to a human reviewer. This page documents the approval queue API, the three approval modes, and the polling pattern your agent uses to wait for a decision.

---

## Action statuses vs rule outcomes

These are two distinct concepts. Conflating them is the most common source of confusion when first using Control.

### Action statuses (what `POST /v1/actions` returns)

Every submitted action resolves to one of **three** HTTP-level statuses:

| Status | Meaning |
|--------|---------|
| `allowed` | The action passed all policies and either executed or is safe to execute. May still include `policy_result.warnings` if any `warn` rules fired. |
| `blocked` | At least one rule with `on_violation: block` fired. The action is rejected. |
| `pending_review` | At least one rule with `on_violation: require_approval` fired. The action is held in the approval queue. The response includes a `trace_id` the agent can poll via `GET /v1/actions/{trace_id}/explain` for the outcome. The same identifier is surfaced as `approval_id` in the queue API. |

### Rule outcomes (what `on_violation` controls)

A rule's `on_violation` field is a separate concept — it controls **what happens when that specific rule fires**, not the final action status. There are **three** possible rule outcomes:

| Rule outcome | Effect |
|--------------|--------|
| `block` | Action status becomes `blocked`. |
| `require_approval` | Action status becomes `pending_review`. |
| `warn` | Action status becomes `allowed`, but the warning is appended to `policy_result.warnings`. The action proceeds. |

> **`warn` is not a fourth action status.** A `warn` rule produces an `allowed` action with a warning attached. If you're looking for `warn` in the top-level status field, you'll never find it — check `policy_result.warnings` instead.

When multiple rules fire, the most severe outcome wins: `block` > `require_approval` > `warn`.

If `on_violation` is omitted from a rule, Novyx falls back to a default based on severity (CRITICAL→block, HIGH→require_approval, MEDIUM/LOW→warn). See [Custom Policies](./custom-policies#the-on_violation-field) for the full mapping.

---

## The three approval modes

When an action enters `pending_review`, Novyx routes it through one of three approval modes. The mode is configured per-tenant.

### Solo mode

A single user can approve their own actions, but only after a confirmation phrase and a short delay. Designed for individual developers running governed agents in their own workspace.

- Requires the user to type the confirmation phrase (`ROLLBACK` for destructive operations)
- Enforces a 5-second delay before the approval is accepted
- Available on **all tiers**

### Team mode

Approvals require a different person, OR the same person after a 10-minute cooling-off period. Prevents accidental rubber-stamping while still allowing solo operators in low-risk situations.

- A different reviewer can approve immediately
- The submitting user can self-approve only after `(now - submitted_at) >= 10 minutes`
- Designed for small teams running shared agents
- Available on **Starter+**

### Enterprise mode

Configurable multi-person approval chains. Novyx accumulates approval records and only finalizes the decision when the configured `min_approvals` threshold is met.

- `min_approvals` is configurable (default 2)
- Optional `require_manager` flag and `allowed_roles` list
- Designed for regulated environments with documented approval chains
- Available on **Enterprise**

---

## Polling pattern

When your agent submits an action that requires approval, the API returns immediately with `status: "pending_review"` and a trace identifier you can poll. The agent should poll [`GET /v1/actions/{action_id}/explain`](../api-reference/actions#explain-action) until the status transitions to `approved`, `denied`, or `executed`.

`POST /v1/actions` accepts `{action, params, agent_id?}`. There is no typed Python/TS wrapper for the direct cloud-API form yet — use `requests`/`fetch` (or [the SDK's escape hatch](../sdks/python)) until a higher-level helper ships.

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
import time
import requests

API = "https://novyx-ram-api.fly.dev"
KEY = "nram_your_key"
HEADERS = {"Authorization": f"Bearer {KEY}"}

# Submit an action that triggers a require_approval rule
resp = requests.post(
    f"{API}/v1/actions",
    headers=HEADERS,
    json={
        "action": "slack.send_message",
        "params": {
            "channel": "#external-customers",
            "text": "Hi! Here's the user's email: alice@example.com",
        },
        "agent_id": "support-bot",
    },
)
result = resp.json()

if result["status"] == "pending_review":
    action_id = result["trace_id"]  # set when an action enters pending_review
    print(f"Action {action_id} pending — polling for decision...")

    while True:
        explain = requests.get(
            f"{API}/v1/actions/{action_id}/explain", headers=HEADERS
        ).json()
        approval = explain.get("approval") or {}
        if approval.get("status") in ("approved", "executed"):
            print("Approved — action executed")
            break
        if approval.get("status") == "denied":
            print(f"Denied: {approval.get('reason', 'no reason given')}")
            break
        time.sleep(2)
elif result["status"] == "blocked":
    print(f"Blocked: {result['message']}")
else:
    print("Allowed and executed")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const API = "https://novyx-ram-api.fly.dev";
const KEY = "nram_your_key";
const HEADERS = { Authorization: `Bearer ${KEY}`, "Content-Type": "application/json" };

// Submit an action that triggers a require_approval rule
const submit = await fetch(`${API}/v1/actions`, {
  method: "POST",
  headers: HEADERS,
  body: JSON.stringify({
    action: "slack.send_message",
    params: {
      channel: "#external-customers",
      text: "Hi! Here's the user's email: alice@example.com",
    },
    agent_id: "support-bot",
  }),
});
const result = await submit.json();

if (result.status === "pending_review") {
  const actionId = result.trace_id;  // set when an action enters pending_review
  console.log(`Action ${actionId} pending — polling for decision...`);

  while (true) {
    const explain = await fetch(
      `${API}/v1/actions/${actionId}/explain`,
      { headers: HEADERS },
    ).then((r) => r.json());
    const approval = explain.approval ?? {};
    if (approval.status === "approved" || approval.status === "executed") {
      console.log("Approved — action executed");
      break;
    }
    if (approval.status === "denied") {
      console.log(`Denied: ${approval.reason ?? "no reason given"}`);
      break;
    }
    await new Promise((r) => setTimeout(r, 2000));
  }
} else if (result.status === "blocked") {
  console.log(`Blocked: ${result.message}`);
} else {
  console.log("Allowed and executed");
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# Submit
curl -X POST https://novyx-ram-api.fly.dev/v1/actions \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "slack.send_message",
    "params": {"channel": "#external-customers", "text": "..."},
    "agent_id": "support-bot"
  }'

# Poll (use the trace_id from the submit response)
curl https://novyx-ram-api.fly.dev/v1/actions/act_xyz/explain \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

---

## List the approval queue

```
GET /v1/approvals
```

Returns the current pending queue for the tenant. Each entry is the **latest event per `approval_id`** (the same value as the `action_id` returned at submission), ordered by `sequence_number` from the audit chain — not by wall-clock timestamp. This is intentional: ordering by `sequence_number` survives cross-worker clock drift and guarantees a consistent view of the queue regardless of which Fly machine handled which event.

### Query parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | number | `50` | Max results. |
| `status_filter` | string | — | Filter by status (e.g., `pending_review`). |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
queue = nx.list_approvals(limit=20)
print(f"{queue['total']} pending")
for a in queue["approvals"]:
    print(f"  {a['approval_id']}: {a['action']} by {a['agent_id']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const queue = await nx.listApprovals({ limit: 20 });
console.log(`${queue.total} pending`);
for (const a of queue.approvals) {
  console.log(`  ${a.approval_id}: ${a.action} by ${a.agent_id}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/approvals?limit=20" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "approvals": [
    {
      "approval_id": "act-tenant-1775831481-dcf5264e",
      "action": "send",
      "connector": null,
      "agent_id": "support-bot",
      "status": "pending_review",
      "submitted_at": "2026-04-10T14:30:00Z",
      "risk_score": 0.72
    }
  ],
  "total": 1
}
```

> The queue entry's `approval_id` is the same identifier returned as `action_id` from `POST /v1/actions`. Pass it directly to the decision endpoint below.

---

## Approve or deny an action

```
POST /v1/approvals/{approval_id}/decision
```

Submits a decision for a pending action. The decision is recorded in the cryptographic audit chain and emits an `ACTION_PENDING_REVIEW`-resolution event so the polling agent can pick up the result.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `approval_id` | string | The approval identifier — same value as the `action_id` returned at submission. Both names refer to the same identifier; the path uses `approval_id` for consistency with the queue API. |

### Request body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `decision` | string | **Yes** | `approve` or `deny`. |
| `reason` | string | No | Optional explanation logged with the decision. |
| `approver_id` | string | No | ID of the human reviewer. Defaults to the tenant's API key owner. |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.approve_action(
    "act-tenant-1775831481-dcf5264e",
    decision="approve",
    reason="Reviewed — internal recipient confirmed",
)
print(result["status"])  # "approved"
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.approveAction("act-tenant-1775831481-dcf5264e", {
  decision: "approve",
  reason: "Reviewed — internal recipient confirmed",
});
console.log(result.status);  // "approved"
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/approvals/act-tenant-1775831481-dcf5264e/decision \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "decision": "approve",
    "reason": "Reviewed — internal recipient confirmed"
  }'
```

</TabItem>
</Tabs>

### Response

```json
{
  "approval_id": "act-tenant-1775831481-dcf5264e",
  "decision": "approve",
  "reason": "Reviewed — internal recipient confirmed",
  "status": "approved"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `novyx_ram.v1.control.invalid_decision` | `decision` must be `approve` or `deny`. |
| 404 | `novyx_ram.v1.control.approval_not_found` | No approval with that ID, or the action was never in `pending_review` state. |
| 409 | `novyx_ram.v1.control.approval_already_decided` | The approval has already been decided. Decisions are immutable. |

---

## See also

- [Custom Policies](./custom-policies) — author the rules that produce `pending_review`
- [Governance Dashboard](./dashboard) — see approval throughput and pending counts
- [Agent-Scoped Policies](./agent-scoped-policies) — different approval thresholds per agent
