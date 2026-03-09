---
sidebar_position: 1
title: Memories
description: Store, retrieve, update, delete, and export memories. The core CRUD endpoints for Novyx.
---

# Memories

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

The Memories router is the core of Novyx. Store observations, retrieve them by ID, list with filters, update fields, delete, and export.

**Base URL:** `https://novyx-ram-api.fly.dev`

---

## Store Memory

```
POST /v1/memories
```

Store a new memory. Returns the memory ID, content hash, and auto-link results.

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `observation` | string | **Yes** | — | The memory content |
| `tags` | string[] | No | `[]` | Tags for filtering |
| `importance` | number | No | `5` | Importance score (1–10) |
| `context` | string | No | — | Additional context metadata |
| `agent_id` | string | No | — | Agent identifier |
| `space_id` | string | No | — | Space namespace (Pro+) |
| `ttl_seconds` | number | No | — | Auto-expire after N seconds (60–7,776,000) |
| `auto_link` | boolean | No | `true` | Auto-link to similar memories |
| `on_conflict` | string | No | `"REJECT"` | Conflict strategy: `REJECT`, `SUPERSEDE`, `MERGE` |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique memory identifier (`urn:uuid:...`) |
| `hash` | string | SHA-256 content hash |
| `created_at` | string | ISO 8601 timestamp |
| `conflict_detected` | boolean | Whether a conflict was detected |
| `auto_links` | string[] | IDs of auto-linked memories |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

result = nx.remember(
    "User prefers dark mode and compact layouts",
    tags=["preferences", "ui"],
    importance=8,
)
print(result["id"])       # urn:uuid:a1b2c3d4-...
print(result["hash"])     # sha256 content hash
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const result = await nx.remember(
  "User prefers dark mode and compact layouts",
  { tags: ["preferences", "ui"], importance: 8 }
);
console.log(result.id);   // urn:uuid:a1b2c3d4-...
console.log(result.hash); // sha256 content hash
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/memories \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "observation": "User prefers dark mode and compact layouts",
    "tags": ["preferences", "ui"],
    "importance": 8
  }'
