---
sidebar_position: 9
title: Cortex
description: Autonomous memory maintenance — consolidation, reinforcement, decay, and AI-generated insights.
---

# Cortex

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

The Cortex is Novyx's autonomous memory maintenance engine. It consolidates duplicate memories, reinforces frequently-recalled ones, decays stale memories, and generates AI-powered insights. You can configure each behavior independently and trigger cycles manually or let them run on schedule.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** Pro+ (Insights require Enterprise)

**Backend:** Requires Postgres

---

## Run Cortex Cycle

```
POST /v1/cortex/run
```

Trigger a manual Cortex cycle. Runs consolidation, reinforcement, and decay in sequence, then generates insights if enabled.

- **Consolidation:** Merges memories above the similarity threshold (default 90%)
- **Reinforcement:** Boosts importance of frequently-recalled memories
- **Decay:** Reduces importance of old, unused memories past the decay age
- **Insights:** Generates synthetic memories from detected patterns (Enterprise only)

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `consolidated` | number | Duplicate memories merged |
| `boosted` | number | Memories with boosted importance |
| `decayed` | number | Memories with reduced importance |
| `insights_generated` | number | New insight memories created |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

result = nx.cortex_run()
print(f"Consolidated: {result['consolidated']}")
print(f"Boosted: {result['boosted']}")
print(f"Decayed: {result['decayed']}")
print(f"Insights: {result['insights_generated']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const result = await nx.cortexRun();
console.log(`Consolidated: ${result.consolidated}`);
console.log(`Boosted: ${result.boosted}`);
console.log(`Decayed: ${result.decayed}`);
console.log(`Insights: ${result.insights_generated}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/cortex/run \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "consolidated": 3,
  "boosted": 12,
  "decayed": 5,
  "insights_generated": 2
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |
| 501 | `REQUIRES_POSTGRES` | Postgres backend required |

---

## Get Cortex Status

```
GET /v1/cortex/status
```

Get the current Cortex status including whether it's enabled, the last run timestamp, and run statistics.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `enabled` | boolean | Whether Cortex is enabled |
| `last_run_at` | string \| null | Last run timestamp (ISO 8601) |
| `run_stats` | object | Operation counts from last run |
| `config` | object | Current Cortex configuration (see below) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
status = nx.cortex_status()
print(f"Enabled: {status['enabled']}")
print(f"Last run: {status['last_run_at']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const status = await nx.cortexStatus();
console.log(`Enabled: ${status.enabled}`);
console.log(`Last run: ${status.last_run_at}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/cortex/status \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "enabled": true,
  "last_run_at": "2026-03-09T06:00:00Z",
  "run_stats": {
    "consolidated": 3,
    "boosted": 12,
    "decayed": 5,
    "insights_generated": 0
  },
  "config": {
    "tenant_id": "tenant_abc123",
    "enabled": true,
    "consolidation_enabled": true,
    "consolidation_threshold": 0.90,
    "reinforcement_enabled": true,
    "decay_enabled": true,
    "decay_age_days": 30,
    "insight_generation_enabled": false,
    "last_run_at": "2026-03-09T06:00:00Z",
    "run_stats": {}
  }
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |
| 501 | `REQUIRES_POSTGRES` | Postgres backend required |

---

## Get Cortex Config

```
GET /v1/cortex/config
```

Retrieve the current Cortex configuration.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `tenant_id` | string | Your tenant ID |
| `enabled` | boolean | Whether Cortex is enabled |
| `consolidation_enabled` | boolean | Merge duplicate memories |
| `consolidation_threshold` | number | Similarity threshold for merging (0.5–1.0) |
| `reinforcement_enabled` | boolean | Boost frequently-recalled memories |
| `decay_enabled` | boolean | Decay old, unused memories |
| `decay_age_days` | number | Days before decay kicks in (1–365) |
| `insight_generation_enabled` | boolean | Generate AI insights (Enterprise only) |
| `last_run_at` | string \| null | Last run timestamp |
| `run_stats` | object | Last run statistics |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
config = nx.cortex_config()
print(f"Consolidation threshold: {config['consolidation_threshold']}")
print(f"Decay after: {config['decay_age_days']} days")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const config = await nx.cortexConfig();
console.log(`Consolidation threshold: ${config.consolidation_threshold}`);
console.log(`Decay after: ${config.decay_age_days} days`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/cortex/config \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "tenant_id": "tenant_abc123",
  "enabled": true,
  "consolidation_enabled": true,
  "consolidation_threshold": 0.90,
  "reinforcement_enabled": true,
  "decay_enabled": true,
  "decay_age_days": 30,
  "insight_generation_enabled": false,
  "last_run_at": "2026-03-09T06:00:00Z",
  "run_stats": {}
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |
| 501 | `REQUIRES_POSTGRES` | Postgres backend required |

---

## Update Cortex Config

```
PATCH /v1/cortex/config
```

Update Cortex configuration. Send only the fields you want to change.

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `enabled` | boolean | No | — | Enable or disable Cortex |
| `consolidation_enabled` | boolean | No | — | Enable/disable consolidation |
| `consolidation_threshold` | number | No | — | Similarity threshold (0.5–1.0) |
| `reinforcement_enabled` | boolean | No | — | Enable/disable reinforcement |
| `decay_enabled` | boolean | No | — | Enable/disable decay |
| `decay_age_days` | number | No | — | Days before decay (1–365) |
| `insight_generation_enabled` | boolean | No | — | Enable insights (Enterprise only) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# Lower the consolidation threshold
updated = nx.update_cortex_config(
    consolidation_threshold=0.85,
    decay_age_days=14,
)

# Disable decay
updated = nx.update_cortex_config(decay_enabled=False)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// Lower the consolidation threshold
const updated = await nx.updateCortexConfig({
  consolidationThreshold: 0.85,
  decayAgeDays: 14,
});

// Disable decay
const updated2 = await nx.updateCortexConfig({ decayEnabled: false });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X PATCH https://novyx-ram-api.fly.dev/v1/cortex/config \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "consolidation_threshold": 0.85,
    "decay_age_days": 14
  }'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan or Enterprise for insights |
| 501 | `REQUIRES_POSTGRES` | Postgres backend required |

---

## List Insights

```
GET /v1/cortex/insights
```

List AI-generated insight memories created by the Cortex. These are synthetic memories derived from patterns detected across your memory store.

:::note Enterprise only
Insight generation requires an Enterprise plan. Enable it via `PATCH /v1/cortex/config`.
:::

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | number | No | `20` | Max results (1–100) |
| `offset` | number | No | `0` | Pagination offset |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `insights` | array | Array of insight memory objects |
| `total` | number | Total insight count |

Each insight includes:

| Field | Type | Description |
|-------|------|-------------|
| `uuid` | string | Insight memory identifier |
| `observation` | string | Generated insight text |
| `tags` | string[] | Auto-generated tags |
| `importance` | number | Assigned importance score |
| `created_at` | string | Generation timestamp |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
insights = nx.cortex_insights(limit=10)
for insight in insights["insights"]:
    print(f"[{insight['importance']}] {insight['observation']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const insights = await nx.cortexInsights({ limit: 10 });
for (const insight of insights.insights) {
  console.log(`[${insight.importance}] ${insight.observation}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/cortex/insights?limit=10" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "insights": [
    {
      "uuid": "urn:uuid:i1a2b3c4-d5e6-7890-abcd-ef1234567890",
      "observation": "User consistently prefers dark themes across all applications and adjusts font sizes for readability",
      "tags": ["insight", "preferences", "ui"],
      "importance": 7,
      "created_at": "2026-03-09T06:00:00Z"
    }
  ],
  "total": 5
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Enterprise plan |
| 501 | `REQUIRES_POSTGRES` | Postgres backend required |
