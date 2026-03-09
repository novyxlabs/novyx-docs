---
sidebar_position: 5
title: Spaces
description: Create isolated memory namespaces for multi-agent teams with cross-tenant sharing.
---

# Context Spaces

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Context Spaces let you organize memories into isolated namespaces. Each space acts as a container — agents can only access memories within spaces they're allowed into. Spaces support cross-tenant sharing for multi-team collaboration.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** All (sharing features require Pro+)

---

## Create Space

```
POST /v1/context-spaces
```

Create a new context space. You become the owner.

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | **Yes** | — | Space name (1–100 characters) |
| `description` | string | No | — | Space description (max 500 characters) |
| `allowed_agent_ids` | string[] | No | `[]` | Agent IDs that can access this space (max 10) |
| `allowed_tenant_ids` | string[] | No | `[]` | Other tenant IDs with access |
| `tags` | string[] | No | `[]` | Space tags |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `space_id` | string | Unique space identifier |
| `name` | string | Space name |
| `description` | string \| null | Space description |
| `owner_tenant_id` | string | Owner's tenant ID |
| `allowed_agent_ids` | string[] | Authorized agent IDs |
| `allowed_tenant_ids` | string[] | Authorized tenant IDs |
| `tags` | string[] | Space tags |
| `created_at` | string | ISO 8601 timestamp |
| `memory_count` | number | Number of memories in the space |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

space = nx.create_space(
    name="customer-support",
    description="Shared context for support agents",
    allowed_agent_ids=["agent-1", "agent-2"],
    tags=["support", "production"],
)
print(space["space_id"])
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const space = await nx.createSpace({
  name: "customer-support",
  description: "Shared context for support agents",
  allowedAgentIds: ["agent-1", "agent-2"],
  tags: ["support", "production"],
});
console.log(space.space_id);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/context-spaces \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "customer-support",
    "description": "Shared context for support agents",
    "allowed_agent_ids": ["agent-1", "agent-2"],
    "tags": ["support", "production"]
  }'
```

</TabItem>
</Tabs>

### Response

```json
{
  "space_id": "urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890",
  "name": "customer-support",
  "description": "Shared context for support agents",
  "owner_tenant_id": "tenant_abc123",
  "allowed_agent_ids": ["agent-1", "agent-2"],
  "allowed_tenant_ids": [],
  "tags": ["support", "production"],
  "created_at": "2026-03-09T12:00:00Z",
  "memory_count": 0
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Name too long or too many agent IDs |
| 401 | `UNAUTHORIZED` | Invalid or missing API key |

---

## List Spaces

```
GET /v1/context-spaces
```

List all spaces you own or have been granted access to.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `spaces` | array | Array of space objects |
| `total_count` | number | Total spaces accessible |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.list_spaces()
for space in result["spaces"]:
    print(f"{space['name']}: {space['memory_count']} memories")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.listSpaces();
for (const space of result.spaces) {
  console.log(`${space.name}: ${space.memory_count} memories`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/context-spaces \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "spaces": [
    {
      "space_id": "urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890",
      "name": "customer-support",
      "description": "Shared context for support agents",
      "owner_tenant_id": "tenant_abc123",
      "allowed_agent_ids": ["agent-1", "agent-2"],
      "allowed_tenant_ids": [],
      "tags": ["support", "production"],
      "created_at": "2026-03-09T12:00:00Z",
      "memory_count": 42
    }
  ],
  "total_count": 1
}
```

---

## Get Space

```
GET /v1/context-spaces/{space_id}
```

Retrieve a single space by ID. Cross-tenant access is audit-logged.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `space_id` | string | Space identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
space = nx.get_space("urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890")
print(space["name"])
print(space["memory_count"])
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const space = await nx.getSpace("urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890");
console.log(space.name);
console.log(space.memory_count);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/context-spaces/urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FORBIDDEN` | You don't have access to this space |
| 404 | `NOT_FOUND` | Space does not exist |

---

## Update Space

```
PUT /v1/context-spaces/{space_id}
```

Update a space. Owner only. Send only the fields you want to change.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `space_id` | string | Space identifier |

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | No | Updated name (1–100 characters) |
| `description` | string | No | Updated description (max 500 characters) |
| `allowed_agent_ids` | string[] | No | Updated agent access list |
| `allowed_tenant_ids` | string[] | No | Updated tenant access list |
| `tags` | string[] | No | Updated tags |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
updated = nx.update_space(
    "urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890",
    name="customer-support-v2",
    allowed_agent_ids=["agent-1", "agent-2", "agent-3"],
)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const updated = await nx.updateSpace(
  "urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890",
  {
    name: "customer-support-v2",
    allowedAgentIds: ["agent-1", "agent-2", "agent-3"],
  }
);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X PUT https://novyx-ram-api.fly.dev/v1/context-spaces/urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890 \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "customer-support-v2",
    "allowed_agent_ids": ["agent-1", "agent-2", "agent-3"]
  }'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Invalid field value |
| 403 | `OWNER_ONLY` | Only the space owner can update |
| 404 | `NOT_FOUND` | Space does not exist |

---

## Delete Space

```
DELETE /v1/context-spaces/{space_id}
```

Soft-delete a space. Owner only. Memories in the space are not deleted.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `space_id` | string | Space identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
nx.delete_space("urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
await nx.deleteSpace("urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890");
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X DELETE https://novyx-ram-api.fly.dev/v1/context-spaces/urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

Returns `204 No Content` on success.

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `OWNER_ONLY` | Only the space owner can delete |
| 404 | `NOT_FOUND` | Space does not exist |

---

## List Space Memories

```
GET /v1/context-spaces/{space_id}/memories
```

List memories scoped to a specific space, with optional search and filters. Cross-tenant access is audit-logged.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `space_id` | string | Space identifier |

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `q` | string | No | — | Search query (semantic/text) |
| `tags` | string | No | — | Comma-separated tag filter |
| `agent_id` | string | No | — | Filter by agent ID |
| `limit` | number | No | `100` | Max results (1–1000) |
| `offset` | number | No | `0` | Pagination offset |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `memories` | array | Array of memory objects |
| `total_count` | number | Total matching memories |
| `filters` | object | Echo of applied filters (includes `space_id`) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# List all memories in a space
result = nx.space_memories("urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890")

# Search within a space
result = nx.space_memories(
    "urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890",
    q="dark mode",
    tags="preferences",
    limit=10,
)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// List all memories in a space
const result = await nx.spaceMemories("urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890");

// Search within a space
const result = await nx.spaceMemories(
  "urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890",
  { q: "dark mode", tags: "preferences", limit: 10 }
);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# List all memories in a space
curl "https://novyx-ram-api.fly.dev/v1/context-spaces/urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890/memories" \
  -H "Authorization: Bearer nram_your_key"

# Search within a space
curl "https://novyx-ram-api.fly.dev/v1/context-spaces/urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890/memories?q=dark+mode&tags=preferences&limit=10" \
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
  "total_count": 42,
  "filters": {
    "space_id": "urn:uuid:s1a2b3c4-d5e6-7890-abcd-ef1234567890",
    "q": null,
    "tags": null,
    "agent_id": null
  }
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FORBIDDEN` | You don't have access to this space |
| 404 | `NOT_FOUND` | Space does not exist |