```

</TabItem>
</Tabs>

### Response

```json
{
  "id": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "created_at": "2026-03-09T12:00:00Z",
  "conflict_detected": false,
  "auto_links": []
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Missing `observation` or invalid `importance` range |
| 409 | `CONFLICT` | Duplicate content detected and `on_conflict` is `REJECT` |
| 429 | `RATE_LIMITED` | Exceeded plan memory limit or API call quota |

---

## List Memories

```
GET /v1/memories
```

List all memories for your tenant, ordered by creation date (newest first).

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | number | No | `20` | Max results (1–100) |
| `offset` | number | No | `0` | Pagination offset |
| `tags` | string | No | — | Filter by tag |
| `agent_id` | string | No | — | Filter by agent |
| `space_id` | string | No | — | Filter by space |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `memories` | array | Array of memory objects |
| `total` | number | Total matching memories |
| `has_more` | boolean | Whether more pages exist |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# List all memories
memories = nx.list_memories(limit=10)

# Filter by tag
preferences = nx.list_memories(tags="preferences", limit=5)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// List all memories
const memories = await nx.listMemories({ limit: 10 });

// Filter by tag
const preferences = await nx.listMemories({ tags: "preferences", limit: 5 });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# List all memories
curl https://novyx-ram-api.fly.dev/v1/memories?limit=10 \
  -H "Authorization: Bearer nram_your_key"

# Filter by tag
curl "https://novyx-ram-api.fly.dev/v1/memories?tags=preferences&limit=5" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "memories": [
    {
      "uuid": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "observation": "User prefers dark mode and compact layouts",
      "tags": ["preferences", "ui"],
      "importance": 8,
      "confidence": 1.0,
      "recall_count": 3,
      "created_at": "2026-03-09T12:00:00Z"
    }
  ],
  "total": 42,
  "has_more": true
}
```

---

## Get Memory

```
GET /v1/memories/{id}
```

Retrieve a single memory by ID with full metadata.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Memory ID (`urn:uuid:...`) |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `uuid` | string | Memory identifier |
| `observation` | string | Memory content |
| `tags` | string[] | Tags |
| `importance` | number | Importance score (1–10) |
| `confidence` | number | System confidence score |
| `recall_count` | number | Number of times recalled |
| `last_recalled_at` | string | Last recall timestamp |
| `superseded_by` | string \| null | ID of superseding memory |
| `created_at` | string | Creation timestamp |
| `updated_at` | string | Last update timestamp |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
memory = nx.get_memory("urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890")
print(memory["observation"])
print(memory["recall_count"])
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const memory = await nx.getMemory("urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890");
console.log(memory.observation);
console.log(memory.recall_count);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/memories/urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Memory does not exist or belongs to another tenant |

---

## Update Memory

```
PATCH /v1/memories/{id}
```

Partially update a memory. Only send the fields you want to change.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Memory ID |

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `observation` | string | No | Updated content |
| `importance` | number | No | Updated importance (1–10) |
| `tags` | string[] | No | Updated tags (replaces existing) |
| `superseded_by` | string | No | Mark as superseded by another memory |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `uuid` | string | Memory identifier |
| `observation` | string | Updated content |
| `updated_at` | string | Update timestamp |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
updated = nx.update_memory(
    "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    observation="User prefers dark mode, compact layouts, and monospace fonts",
    importance=9,
    tags=["preferences", "ui", "fonts"],
)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const updated = await nx.updateMemory(
  "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  {
    observation: "User prefers dark mode, compact layouts, and monospace fonts",
    importance: 9,
    tags: ["preferences", "ui", "fonts"],
  }
);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X PATCH https://novyx-ram-api.fly.dev/v1/memories/urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890 \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "observation": "User prefers dark mode, compact layouts, and monospace fonts",
    "importance": 9,
    "tags": ["preferences", "ui", "fonts"]
  }'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Invalid field value |
| 404 | `NOT_FOUND` | Memory does not exist |
| 409 | `CONFLICT` | Concurrent write conflict |

---

## Delete Memory

```
DELETE /v1/memories/{id}
```

Permanently delete a memory and its associated links.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Memory ID |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `deleted` | boolean | Whether the memory was deleted |
| `memory_id` | string | ID of deleted memory |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.delete_memory("urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890")
print(result["deleted"])  # True
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.deleteMemory("urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890");
console.log(result.deleted); // true
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X DELETE https://novyx-ram-api.fly.dev/v1/memories/urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Memory does not exist |

---

## Export Memories

```
GET /v1/memories/export
```

Export all memories as a structured file. Supports Markdown, JSON, and CSV formats.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `format` | string | No | `"md"` | Export format: `md`, `json`, or `csv` |
| `tags` | string | No | — | Comma-separated tag filter |
| `agent_id` | string | No | — | Filter by agent ID |

### Response

Returns a file download. Content-Type varies by format:

| Format | Content-Type |
|--------|-------------|
| `md` | `text/markdown` |
| `json` | `application/json` |
| `csv` | `text/csv` |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# Export as JSON
data = nx.export_memories(format="json")

# Export filtered by tag
preferences = nx.export_memories(format="csv", tags="preferences")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// Export as JSON
const data = await nx.exportMemories({ format: "json" });

// Export filtered by tag
const preferences = await nx.exportMemories({ format: "csv", tags: "preferences" });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# Export as JSON
curl "https://novyx-ram-api.fly.dev/v1/memories/export?format=json" \
  -H "Authorization: Bearer nram_your_key" \
  -o memories.json

# Export as CSV, filtered by tag
curl "https://novyx-ram-api.fly.dev/v1/memories/export?format=csv&tags=preferences" \
  -H "Authorization: Bearer nram_your_key" \
  -o preferences.csv
```

</TabItem>
</Tabs>

---

## Temporal Context

```
GET /v1/context/now
```

Get the current temporal context including recent memories, last session timestamp, and server time. Useful for session resumption.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `server_time_utc` | string | Current server time (ISO 8601) |
| `recent_memories` | array | Most recent memories |
| `recent_count` | number | Number of recent memories returned |
| `last_session_at` | string | Last session timestamp |
| `seconds_since_last_session` | number | Seconds since last activity |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
context = nx.context_now()
print(f"Last active: {context['seconds_since_last_session']}s ago")
print(f"Recent memories: {context['recent_count']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const context = await nx.contextNow();
console.log(`Last active: ${context.seconds_since_last_session}s ago`);
console.log(`Recent memories: ${context.recent_count}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/context/now \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "server_time_utc": "2026-03-09T15:30:00Z",
  "recent_memories": [
    {
      "uuid": "urn:uuid:a1b2c3d4-...",
      "observation": "User prefers dark mode",
      "created_at": "2026-03-09T12:00:00Z"
    }
  ],
  "recent_count": 1,
  "last_session_at": "2026-03-09T12:00:00Z",
  "seconds_since_last_session": 12600
}
```
