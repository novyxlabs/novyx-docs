---
sidebar_position: 19
title: System
description: Health checks, status, milestones, and metrics — no auth required for liveness probes.
---

# System

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

System endpoints for health checks, status monitoring, and milestone tracking. The liveness probe requires no authentication.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** Public (no auth for health/liveness, auth required for status details and milestones)

---

## Liveness Probe

```
GET /healthz
```

Lightweight liveness check. Always returns `200` if the server is running. No authentication required.

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
import requests

r = requests.get("https://novyx-ram-api.fly.dev/healthz")
print(r.json())  # {"status": "ok"}
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const res = await fetch("https://novyx-ram-api.fly.dev/healthz");
const data = await res.json();
console.log(data); // { status: "ok" }
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/healthz
```

</TabItem>
</Tabs>

### Response

```json
{
  "status": "ok"
}
```

---

## Health Check

```
GET /health
```

Detailed health check. Without authentication, returns minimal info. With a valid API key, returns subsystem checks.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `status` | string | `healthy`, `degraded`, or `unhealthy` |
| `version` | string | API version |
| `timestamp` | string | ISO 8601 timestamp |
| `enterprise_available` | boolean | Whether enterprise features are available |
| `checks` | object \| null | Subsystem checks (authenticated only) |
| `warnings` | string[] \| null | Non-critical issues (authenticated only) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

health = nx.health()
print(f"Status: {health['status']}")
print(f"Version: {health['version']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const health = await nx.health();
console.log(`Status: ${health.status}`);
console.log(`Version: ${health.version}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# Basic (no auth)
curl https://novyx-ram-api.fly.dev/health

# Detailed (with auth)
curl https://novyx-ram-api.fly.dev/health \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "status": "healthy",
  "version": "1.1.1",
  "timestamp": "2026-03-09T12:00:00Z",
  "enterprise_available": true,
  "checks": {
    "disk_space": "ok",
    "memory_dir": "ok",
    "redis": "ok",
    "audit_trail": "ok"
  },
  "warnings": []
}
```

---

## Status

```
GET /v1/status
```

Get API status and optional runtime metrics. Without authentication, returns basic status. With auth, includes uptime and usage stats.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | API version |
| `status` | string | `operational` |
| `timestamp` | string | ISO 8601 timestamp |
| `uptime_seconds` | number | Server uptime (authenticated only) |
| `total_memories_stored` | number | Total memories (authenticated only) |
| `avg_response_time_ms` | number | Average response time (authenticated only) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
status = nx.status()
print(f"Status: {status['status']}")
print(f"Uptime: {status['uptime_seconds']}s")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const status = await nx.status();
console.log(`Status: ${status.status}`);
console.log(`Uptime: ${status.uptime_seconds}s`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/status \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "version": "1.1.1",
  "status": "operational",
  "timestamp": "2026-03-09T12:00:00Z",
  "uptime_seconds": 86400.5,
  "total_memories_stored": 1423,
  "avg_response_time_ms": 45.2
}
```

---

## Milestones

```
GET /v1/milestones
```

Get your account milestones — key moments like storing your first memory, first rollback, first team, etc.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `milestones` | array | Array of milestone objects |
| `total` | number | Total milestones achieved |

Each milestone includes:

| Field | Type | Description |
|-------|------|-------------|
| `milestone` | string | Milestone identifier (e.g., `first_memory`, `first_rollback`) |
| `achieved_at` | string | ISO 8601 timestamp |
| `metadata` | object | Additional context |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.milestones()
for m in result["milestones"]:
    print(f"  {m['milestone']}: {m['achieved_at']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.milestones();
for (const m of result.milestones) {
  console.log(`  ${m.milestone}: ${m.achieved_at}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/milestones \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "milestones": [
    {
      "milestone": "first_memory",
      "achieved_at": "2026-03-01T10:00:00Z",
      "metadata": {}
    },
    {
      "milestone": "first_search",
      "achieved_at": "2026-03-01T10:05:00Z",
      "metadata": {}
    },
    {
      "milestone": "first_rollback",
      "achieved_at": "2026-03-02T14:30:00Z",
      "metadata": {}
    }
  ],
  "total": 3
}
```
