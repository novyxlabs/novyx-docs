---
sidebar_position: 10
title: Eval
description: Memory health scoring, drift analysis, recall baselines, and CI/CD gate checks.
---

# Eval

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

The Eval router scores the health of your memory store, tracks drift over time, and provides a CI/CD gate to fail builds when memory quality drops below a threshold. Set recall baselines to catch regressions.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** All (gate requires Pro+, drift detail requires Pro+)

**Plan limits:** Free: 3 runs/day, 1 baseline · Starter: 30 runs/day, 5 baselines · Pro+: unlimited

---

## Run Eval

```
POST /v1/eval/run
```

Run a health evaluation of your memory store. Returns an overall health score (0–100) with a breakdown across four dimensions.

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `min_score` | number | No | — | Minimum score threshold (0–100). If set, response includes `passed` |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `eval_id` | string | Evaluation identifier |
| `health_score` | number | Overall health score (0–100) |
| `breakdown` | object | Score breakdown (see below) |
| `memory_count` | number | Total memories |
| `conflict_count` | number | Memories with conflicts |
| `stale_count` | number | Stale memories |
| `passed` | boolean \| null | Pass/fail result (only if `min_score` set) |
| `drift_detail` | object \| null | Drift analysis (Pro+ only) |
| `created_at` | string | ISO 8601 timestamp |

Breakdown fields:

| Field | Type | Description |
|-------|------|-------------|
| `recall_consistency` | number | How well baselines are recalled (0–100) |
| `drift_score` | number | Memory drift measurement (0–100) |
| `conflict_score` | number | Conflict health (0–100) |
| `staleness_score` | number | Freshness of memories (0–100) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

