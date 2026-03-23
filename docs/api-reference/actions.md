---
sidebar_position: 14
title: "Novyx API: Actions — Governed Agent Tool Calls"
description: "Policy engine for agent actions. Submit, approve, reject, and audit every tool call that touches the real world."
---

# Actions & Control

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

The Actions router evaluates agent actions against security policies (FinancialSafetyPolicy, DataExfiltrationPolicy) via the Sentinel circuit breaker. Actions are either allowed, blocked, or flagged for review. The Control endpoints manage approval workflows and policy configuration.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** All tiers can submit actions. Approval workflows available on all tiers.

**Connectors:** github, slack, linear, pagerduty, http

**Approval modes:** solo, team, enterprise

---

## Submit Action

```
POST /v1/actions
```

Submit an action for policy evaluation via Sentinel. The action is evaluated against all active policies and returns one of three outcomes: `allowed`, `blocked`, or `pending_review`.

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `action` | string | **Yes** | Action name (e.g., `github.merge_pr`, `slack.post_message`) |
| `params` | object | No | Action parameters passed to the policy evaluator |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `action` | string | Action name |
| `status` | string | `allowed`, `blocked`, or `pending_review` |
| `policy_result` | object \| null | Policy evaluation details (risk score, triggered policy, violations) |
| `message` | string | Human-readable explanation |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

