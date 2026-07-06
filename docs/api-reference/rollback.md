---
sidebar_position: 3
title: "Novyx API: Rollback — Memory Recovery Helpers"
description: "Preview and execute memory rollback helpers. External side effects require compensation and are not automatically undone."
---

# Rollback

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Rollback is a memory-layer recovery helper. Preview what will change before executing. It can remove memories created after the target timestamp and restore memories deleted after the target when the backend has enough history. It does not transactionally restore full agent state, policy snapshots, connector bindings, or external side effects.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Current backend limits:** Free: 10 rollbacks/mo · Starter: 50/mo · Pro+: unlimited

---

## Execute Rollback

```
POST /v1/rollback
```

Execute a memory rollback toward a target timestamp. This is a destructive memory operation: memories created after the target may be removed, and memories deleted after the target may be restored when recoverable from stored history.

:::tip Always preview first
Use [Preview Rollback](#preview-rollback) to see what will change before executing. Treat rollback as an incident-recovery helper, not as a transactional undo guarantee.
:::

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `target` | string | **Yes** | — | ISO 8601 timestamp to roll back to (e.g. `2026-03-09T14:00:00Z`) |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Whether the rollback succeeded |
| `rolled_back_to` | string | Target timestamp requested for rollback |
| `artifacts_restored` | number | Artifacts restored (were deleted after target) |
| `operations_undone` | number | Operations undone (were created after target) |
| `message` | string | Human-readable summary of the rollback |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

# Roll back to 2 hours ago
result = nx.rollback("2026-03-09T12:00:00Z")
print(f"Restored: {result['artifacts_restored']}, Undone: {result['operations_undone']}")
```

The Python SDK also supports natural language targets:

```python
# Natural language rollback (SDK converts to timestamp)
result = nx.rollback("2 hours ago")
result = nx.rollback("yesterday at 3pm")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const result = await nx.rollback("2026-03-09T12:00:00Z");
console.log(`Restored: ${result.artifacts_restored}, Undone: ${result.operations_undone}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/rollback \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"target": "2026-03-09T12:00:00Z"}'
```

</TabItem>
</Tabs>

### Response

```json
{
  "success": true,
  "rolled_back_to": "2026-03-09T12:00:00Z",
  "artifacts_restored": 3,
  "operations_undone": 7,
  "message": "Rolled back to 2026-03-09T12:00:00Z — restored 3 artifacts, undone 7 operations"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Missing `target` or invalid timestamp format |
| 403 | `TIER_REQUIRED` | Rollback limit exceeded for your plan |
| 429 | `RATE_LIMITED` | Exceeded monthly rollback quota |

---

## Preview Rollback

```
GET /v1/rollback/preview
```

Preview what a rollback would do without executing it. Shows which memories would be restored and which would be removed. No side effects.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `target` | string | **Yes** | — | ISO 8601 timestamp |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `target_timestamp` | string | The target timestamp being previewed |
| `artifacts_modified` | number | Artifacts that would be modified |
| `artifacts_deleted` | number | Artifacts that would be deleted |
| `size_bytes` | number | Total size of affected artifacts in bytes |
| `safe_rollback` | boolean | Whether the rollback is safe to execute |
| `warnings` | string[] | Warnings about potential issues (empty if safe) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# Preview before executing
preview = nx.rollback_preview("2026-03-09T12:00:00Z")
print(f"Artifacts modified: {preview['artifacts_modified']}")
print(f"Artifacts deleted: {preview['artifacts_deleted']}")
print(f"Safe: {preview['safe_rollback']}")

# If the preview looks right, execute
if preview["safe_rollback"]:
    result = nx.rollback("2026-03-09T12:00:00Z")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// Preview before executing
const preview = await nx.rollbackPreview("2026-03-09T12:00:00Z");
console.log(`Artifacts modified: ${preview.artifacts_modified}`);
console.log(`Artifacts deleted: ${preview.artifacts_deleted}`);
console.log(`Safe: ${preview.safe_rollback}`);

// If the preview looks right, execute
if (preview.safe_rollback) {
  const result = await nx.rollback("2026-03-09T12:00:00Z");
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/rollback/preview?target=2026-03-09T12:00:00Z" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "target_timestamp": "2026-03-09T12:00:00Z",
  "artifacts_modified": 3,
  "artifacts_deleted": 7,
  "size_bytes": 14320,
  "safe_rollback": true,
  "warnings": []
}
```

---

## Compensation Plans

When memory rollback intersects with actions that triggered side effects (API calls, webhook fires, external writes), Novyx can expose a compensation plan: reviewable reversal steps for an operator to execute or acknowledge. Compensation plans do not automatically undo every side effect.

Compensation plans are managed through the [Compensations router](/api-reference/compensations). The workflow:

1. **Preview** a compensation plan for a time range
2. **Review** the generated reversal actions
3. **Acknowledge** each action as completed, failed, or skipped
4. The plan auto-completes when all actions are acknowledged

See the [Compensations API reference](/api-reference/compensations) for the full endpoint documentation.

---

## Rollback workflow

A typical rollback workflow:

```
1. nx.rollback_preview("2 hours ago")     → See what would change
2. Review the preview results
3. nx.rollback("2 hours ago")             → Execute the rollback
4. nx.recall("check current state")       → Verify the results
```

For rollbacks with side effects (Pro+):

```
1. Preview compensation plan              → See reversal actions
2. Execute rollback                       → Apply memory-layer recovery
3. Work through compensation actions      → Review external side-effect remediation
4. Acknowledge each action                → Mark as done/failed/skipped
```