result = nx.eval_run()
print(f"Health: {result['health_score']}/100")
print(f"Recall: {result['breakdown']['recall_consistency']}")
print(f"Drift: {result['breakdown']['drift_score']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const result = await nx.evalRun();
console.log(`Health: ${result.health_score}/100`);
console.log(`Recall: ${result.breakdown.recall_consistency}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/eval/run \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{}'
```

</TabItem>
</Tabs>

### Response

```json
{
  "eval_id": "eval_a1b2c3d4",
  "health_score": 87.5,
  "breakdown": {
    "recall_consistency": 95.0,
    "drift_score": 82.0,
    "conflict_score": 90.0,
    "staleness_score": 83.0
  },
  "memory_count": 142,
  "conflict_count": 2,
  "stale_count": 8,
  "passed": null,
  "drift_detail": null,
  "created_at": "2026-03-09T12:00:00Z"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 429 | `RATE_LIMITED` | Daily eval limit exceeded |

---

## CI/CD Gate

```
POST /v1/eval/gate
```

Run an eval with a required minimum score. Returns `200` on pass, `422` on fail — designed for CI/CD pipelines.

:::tip CI/CD integration
Use this in your deployment pipeline to block deploys when memory quality drops:
```bash
curl -sf -X POST .../v1/eval/gate -d '{"min_score": 80}' || exit 1
```
:::

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `min_score` | number | **Yes** | — | Minimum passing score (0–100) |

### Response fields

Same as [Run Eval](#run-eval). `passed` is always set.

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# Fail CI if health drops below 80
result = nx.eval_gate(min_score=80)
if not result["passed"]:
    raise SystemExit(f"Eval failed: {result['health_score']}/100")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.evalGate({ minScore: 80 });
if (!result.passed) {
  throw new Error(`Eval failed: ${result.health_score}/100`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/eval/gate \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"min_score": 80}'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |
| 422 | `GATE_FAILED` | Health score below `min_score` (response body includes full eval) |

---

## Eval History

```
GET /v1/eval/history
```

List past eval runs. Retention depends on your plan: Free 7 days, Starter 30 days, Pro+ 90 days.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | number | No | `50` | Max results (1–200) |
| `offset` | number | No | `0` | Pagination offset |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `entries` | array | Array of eval history entries |
| `total_count` | number | Total entries (within retention window) |
| `has_more` | boolean | Whether more pages exist |

Each entry includes `eval_id`, `health_score`, `breakdown`, `memory_count`, `passed`, and `created_at`.

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
history = nx.eval_history(limit=10)
for entry in history["entries"]:
    print(f"{entry['created_at']}: {entry['health_score']}/100")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const history = await nx.evalHistory({ limit: 10 });
for (const entry of history.entries) {
  console.log(`${entry.created_at}: ${entry.health_score}/100`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/eval/history?limit=10" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

---

## Drift Analysis

```
GET /v1/eval/drift
```

Analyze how your memory store has changed over a time window.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `days` | number | No | `7` | Analysis window (1–90 days) |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `drift_score` | number | Overall drift score |
| `period_days` | number | Analysis window |
| `memory_count_delta` | number | Net change in memory count |
| `avg_importance_delta` | number | Change in average importance (Pro+) |
| `top_new_topics` | string[] | Emerging topics (Pro+) |
| `top_lost_topics` | string[] | Declining topics (Pro+) |
| `tag_shifts` | array | Tag count changes (Pro+) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
drift = nx.eval_drift(days=14)
print(f"Drift score: {drift['drift_score']}")
print(f"Memory delta: {drift['memory_count_delta']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const drift = await nx.evalDrift({ days: 14 });
console.log(`Drift score: ${drift.drift_score}`);
console.log(`Memory delta: ${drift.memory_count_delta}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/eval/drift?days=14" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Starter+ plan |

---

## Create Baseline

```
POST /v1/eval/baselines
```

Create a recall baseline — a query/expected-answer pair that eval checks on every run.

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `query` | string | **Yes** | — | Recall query (1–500 characters) |
| `expected_observation` | string | **Yes** | — | Expected top result (1–2000 characters) |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Baseline identifier |
| `query` | string | Recall query |
| `expected_observation` | string | Expected result |
| `expected_score` | number \| null | Similarity score |
| `created_at` | string | ISO 8601 timestamp |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
baseline = nx.create_baseline(
    query="What UI theme does the user prefer?",
    expected_observation="User prefers dark mode and compact layouts",
)
print(baseline["id"])
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const baseline = await nx.createBaseline({
  query: "What UI theme does the user prefer?",
  expectedObservation: "User prefers dark mode and compact layouts",
});
console.log(baseline.id);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/eval/baselines \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What UI theme does the user prefer?",
    "expected_observation": "User prefers dark mode and compact layouts"
  }'
```

</TabItem>
</Tabs>

### Response

```json
{
  "id": "bl_a1b2c3d4",
  "query": "What UI theme does the user prefer?",
  "expected_observation": "User prefers dark mode and compact layouts",
  "expected_score": null,
  "created_at": "2026-03-09T12:00:00Z"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 429 | `RATE_LIMITED` | Baseline limit exceeded for your plan |

---

## List Baselines

```
GET /v1/eval/baselines
```

List all recall baselines.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `baselines` | array | Array of baseline objects |
| `total_count` | number | Total baselines |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.list_baselines()
for bl in result["baselines"]:
    print(f"{bl['query']} → {bl['expected_observation'][:40]}...")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.listBaselines();
for (const bl of result.baselines) {
  console.log(`${bl.query} → ${bl.expected_observation.slice(0, 40)}...`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/eval/baselines \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

---

## Delete Baseline

```
DELETE /v1/eval/baselines/{baseline_id}
```

Delete a recall baseline.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `baseline_id` | string | Baseline identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
nx.delete_baseline("bl_a1b2c3d4")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
await nx.deleteBaseline("bl_a1b2c3d4");
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X DELETE https://novyx-ram-api.fly.dev/v1/eval/baselines/bl_a1b2c3d4 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

Returns `204 No Content` on success.

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Baseline does not exist |
