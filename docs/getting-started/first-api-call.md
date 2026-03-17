---
sidebar_position: 3
title: First API Call
description: Walkthrough of your first Novyx API calls with full response shapes.
---

# First API Call

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

This guide walks through the core operations — store, search, and rollback — with full request/response shapes.

## Store a memory

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

memory = nx.remember(
    "User prefers dark mode and larger font sizes",
    tags=["preferences", "ui"],
    importance=8,
)
print(memory)
```

  </TabItem>
  <TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const memory = await nx.remember({
  observation: "User prefers dark mode and larger font sizes",
  tags: ["preferences", "ui"],
  importance: 8,
});
console.log(memory);
```

  </TabItem>
  <TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/memories \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "observation": "User prefers dark mode and larger font sizes",
    "tags": ["preferences", "ui"],
    "importance": 8
  }'
```

  </TabItem>
</Tabs>

**Response:**

```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "observation": "User prefers dark mode and larger font sizes",
  "importance": 8,
  "tags": ["preferences", "ui"],
  "created_at": "2026-03-09T14:30:00Z"
}
```

### Key parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `observation` | string | Yes | The fact, preference, or context to store |
| `tags` | string[] | No | Labels for filtering and organization |
| `importance` | int | No | 1–10 weight for search ranking (default: 5) |
| `space_id` | string | No | Context Space to store in (Pro+) |

## Semantic search

Search returns semantically ranked results — ask a question in natural language.

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```python
results = nx.recall("What are the user's UI preferences?")

for r in results:
    print(f"{r['observation']} (score: {r['score']:.2f})")
```

  </TabItem>
  <TabItem value="typescript" label="TypeScript">

```typescript
const results = await nx.recall("What are the user's UI preferences?");

for (const r of results) {
  console.log(`${r.observation} (score: ${r.score.toFixed(2)})`);
}
```

  </TabItem>
  <TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/memories/search?q=user+UI+preferences" \
  -H "Authorization: Bearer nram_your_key"
```

  </TabItem>
</Tabs>

**Response:**

```json
{
  "results": [
    {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "observation": "User prefers dark mode and larger font sizes",
      "score": 0.92,
      "importance": 8,
      "tags": ["preferences", "ui"],
      "created_at": "2026-03-09T14:30:00Z"
    }
  ]
}
```

### Search parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `q` | string | — | Natural language search query |
| `limit` | int | 10 | Max results to return |
| `threshold` | float | 0.0 | Minimum similarity score |
| `tags` | string[] | — | Filter by tags (AND logic) |
| `recency_weight` | float | 0.0 | 0.0–1.0, boost recent memories |

## Rollback

Undo agent mistakes by reverting memory to any point in time.

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```python
# Preview what will change (non-destructive)
preview = nx.rollback_preview(target="1 hour ago")
print(f"Will modify {preview['artifacts_modified']} and delete {preview['artifacts_deleted']}")

# Execute the rollback
result = nx.rollback(target="1 hour ago")
print(f"Rolled back: {result['message']}")
```

  </TabItem>
  <TabItem value="typescript" label="TypeScript">

```typescript
// Preview what will change (non-destructive)
const preview = await nx.rollbackPreview({ target: "1 hour ago" });
console.log(`Will modify ${preview.artifacts_modified} and delete ${preview.artifacts_deleted}`);

// Execute the rollback
const result = await nx.rollback({ target: "1 hour ago" });
console.log(`Rolled back: ${result.message}`);
```

  </TabItem>
  <TabItem value="curl" label="curl">

```bash
# Preview
curl "https://novyx-ram-api.fly.dev/v1/rollback/preview?target=1+hour+ago" \
  -H "Authorization: Bearer nram_your_key"

# Execute
curl -X POST https://novyx-ram-api.fly.dev/v1/rollback \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"target": "1 hour ago"}'
```

  </TabItem>
</Tabs>

**Response:**

```json
{
  "success": true,
  "rolled_back_to": "2026-03-09T13:30:00Z",
  "artifacts_restored": 2,
  "operations_undone": 3,
  "message": "Rolled back to 1 hour ago"
}
```

:::info Rollback targets
The `target` parameter accepts:
- **Relative time:** `"2 hours ago"`, `"30 minutes ago"`, `"1 day ago"`
- **ISO 8601 timestamp:** `"2026-03-09T14:00:00Z"`
- **Human-readable date:** `"yesterday"`, `"last week"`
:::

## Sessions

Scope memories to a conversation or user session:

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```python
session = nx.session("chat-user-123")
session.remember("User asked about dark mode")
results = session.recall("dark mode")
```

  </TabItem>
  <TabItem value="typescript" label="TypeScript">

```typescript
const session = nx.session("chat-user-123");
await session.remember({ observation: "User asked about dark mode" });
const results = await session.recall("dark mode");
```

  </TabItem>
</Tabs>

Sessions are scoped subsets of your memory. Memories stored in a session are still searchable globally, but session-scoped queries only return memories from that session.

## Audit trail

Every operation is SHA-256 hashed and timestamped:

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```python
logs = nx.audit(limit=5)
for log in logs:
    print(f"{log['event_type']} at {log['timestamp']} — hash: {log['hash_chain'][:16]}...")
```

  </TabItem>
  <TabItem value="typescript" label="TypeScript">

```typescript
const logs = await nx.audit({ limit: 5 });
for (const log of logs) {
  console.log(`${log.event_type} at ${log.timestamp} — hash: ${log.hash_chain.slice(0, 16)}...`);
}
```

  </TabItem>
</Tabs>

## Next steps

- **[Authentication](/getting-started/authentication)** — API key management and security
- **[API Reference](/api-reference)** — All 120+ endpoints across 19 routers
- **[Rollback guide](/guides/rollback)** — Advanced rollback patterns
- **[Eval guide](/guides/eval)** — Memory health scoring and CI/CD gates
