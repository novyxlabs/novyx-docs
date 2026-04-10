---
sidebar_position: 3
title: "Governance Dashboard — Aggregated Stats for Novyx Control"
description: "Aggregate governance stats over the audit chain. Totals, violations by policy, violations by agent, time-series. Per-agent violation history endpoint."
---

# Governance Dashboard

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

The governance dashboard endpoints turn the raw audit chain into something a security team can actually look at. You get totals, violations broken down by policy and agent, a time-series of activity, and per-agent violation history — all served from a single SQL query against the audit log.

**Tier:** All endpoints on this page require the `governance_dashboard` feature. Available on **Starter+**. Free-tier tenants receive a 403.

---

## `GET /v1/control/dashboard`

Aggregated governance stats for a configurable time window.

### Query parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `window` | string | `7d` | Time window. One of `24h`, `7d`, `30d`. |
| `bucket` | string | auto | Time-series bucket size. `hour` or `day`. Defaults to `hour` for `24h` window, `day` for `7d` and `30d`. |

### Response shape

| Field | Type | Description |
|-------|------|-------------|
| `window` | string | Echoes the requested window. |
| `bucket` | string | Echoes the bucket (resolved if auto). |
| `backend` | string | `postgres` or `file`. See [Postgres vs file mode](#postgres-vs-file-mode) below. |
| `totals` | object | Aggregate counts. See below. |
| `violations_by_policy` | object[] | One entry per policy that fired in the window, with severity breakdown. |
| `violations_by_agent` | object[] | One entry per agent that hit a violation. |
| `time_series` | object[] | One entry per bucket. |

#### `totals` fields

| Field | Type | Description |
|-------|------|-------------|
| `evaluations` | number | Total actions evaluated against policies. |
| `executed` | number | Actions that ran (allowed or post-approval). |
| `pending_review` | number | Actions currently held in the approval queue. |
| `approved` | number | Actions approved by a human reviewer. |
| `denied` | number | Actions denied by a human reviewer. |

#### `violations_by_policy[]` fields

| Field | Type | Description |
|-------|------|-------------|
| `policy` | string | Policy name. |
| `count` | number | Total times the policy fired in the window. |
| `severity_breakdown` | object | Map of severity → count (e.g., `{"critical": 3, "high": 12}`). |

#### `violations_by_agent[]` fields

| Field | Type | Description |
|-------|------|-------------|
| `agent_id` | string | The agent that hit the violation. |
| `count` | number | Total violations for this agent in the window. |

#### `time_series[]` fields

| Field | Type | Description |
|-------|------|-------------|
| `bucket` | string | ISO 8601 timestamp at the start of the bucket. |
| `executed` | number | Actions executed in this bucket. |
| `pending_review` | number | Actions that entered pending in this bucket. |
| `approved` | number | Approvals recorded in this bucket. |
| `denied` | number | Denials recorded in this bucket. |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

dash = nx.governance_dashboard(window="7d")

print(dash["totals"])
# {'evaluations': 1248, 'executed': 1109, 'pending_review': 87, 'approved': 134, 'denied': 18}

for p in dash["violations_by_policy"]:
    print(f"{p['policy']}: {p['count']} ({p['severity_breakdown']})")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const dash = await nx.governanceDashboard({ window: "7d" });

console.log(dash.totals);
// { evaluations: 1248, executed: 1109, pending_review: 87, approved: 134, denied: 18 }

for (const p of dash.violations_by_policy) {
  console.log(`${p.policy}: ${p.count} (${JSON.stringify(p.severity_breakdown)})`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/control/dashboard?window=7d" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Sample response

```json
{
  "window": "7d",
  "bucket": "day",
  "backend": "postgres",
  "totals": {
    "evaluations": 1248,
    "executed": 1109,
    "pending_review": 87,
    "approved": 134,
    "denied": 18
  },
  "violations_by_policy": [
    {
      "policy": "pii_protection",
      "count": 47,
      "severity_breakdown": {"critical": 3, "high": 38, "medium": 6}
    },
    {
      "policy": "FinancialSafetyPolicy",
      "count": 12,
      "severity_breakdown": {"high": 12}
    }
  ],
  "violations_by_agent": [
    {"agent_id": "support-bot", "count": 41},
    {"agent_id": "billing-bot", "count": 18}
  ],
  "time_series": [
    {
      "bucket": "2026-04-04T00:00:00Z",
      "executed": 142,
      "pending_review": 11,
      "approved": 18,
      "denied": 2
    },
    {
      "bucket": "2026-04-05T00:00:00Z",
      "executed": 168,
      "pending_review": 14,
      "approved": 22,
      "denied": 3
    }
  ]
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `novyx_ram.v1.tier.feature_required` | Tenant tier does not include `governance_dashboard` (Free tier). |

---

### Postgres vs file mode

The dashboard reads from the same audit chain as the rest of Novyx. Tenants on the standard cloud deployment use the Postgres backend (`backend: "postgres"`) and get full aggregate stats.

Tenants in **file mode** (local SQLite or filesystem audit log) receive an **empty-but-valid** response: the same shape, with all counts at zero and `backend: "file"`. This lets dashboard clients render the same UI regardless of backend without special-casing — a "no data yet" state instead of a 500 or a missing field.

If you're integrating the dashboard into your own tooling, check `backend` to know whether the zeros are "no activity" or "the file backend doesn't aggregate."

---

## `GET /v1/control/agents/{agent_id}/violations`

Per-agent violation history. Returns audit entries containing non-empty violation payloads, ordered most recent first.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `agent_id` | string | The agent identifier. |

### Query parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | number | `50` | Max entries to return. |
| `since` | string | — | ISO 8601 timestamp lower bound. |
| `until` | string | — | ISO 8601 timestamp upper bound. |

> **Known issue (April 2026):** `since` and `until` currently return `novyx_ram.v1.control.violations_failed` against the live API. Until that's fixed, omit them and filter client-side. Tracking under the violations endpoint backlog.

### Response shape

| Field | Type | Description |
|-------|------|-------------|
| `agent_id` | string | The agent. |
| `total` | number | Number of entries returned. |
| `backend` | string | `postgres` or `file`. |
| `violations` | object[] | Violation entries. Each entry has `action_id`, `action`, `timestamp`, `event`, `triggered_policy`, `severity`, `reason`, `risk_score`, `violation_count`. |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
v = nx.agent_violations("billing-bot", limit=20)
print(f"{v['total']} violations for {v['agent_id']}")
for entry in v["violations"]:
    print(f"  {entry['timestamp']}: {entry['triggered_policy']} ({entry['severity']}) — {entry['reason']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const v = await nx.agentViolations("billing-bot", { limit: 20 });
console.log(`${v.total} violations for ${v.agent_id}`);
for (const entry of v.violations) {
  console.log(`  ${entry.timestamp}: ${entry.triggered_policy} (${entry.severity}) — ${entry.reason}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/control/agents/billing-bot/violations?limit=20" \
  -H "Authorization: Bearer nram_your_key"

# Filter by time range
curl "https://novyx-ram-api.fly.dev/v1/control/agents/billing-bot/violations?since=2026-04-01T00:00:00Z&until=2026-04-08T00:00:00Z" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Sample response

```json
{
  "agent_id": "billing-bot",
  "total": 3,
  "backend": "postgres",
  "violations": [
    {
      "action_id": "act_xyz789",
      "action": "http.transfer_funds",
      "timestamp": "2026-04-10T13:42:00Z",
      "event": "action_blocked",
      "triggered_policy": "FinancialSafetyPolicy",
      "severity": "critical",
      "reason": "Unauthorized financial operation",
      "risk_score": 0.92,
      "violation_count": 1
    }
  ]
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `novyx_ram.v1.tier.feature_required` | Tenant tier does not include `governance_dashboard` (Free tier). |

---

## See also

- [Custom Policies](./custom-policies) — author the rules whose firing is aggregated here
- [Approval Workflows](./approval-workflows) — the queue whose throughput shows up in `totals`
- [Agent-Scoped Policies](./agent-scoped-policies) — drill down by agent in `violations_by_agent`
