---
sidebar_position: 13
title: "Novyx API: Milestones — Named Memory Checkpoints"
description: "Create named checkpoints in agent memory history. Tag important states for easy rollback and reference."
---

# Milestones

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Milestones track key moments in your Novyx journey — your first memory, first search, first rollback, and more. They're recorded automatically as you use the API.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** All

---

## List Milestones

```
GET /v1/milestones
```

Get all milestones achieved by your account.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `milestones` | array | Array of milestone objects |
| `total` | number | Total milestones achieved |

Each milestone includes:

| Field | Type | Description |
|-------|------|-------------|
| `milestone` | string | Milestone identifier |
| `achieved_at` | string | ISO 8601 timestamp |
| `metadata` | object | Additional context |

Available milestones:

| Milestone | Triggered when |
|-----------|---------------|
| `first_memory` | You store your first memory |
| `first_search` | You run your first semantic search |
| `first_rollback` | You perform your first rollback |
| `first_replay` | You view the replay timeline |
| `first_cortex` | You run your first Cortex cycle |
| `first_space` | You create your first context space |
| `first_share` | You share a space with another tenant |
| `first_webhook` | You register your first webhook |
| `first_team` | You create your first team |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

result = nx.milestones()
for m in result["milestones"]:
    print(f"{m['milestone']}: {m['achieved_at']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const result = await nx.milestones();
for (const m of result.milestones) {
  console.log(`${m.milestone}: ${m.achieved_at}`);
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
    },
    {
      "milestone": "first_space",
      "achieved_at": "2026-03-05T09:00:00Z",
      "metadata": {}
    }
  ],
  "total": 4
}
```