result = nx.action_submit(
    action="github.merge_pr",
    params={"repo": "myorg/myrepo", "pr_number": 42}
)
print(f"Status: {result['status']}")
print(f"Message: {result['message']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const result = await nx.actionSubmit({
  action: "github.merge_pr",
  params: { repo: "myorg/myrepo", pr_number: 42 },
});
console.log(`Status: ${result.status}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/actions \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "github.merge_pr",
    "params": {"repo": "myorg/myrepo", "pr_number": 42}
  }'
```

</TabItem>
</Tabs>

### Response

```json
{
  "action": "github.merge_pr",
  "status": "allowed",
  "policy_result": {
    "risk_score": 0.12,
    "evaluation_time_ms": 3.4
  },
  "message": "Action permitted by policy evaluation"
}
```

**Blocked response example:**

```json
{
  "action": "http.transfer_funds",
  "status": "blocked",
  "policy_result": {
    "triggered_policy": "FinancialSafetyPolicy",
    "reason": "High-value financial operation requires approval",
    "risk_score": 0.85,
    "severity": "high"
  },
  "message": "Action blocked: High-value financial operation requires approval"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 401 | `UNAUTHORIZED` | Invalid or missing API key |
| 403 | `BLOCKED` | Action blocked by policy |

---

## Explain Action

```
GET /v1/actions/{action_id}/explain
```

Get the full causal chain for an action: policy evaluation, approval flow, agent memories at the time, and cryptographic audit trail. One API call to answer "why did my agent do that?"

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `action_id` | string | The action identifier |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `action_id` | string | Action identifier |
| `action` | string | Action name/operation |
| `agent_id` | string | Agent that submitted the action |
| `connector` | string | Connector used (github, slack, etc.) |
| `operation` | string | Specific operation |
| `submitted_at` | string | ISO 8601 timestamp |
| `policy_result` | object \| null | Policy evaluation result |
| `approval` | object \| null | Approval flow details |
| `memories_at_time` | array \| null | Agent memories at the moment of the action |
| `audit_trail` | array | Cryptographic audit entries |
| `summary` | string | Human-readable summary of the entire chain |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
explanation = nx.action_explain("action_abc123")
print(explanation["summary"])
for entry in explanation["audit_trail"]:
    print(f"  {entry['timestamp']}: {entry['event']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const explanation = await nx.actionExplain("action_abc123");
console.log(explanation.summary);
for (const entry of explanation.audit_trail) {
  console.log(`  ${entry.timestamp}: ${entry.event}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/actions/action_abc123/explain \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "action_id": "action_abc123",
  "action": "github.merge_pr",
  "agent_id": "deploy-bot",
  "connector": "github",
  "operation": "merge_pr",
  "submitted_at": "2026-03-15T14:30:00Z",
  "policy_result": {
    "status": "allowed",
    "policies_evaluated": ["FinancialSafetyPolicy", "DataExfiltrationPolicy"],
    "risk_score": 0.12,
    "violations": null
  },
  "approval": null,
  "memories_at_time": [
    {
      "memory_id": "mem_xyz",
      "observation": "PR #42 passed all CI checks",
      "importance": 7,
      "tags": ["ci", "deploy"],
      "created_at": "2026-03-15T14:25:00Z"
    }
  ],
  "audit_trail": [
    {
      "sequence_number": 1,
      "timestamp": "2026-03-15T14:30:00Z",
      "event": "action_executed",
      "entry_hash": "sha256:abc123...",
      "metadata": {"connector": "github", "operation": "merge_pr"}
    }
  ],
  "summary": "Agent 'deploy-bot' submitted a github.merge_pr action at 2026-03-15T14:30:00Z. Action was approved. Agent had 42 memories at the time."
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `actions.not_found` | No audit trail found for the action |

---

## List Approvals

```
GET /v1/approvals
```

List pending action approvals for the current tenant. Used by the Vault dashboard to show the approval queue.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | number | No | `50` | Max results |
| `status` | string | No | — | Filter by status (e.g., `pending_review`) |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `approvals` | array | Array of pending approval objects |
| `total` | number | Total count |

Each approval includes:

| Field | Type | Description |
|-------|------|-------------|
| `approval_id` | string | Approval/action identifier |
| `action` | string | Action name |
| `connector` | string | Connector used |
| `agent_id` | string | Submitting agent |
| `status` | string | Current status |
| `submitted_at` | string | ISO 8601 timestamp |
| `risk_score` | number \| null | Risk score from policy evaluation |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
pending = nx.action_list()
for approval in pending["approvals"]:
    print(f"{approval['action']} by {approval['agent_id']} — {approval['status']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const pending = await nx.actionList();
for (const approval of pending.approvals) {
  console.log(`${approval.action} by ${approval.agent_id} — ${approval.status}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/approvals?limit=10" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

---

## Approve / Reject Action

```
POST /v1/approvals/{approval_id}/decision
```

Approve or deny a pending action. Records the decision in the cryptographic audit trail and emits an event bus notification.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `approval_id` | string | The approval/action identifier |

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `decision` | string | No | `approve` | `approve` or `deny` |
| `reason` | string | No | — | Reason for the decision |
| `approver_id` | string | No | — | ID of the person making the decision (defaults to tenant) |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `approval_id` | string | Approval identifier |
| `decision` | string | `approve` or `deny` |
| `reason` | string \| null | Decision reason |
| `status` | string | `approved` or `denied` |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.approve_action(
    "approval_abc123",
    decision="approve",
    reason="Reviewed and safe to proceed"
)
print(f"Decision: {result['status']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.approveAction("approval_abc123", {
  decision: "approve",
  reason: "Reviewed and safe to proceed",
});
console.log(`Decision: ${result.status}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST "https://novyx-ram-api.fly.dev/v1/approvals/approval_abc123/decision?decision=approve&reason=Reviewed" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "approval_id": "approval_abc123",
  "decision": "approve",
  "reason": "Reviewed and safe to proceed",
  "status": "approved"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `control.invalid_decision` | Decision must be `approve` or `deny` |
| 404 | `NOT_FOUND` | Approval not found |

---

## List Policies

```
GET /v1/control/policies
```

List active Control policies and their configuration. Returns which policies are active, supported connectors, and approval modes.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `policies` | array | Active policy objects |
| `mode` | string | Evaluation mode (`enforcement` or `shadow`) |
| `connectors` | string[] | Supported connectors |
| `approval_modes` | string[] | Available approval modes |

Each policy includes:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Policy name |
| `enabled` | boolean | Whether the policy is active |
| `description` | string | Human-readable description |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
policies = nx.policy_check()
for p in policies["policies"]:
    print(f"{p['name']}: {'enabled' if p['enabled'] else 'disabled'}")
print(f"Connectors: {', '.join(policies['connectors'])}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const policies = await nx.policyCheck();
for (const p of policies.policies) {
  console.log(`${p.name}: ${p.enabled ? "enabled" : "disabled"}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/control/policies \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "policies": [
    {
      "name": "FinancialSafetyPolicy",
      "enabled": true,
      "description": "Blocks high-value financial operations without approval"
    },
    {
      "name": "DataExfiltrationPolicy",
      "enabled": true,
      "description": "Prevents unauthorized data export"
    }
  ],
  "mode": "enforcement",
  "connectors": ["github", "slack", "linear", "pagerduty", "http"],
  "approval_modes": ["solo", "team", "enterprise"]
}
```
