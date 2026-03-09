---
sidebar_position: 18
title: Usage
description: Check your plan usage, limits, quotas, and spend estimates.
---

# Usage

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Check your current plan usage, remaining quotas, spend estimates, and feature availability.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** All

---

## Get Usage

```
GET /v1/usage
```

Get your current plan usage and limits for the billing period.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `tier` | string | Current plan tier |
| `api_calls` | object | `{ used, limit, unlimited }` |
| `memories` | object | `{ used, limit, unlimited }` |
| `rollbacks` | object | `{ used, limit, unlimited }` |
| `audit_retention_days` | number | Audit log retention |
| `features` | object | Feature flags for your plan |
| `period` | string | Billing period (`YYYY-MM`) |
| `resets_at` | string \| null | Next reset timestamp (ISO 8601) |
| `usage_pressure_level` | string | `low`, `medium`, `high`, or `critical` |
| `projected_limit_date` | string \| null | Projected quota exhaustion date |
| `budget_alert` | boolean | Whether budget is exceeded |
| `spend_estimate` | object | `{ spend_estimate_usd, projected_spend_estimate_usd, storage_estimate_usd }` |
| `quota_percent` | object | `{ api_calls, memories, rollbacks }` as percentages |
| `upgrade_message` | string \| null | Tier-specific upgrade prompt |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

usage = nx.usage()
print(f"Plan: {usage['tier']}")
print(f"API calls: {usage['api_calls']['used']}/{usage['api_calls']['limit']}")
print(f"Memories: {usage['memories']['used']}/{usage['memories']['limit']}")
print(f"Pressure: {usage['usage_pressure_level']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const usage = await nx.usage();
console.log(`Plan: ${usage.tier}`);
console.log(`API calls: ${usage.api_calls.used}/${usage.api_calls.limit}`);
console.log(`Memories: ${usage.memories.used}/${usage.memories.limit}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/usage \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "tier": "starter",
  "api_calls": { "used": 1250, "limit": 10000, "unlimited": false },
  "memories": { "used": 87, "limit": 500, "unlimited": false },
  "rollbacks": { "used": 3, "limit": 50, "unlimited": false },
  "audit_retention_days": 30,
  "features": {
    "semantic_search": true,
    "rollback": true,
    "trace_audit": false,
    "knowledge_graph": false,
    "spaces": true
  },
  "period": "2026-03",
  "resets_at": "2026-04-01T00:00:00Z",
  "usage_pressure_level": "low",
  "projected_limit_date": null,
  "budget_alert": false,
  "spend_estimate": {
    "spend_estimate_usd": 0.0,
    "projected_spend_estimate_usd": 0.0,
    "storage_estimate_usd": 0.0
  },
  "quota_percent": {
    "api_calls": 12.5,
    "memories": 17.4,
    "rollbacks": 6.0
  },
  "upgrade_message": null
}
```

---

## Dashboard

```
GET /v1/dashboard
```

Get a compact summary of your account for dashboard UIs.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `memory_count` | number | Total stored memories |
| `tier` | string | Current plan |
| `features` | object | Feature flags |
| `usage_percent` | object | `{ api_calls, memories, rollbacks }` as percentages |
| `pressure` | string | `low`, `medium`, `high`, or `critical` |
| `api_calls_today` | number | API calls made today |
| `limits` | object | `{ api_calls, memories, rollbacks }` |
| `period` | string | Billing period (`YYYY-MM`) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
dashboard = nx.dashboard()
print(f"Memories: {dashboard['memory_count']}")
print(f"Pressure: {dashboard['pressure']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const dashboard = await nx.dashboard();
console.log(`Memories: ${dashboard.memory_count}`);
console.log(`Pressure: ${dashboard.pressure}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/dashboard \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "memory_count": 87,
  "tier": "starter",
  "features": {
    "semantic_search": true,
    "rollback": true,
    "trace_audit": false
  },
  "usage_percent": {
    "api_calls": 12.5,
    "memories": 17.4,
    "rollbacks": 6.0
  },
  "pressure": "low",
  "api_calls_today": 42,
  "limits": {
    "api_calls": 10000,
    "memories": 500,
    "rollbacks": 50
  },
  "period": "2026-03"
}
```
