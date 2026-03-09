---
sidebar_position: 8
title: Replay
description: Time-travel debugging — timeline, point-in-time snapshots, diffs, and memory lifecycle tracking.
---

# Replay

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

The Replay router provides time-travel debugging for your memory store. Browse the full timeline of operations, reconstruct state at any point in time, diff between timestamps, and track the complete lifecycle of individual memories.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** Pro+ (Counterfactual Recall and Drift require Enterprise)

**Backend:** Requires Postgres

---

## Timeline

```
GET /v1/replay/timeline
```

Get a chronological feed of all memory operations — creates, updates, deletes, and rollbacks.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `since` | string | No | — | Start of time range (ISO 8601) |
| `until` | string | No | — | End of time range (ISO 8601) |
| `operations` | string | No | — | Comma-separated filter: `create`, `update`, `delete`, `rollback` |
| `agent_id` | string | No | — | Filter by agent ID |
| `limit` | number | No | `100` | Max results (1–1000) |
| `offset` | number | No | `0` | Pagination offset |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `entries` | array | Array of timeline entries |
| `total_count` | number | Total matching entries |
| `has_more` | boolean | Whether more pages exist |
| `period_start` | string | Start of returned period (ISO 8601) |
| `period_end` | string | End of returned period (ISO 8601) |

Each timeline entry includes:

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | string | ISO 8601 timestamp |
| `operation` | string | Operation type: `create`, `update`, `delete`, `rollback` |
| `memory_id` | string | Affected memory ID |
| `observation_preview` | string | Truncated observation text |
| `agent_id` | string \| null | Agent that performed the operation |
| `importance` | number | Memory importance score |
| `content_hash` | string | SHA-256 content hash |
| `metadata` | object | Operation metadata |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

# Get recent timeline
timeline = nx.replay_timeline(limit=20)
for entry in timeline["entries"]:
    print(f"{entry['timestamp']} {entry['operation']} {entry['observation_preview']}")

# Filter by operation type and time range
creates = nx.replay_timeline(
    since="2026-03-01T00:00:00Z",
    until="2026-03-09T00:00:00Z",
    operations="create,update",
)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

// Get recent timeline
const timeline = await nx.replayTimeline({ limit: 20 });
for (const entry of timeline.entries) {
  console.log(`${entry.timestamp} ${entry.operation} ${entry.observation_preview}`);
}

// Filter by operation type and time range
const creates = await nx.replayTimeline({
  since: "2026-03-01T00:00:00Z",
  until: "2026-03-09T00:00:00Z",
  operations: "create,update",
});
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# Get recent timeline
curl "https://novyx-ram-api.fly.dev/v1/replay/timeline?limit=20" \
  -H "Authorization: Bearer nram_your_key"

# Filter by operation type
curl "https://novyx-ram-api.fly.dev/v1/replay/timeline?operations=create,update&since=2026-03-01T00:00:00Z" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "entries": [
    {
      "timestamp": "2026-03-09T14:30:00Z",
      "operation": "create",
      "memory_id": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "observation_preview": "User prefers dark mode and compact...",
      "agent_id": "agent-1",
      "importance": 8,
      "content_hash": "e3b0c44298fc1c149afbf4c8996fb924...",
      "metadata": {}
    }
  ],
  "total_count": 156,
  "has_more": true,
  "period_start": "2026-03-01T00:00:00Z",
  "period_end": "2026-03-09T14:30:00Z"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |
| 501 | `REQUIRES_POSTGRES` | Postgres backend required |

---

## Snapshot

```
GET /v1/replay/snapshot
```

Reconstruct the complete state of your memory store at any point in time — including all memories and graph edges that existed at that moment.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `at` | string | **Yes** | — | Point in time to reconstruct (ISO 8601) |
| `limit` | number | No | `500` | Max memories (1–5000) |
| `offset` | number | No | `0` | Pagination offset |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `snapshot_at` | string | Requested timestamp (ISO 8601) |
| `total_memories` | number | Total memories at that time |
| `memories` | array | Array of memory snapshots |
| `edges` | array | Array of graph edges at that time |
| `total_edges` | number | Total edge count |

Each memory snapshot includes:

| Field | Type | Description |
|-------|------|-------------|
| `uuid` | string | Memory identifier |
| `observation` | string | Memory content |
| `context` | string \| null | Context metadata |
| `agent_id` | string \| null | Agent identifier |
| `tags` | string[] | Tags |
| `importance` | number | Importance score |
| `confidence` | number | Confidence score |
| `created_at` | string | Creation timestamp |
| `space_id` | string \| null | Space identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# See what your memory store looked like yesterday
snapshot = nx.replay_snapshot(at="2026-03-08T12:00:00Z")
print(f"{snapshot['total_memories']} memories at that time")

for mem in snapshot["memories"]:
    print(f"  {mem['observation'][:60]}...")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// See what your memory store looked like yesterday
const snapshot = await nx.replaySnapshot({ at: "2026-03-08T12:00:00Z" });
console.log(`${snapshot.total_memories} memories at that time`);

