---
sidebar_position: 16
title: Compensations
description: Compensation plans for undoing external actions after a rollback.
---

# Compensations

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

The Compensations router generates and tracks compensation plans for external actions that may need to be undone after a memory rollback. When you roll back memory state, Novyx scans trace ACTION steps in the rollback window and produces a reverse-chronological list of external actions to undo, with per-action acknowledgment tracking.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** Pro+ (requires trace audit capability)

---

## Preview Compensation Plan

```
POST /v1/compensations/preview
```

Generate a compensation plan for a time range. Scans trace ACTION steps between `rollback_to` and `rollback_from` and returns a list of external actions that may need to be undone, in reverse chronological order. The plan is persisted for tracking.

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `rollback_from` | string | **Yes** | ISO 8601 timestamp: start of window (usually now) |
| `rollback_to` | string | **Yes** | ISO 8601 timestamp: rollback target |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `compensation_id` | string | Compensation plan identifier |
| `status` | string | Plan status (`pending`, `in_progress`, `completed`) |
| `rollback_from` | string | Window start |
| `rollback_to` | string | Window end |
| `actions` | array | Compensation actions to perform (reverse chronological) |
| `created_at` | string | ISO 8601 timestamp |

Each action includes:

| Field | Type | Description |
|-------|------|-------------|
| `index` | number | Action index within the plan |
| `trace_id` | string | Source trace identifier |
| `description` | string | What needs to be undone |
| `connector` | string | Connector involved (github, slack, etc.) |
| `status` | string | `pending`, `completed`, `failed`, or `skipped` |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

plan = nx.compensation_preview(
    rollback_from="2026-03-15T14:00:00Z",
    rollback_to="2026-03-15T12:00:00Z"
)
print(f"Compensation ID: {plan['compensation_id']}")
print(f"Actions to undo: {len(plan['actions'])}")
for action in plan["actions"]:
    print(f"  [{action['connector']}] {action['description']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const plan = await nx.compensationPreview({
  rollbackFrom: "2026-03-15T14:00:00Z",
  rollbackTo: "2026-03-15T12:00:00Z",
});
console.log(`Actions to undo: ${plan.actions.length}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/compensations/preview \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "rollback_from": "2026-03-15T14:00:00Z",
    "rollback_to": "2026-03-15T12:00:00Z"
  }'
```

</TabItem>
</Tabs>

### Response

```json
{
  "compensation_id": "comp_a1b2c3d4",
  "status": "pending",
  "rollback_from": "2026-03-15T14:00:00Z",
  "rollback_to": "2026-03-15T12:00:00Z",
  "actions": [
    {
      "index": 0,
      "trace_id": "trace_xyz",
      "description": "Revert Slack message posted to #deployments",
      "connector": "slack",
      "status": "pending"
    },
    {
      "index": 1,
      "trace_id": "trace_abc",
      "description": "Close GitHub PR #42 that was auto-merged",
      "connector": "github",
      "status": "pending"
    }
  ],
  "created_at": "2026-03-15T14:05:00Z"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `feature_not_available` | Requires Pro or Enterprise plan |

---

## List Compensation Plans

```
GET /v1/compensations
```

List compensation plans for the current tenant.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | number | No | `20` | Max results (1-100) |

### Response fields

Returns an array of compensation plan objects (same structure as the preview response).

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
plans = nx.list_compensations(limit=10)
for plan in plans:
    pending = sum(1 for a in plan["actions"] if a["status"] == "pending")
    print(f"{plan['compensation_id']}: {pending} actions pending")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const plans = await nx.listCompensations({ limit: 10 });
for (const plan of plans) {
  console.log(`${plan.compensation_id}: ${plan.status}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/compensations?limit=10" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `feature_not_available` | Requires Pro or Enterprise plan |

---

## Get Compensation Plan

```
GET /v1/compensations/{compensation_id}
```

Get a compensation plan with all actions and their current statuses.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `compensation_id` | string | Compensation plan identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
plan = nx.get_compensation("comp_a1b2c3d4")
for action in plan["actions"]:
    print(f"  [{action['status']}] {action['description']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const plan = await nx.getCompensation("comp_a1b2c3d4");
for (const action of plan.actions) {
  console.log(`  [${action.status}] ${action.description}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/compensations/comp_a1b2c3d4 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `compensation.not_found` | Compensation plan not found |

---

## Acknowledge Action

```
PATCH /v1/compensations/{compensation_id}/actions/{action_index}
```

Mark a compensation action as completed, failed, or skipped. When all actions in a plan are acknowledged, the plan status automatically changes to `completed`.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `compensation_id` | string | Compensation plan identifier |
| `action_index` | number | Zero-based index of the action within the plan |

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | **Yes** | Action outcome: `completed`, `failed`, or `skipped` |
| `detail` | string | No | Optional detail about the outcome (max 500 characters) |

### Response fields

Returns the updated compensation plan with all actions and their statuses.

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# Mark the first action as completed
result = nx.acknowledge_compensation(
    "comp_a1b2c3d4",
    action_index=0,
    status="completed",
    detail="Slack message deleted successfully"
)

# Skip an action that can't be undone
result = nx.acknowledge_compensation(
    "comp_a1b2c3d4",
    action_index=1,
    status="skipped",
    detail="PR was already reverted by another process"
)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.acknowledgeCompensation("comp_a1b2c3d4", {
  actionIndex: 0,
  status: "completed",
  detail: "Slack message deleted successfully",
});
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X PATCH https://novyx-ram-api.fly.dev/v1/compensations/comp_a1b2c3d4/actions/0 \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "completed",
    "detail": "Slack message deleted successfully"
  }'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `compensation.not_found` | Compensation plan or action index not found |
| 403 | `feature_not_available` | Requires Pro or Enterprise plan |