for (const mem of snapshot.memories) {
  console.log(`  ${mem.observation.slice(0, 60)}...`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/replay/snapshot?at=2026-03-08T12:00:00Z" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "snapshot_at": "2026-03-08T12:00:00Z",
  "total_memories": 87,
  "memories": [
    {
      "uuid": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "observation": "User prefers dark mode and compact layouts",
      "context": null,
      "agent_id": "agent-1",
      "tags": ["preferences", "ui"],
      "importance": 8,
      "confidence": 1.0,
      "created_at": "2026-03-07T10:00:00Z",
      "space_id": null
    }
  ],
  "edges": [
    {
      "edge_id": "urn:uuid:ed1a2b3c-0000-0000-0000-000000000001",
      "source_id": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "target_id": "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "relation": "similar",
      "weight": 0.92
    }
  ],
  "total_edges": 12
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |
| 501 | `REQUIRES_POSTGRES` | Postgres backend required |

---

## Diff

```
GET /v1/replay/diff
```

Compare your memory store between two points in time. Shows what was added, removed, and modified.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `from` | string | **Yes** | — | Start timestamp (ISO 8601) |
| `to` | string | **Yes** | — | End timestamp (ISO 8601) |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `from_timestamp` | string | Start of diff range |
| `to_timestamp` | string | End of diff range |
| `added` | array | Memories created in this period |
| `removed` | array | Memories deleted in this period |
| `modified` | array | Memories updated in this period |
| `summary` | object | Counts: `{ added, removed, modified }` |

Each diff entry includes:

| Field | Type | Description |
|-------|------|-------------|
| `memory_id` | string | Memory identifier |
| `change_type` | string | `added`, `removed`, or `modified` |
| `observation_preview` | string | Truncated observation text |
| `importance` | number | Importance score |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# What changed in the last 24 hours?
diff = nx.replay_diff(
    from_ts="2026-03-08T12:00:00Z",
    to="2026-03-09T12:00:00Z",
)
print(f"Added: {diff['summary']['added']}")
print(f"Removed: {diff['summary']['removed']}")
print(f"Modified: {diff['summary']['modified']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// What changed in the last 24 hours?
const diff = await nx.replayDiff({
  from: "2026-03-08T12:00:00Z",
  to: "2026-03-09T12:00:00Z",
});
console.log(`Added: ${diff.summary.added}`);
console.log(`Removed: ${diff.summary.removed}`);
console.log(`Modified: ${diff.summary.modified}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/replay/diff?from=2026-03-08T12:00:00Z&to=2026-03-09T12:00:00Z" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "from_timestamp": "2026-03-08T12:00:00Z",
  "to_timestamp": "2026-03-09T12:00:00Z",
  "added": [
    {
      "memory_id": "urn:uuid:c3d4e5f6-a7b8-9012-cdef-123456789012",
      "change_type": "added",
      "observation_preview": "New deployment config uses blue-green...",
      "importance": 7
    }
  ],
  "removed": [],
  "modified": [
    {
      "memory_id": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "change_type": "modified",
      "observation_preview": "User prefers dark mode and compact...",
      "importance": 9
    }
  ],
  "summary": {
    "added": 1,
    "removed": 0,
    "modified": 1
  }
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |
| 422 | `INVALID_RANGE` | `from` must be before `to` |
| 501 | `REQUIRES_POSTGRES` | Postgres backend required |

---

## Memory Lifecycle

```
GET /v1/replay/memory/{memory_id}
```

Track the complete lifecycle of a single memory — from creation through updates, recalls, links, and deletion.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `memory_id` | string | Memory identifier |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `memory_id` | string | Memory identifier |
| `observation` | string | Original memory content |
| `created_at` | string | Creation timestamp |
| `current_state` | string | Current observation (if modified) |
| `events` | array | Chronological list of lifecycle events |
| `versions` | array | Version history |
| `links` | array | Graph edges to/from this memory |
| `recall_count` | number | Number of times recalled |
| `last_recalled_at` | string \| null | Last recall timestamp |

Each lifecycle event includes:

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | string | Event timestamp |
| `event_type` | string | `create`, `update`, `delete`, `recall`, `link` |
| `detail` | object | Event-specific details |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
lifecycle = nx.replay_lifecycle("urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890")
print(f"Created: {lifecycle['created_at']}")
print(f"Recalled {lifecycle['recall_count']} times")

for event in lifecycle["events"]:
    print(f"  {event['timestamp']} — {event['event_type']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const lifecycle = await nx.replayLifecycle("urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890");
console.log(`Created: ${lifecycle.created_at}`);
console.log(`Recalled ${lifecycle.recall_count} times`);

for (const event of lifecycle.events) {
  console.log(`  ${event.timestamp} — ${event.event_type}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/replay/memory/urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "memory_id": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "observation": "User prefers dark mode and compact layouts",
  "created_at": "2026-03-07T10:00:00Z",
  "current_state": "User prefers dark mode, compact layouts, and monospace fonts",
  "events": [
    {
      "timestamp": "2026-03-07T10:00:00Z",
      "event_type": "create",
      "detail": { "importance": 8 }
    },
    {
      "timestamp": "2026-03-08T09:15:00Z",
      "event_type": "recall",
      "detail": { "query": "user preferences" }
    },
    {
      "timestamp": "2026-03-09T11:00:00Z",
      "event_type": "update",
      "detail": { "fields": ["observation", "importance"] }
    }
  ],
  "versions": [
    {
      "observation": "User prefers dark mode and compact layouts",
      "importance": 8,
      "timestamp": "2026-03-07T10:00:00Z"
    },
    {
      "observation": "User prefers dark mode, compact layouts, and monospace fonts",
      "importance": 9,
      "timestamp": "2026-03-09T11:00:00Z"
    }
  ],
  "links": [
    {
      "edge_id": "urn:uuid:ed1a2b3c-0000-0000-0000-000000000001",
      "source_id": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "target_id": "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "relation": "similar",
      "weight": 0.92
    }
  ],
  "recall_count": 3,
  "last_recalled_at": "2026-03-09T14:00:00Z"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |
| 404 | `NOT_FOUND` | Memory does not exist |
| 501 | `REQUIRES_POSTGRES` | Postgres backend required |
