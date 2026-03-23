---
sidebar_position: 7
title: "Novyx API: Knowledge Graph — 7 Endpoints for Entity Relations"
description: "Store structured relationships as triples. Query entity connections, traverse graphs, and build agent knowledge bases."
---

# Knowledge Graph

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

The Knowledge Graph router lets you create structured relationships between entities using subject-predicate-object triples. Entities are auto-created when referenced in a triple.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** Pro+

**Backend:** Requires Postgres

---

## Create Triple

```
POST /v1/knowledge/triples
```

Create a relationship between two entities. Entity names are auto-normalized to lowercase. If the subject or object entity doesn't exist yet, it's created automatically.

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `subject` | string | **Yes** | — | Subject entity name |
| `predicate` | string | **Yes** | — | Relationship type (e.g., `prefers`, `works_at`) |
| `object` | string | **Yes** | — | Object entity name |
| `confidence` | number | No | `1.0` | Confidence score (0.0–1.0) |
| `source_memory_id` | string | No | — | UUID linking this triple to a source memory |
| `subject_type` | string | No | — | Entity type for auto-created subject |
| `object_type` | string | No | — | Entity type for auto-created object |
| `metadata` | object | No | — | Custom metadata |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `triple_id` | string | Unique triple identifier |
| `subject` | object | Full subject entity (id, name, type) |
| `predicate` | string | Relationship type |
| `object` | object | Full object entity (id, name, type) |
| `confidence` | number | Confidence score |
| `source_memory_id` | string \| null | Linked source memory |
| `metadata` | object | Custom metadata |
| `created_at` | string | ISO 8601 timestamp |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

triple = nx.add_triple(
    subject="alice",
    predicate="works_at",
    object="novyx",
    confidence=0.95,
    subject_type="person",
    object_type="company",
)
print(triple["triple_id"])
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const triple = await nx.addTriple({
  subject: "alice",
  predicate: "works_at",
  object: "novyx",
  confidence: 0.95,
  subjectType: "person",
  objectType: "company",
});
console.log(triple.triple_id);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/knowledge/triples \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "alice",
    "predicate": "works_at",
    "object": "novyx",
    "confidence": 0.95,
    "subject_type": "person",
    "object_type": "company"
  }'
```

</TabItem>
</Tabs>

### Response

```json
{
  "triple_id": "urn:uuid:t1a2b3c4-d5e6-7890-abcd-ef1234567890",
  "subject": {
    "entity_id": "urn:uuid:e1a2b3c4-0001-0000-0000-000000000001",
    "name": "alice",
    "entity_type": "person"
  },
  "predicate": "works_at",
  "object": {
    "entity_id": "urn:uuid:e1a2b3c4-0001-0000-0000-000000000002",
    "name": "novyx",
    "entity_type": "company"
  },
  "confidence": 0.95,
  "source_memory_id": null,
  "metadata": {},
  "created_at": "2026-03-09T12:00:00Z"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |
| 404 | `NOT_FOUND` | `source_memory_id` does not exist |
| 501 | `REQUIRES_POSTGRES` | Postgres backend required |

---

## Query Triples

```
GET /v1/knowledge/triples
```

List triples with optional filters. Results are sorted by creation date (newest first).

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `subject` | string | No | — | Filter by subject entity name |
| `predicate` | string | No | — | Filter by predicate |
| `object` | string | No | — | Filter by object entity name |
| `source_memory_id` | string | No | — | Filter by linked source memory |
| `limit` | number | No | `50` | Max results (1–500) |
| `offset` | number | No | `0` | Pagination offset |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `triples` | array | Array of triple objects |
| `total` | number | Total matching triples |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# All triples for a subject
triples = nx.query_triples(subject="alice")

# Filter by predicate
works = nx.query_triples(predicate="works_at", limit=10)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// All triples for a subject
const triples = await nx.queryTriples({ subject: "alice" });

// Filter by predicate
const works = await nx.queryTriples({ predicate: "works_at", limit: 10 });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# All triples for a subject
curl "https://novyx-ram-api.fly.dev/v1/knowledge/triples?subject=alice" \
  -H "Authorization: Bearer nram_your_key"

# Filter by predicate
curl "https://novyx-ram-api.fly.dev/v1/knowledge/triples?predicate=works_at&limit=10" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "triples": [
    {
      "triple_id": "urn:uuid:t1a2b3c4-d5e6-7890-abcd-ef1234567890",
      "subject": {
        "entity_id": "urn:uuid:e1a2b3c4-0001-0000-0000-000000000001",
        "name": "alice",
        "entity_type": "person"
      },
      "predicate": "works_at",
      "object": {
        "entity_id": "urn:uuid:e1a2b3c4-0001-0000-0000-000000000002",
        "name": "novyx",
        "entity_type": "company"
      },
      "confidence": 0.95,
      "source_memory_id": null,
      "metadata": {},
      "created_at": "2026-03-09T12:00:00Z"
    }
  ],
  "total": 1
}
```

---

## Get Triple

```
GET /v1/knowledge/triples/{triple_id}
```

Retrieve a single triple by ID.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `triple_id` | string | Triple identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
triple = nx.get_triple("urn:uuid:t1a2b3c4-d5e6-7890-abcd-ef1234567890")
print(f"{triple['subject']['name']} → {triple['predicate']} → {triple['object']['name']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const triple = await nx.getTriple("urn:uuid:t1a2b3c4-d5e6-7890-abcd-ef1234567890");
console.log(`${triple.subject.name} → ${triple.predicate} → ${triple.object.name}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/knowledge/triples/urn:uuid:t1a2b3c4-d5e6-7890-abcd-ef1234567890 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Triple does not exist |

---

## Delete Triple

```
DELETE /v1/knowledge/triples/{triple_id}
```

Delete a triple. Does not delete the associated entities.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `triple_id` | string | Triple identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.delete_triple("urn:uuid:t1a2b3c4-d5e6-7890-abcd-ef1234567890")
print(result["deleted"])  # True
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.deleteTriple("urn:uuid:t1a2b3c4-d5e6-7890-abcd-ef1234567890");
console.log(result.deleted); // true
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X DELETE https://novyx-ram-api.fly.dev/v1/knowledge/triples/urn:uuid:t1a2b3c4-d5e6-7890-abcd-ef1234567890 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "deleted": true
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Triple does not exist |

---

## List Entities

```
GET /v1/knowledge/entities
```

List all entities in the knowledge graph with optional filters.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `entity_type` | string | No | — | Filter by entity type |
| `q` | string | No | — | Name prefix search (case-insensitive) |
| `limit` | number | No | `50` | Max results (1–500) |
| `offset` | number | No | `0` | Pagination offset |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `entities` | array | Array of entity objects |
| `total` | number | Total matching entities |

Each entity includes:

| Field | Type | Description |
|-------|------|-------------|
| `entity_id` | string | Unique entity identifier |
| `name` | string | Entity name (lowercase) |
| `entity_type` | string | Entity type |
| `metadata` | object | Custom metadata |
| `created_at` | string | ISO 8601 timestamp |
| `triple_count` | number | Number of triples referencing this entity |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# List all entities
entities = nx.list_entities()

# Filter by type
people = nx.list_entities(entity_type="person")

# Search by name prefix
results = nx.list_entities(q="ali")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// List all entities
const entities = await nx.listEntities();

// Filter by type
const people = await nx.listEntities({ entityType: "person" });

// Search by name prefix
const results = await nx.listEntities({ q: "ali" });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# List all entities
curl https://novyx-ram-api.fly.dev/v1/knowledge/entities \
  -H "Authorization: Bearer nram_your_key"

# Filter by type
curl "https://novyx-ram-api.fly.dev/v1/knowledge/entities?entity_type=person" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "entities": [
    {
      "entity_id": "urn:uuid:e1a2b3c4-0001-0000-0000-000000000001",
      "name": "alice",
      "entity_type": "person",
      "metadata": {},
      "created_at": "2026-03-09T12:00:00Z",
      "triple_count": 3
    }
  ],
  "total": 1
}
```

---

## Entity Traversal

```
GET /v1/knowledge/entities/{entity_id}
```

Get an entity with all its connections — triples where it appears as subject or object.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity_id` | string | Entity identifier |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `entity` | object | Full entity details |
| `as_subject` | array | Triples where this entity is the subject |
| `as_object` | array | Triples where this entity is the object |
| `total_connections` | number | Total triples in both directions |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
traversal = nx.get_entity("urn:uuid:e1a2b3c4-0001-0000-0000-000000000001")
print(f"{traversal['entity']['name']} has {traversal['total_connections']} connections")

for t in traversal["as_subject"]:
    print(f"  → {t['predicate']} → {t['object']['name']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const traversal = await nx.getEntity("urn:uuid:e1a2b3c4-0001-0000-0000-000000000001");
console.log(`${traversal.entity.name} has ${traversal.total_connections} connections`);

for (const t of traversal.as_subject) {
  console.log(`  → ${t.predicate} → ${t.object.name}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/knowledge/entities/urn:uuid:e1a2b3c4-0001-0000-0000-000000000001 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "entity": {
    "entity_id": "urn:uuid:e1a2b3c4-0001-0000-0000-000000000001",
    "name": "alice",
    "entity_type": "person",
    "metadata": {},
    "created_at": "2026-03-09T12:00:00Z"
  },
  "as_subject": [
    {
      "triple_id": "urn:uuid:t1a2b3c4-d5e6-7890-abcd-ef1234567890",
      "predicate": "works_at",
      "object": {
        "entity_id": "urn:uuid:e1a2b3c4-0001-0000-0000-000000000002",
        "name": "novyx",
        "entity_type": "company"
      },
      "confidence": 0.95,
      "created_at": "2026-03-09T12:00:00Z"
    }
  ],
  "as_object": [],
  "total_connections": 1
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Entity does not exist |

---

## Delete Entity

```
DELETE /v1/knowledge/entities/{entity_id}
```

Delete an entity and cascade-delete all triples that reference it.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity_id` | string | Entity identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.delete_entity("urn:uuid:e1a2b3c4-0001-0000-0000-000000000001")
print(f"Deleted, removed {result['triples_removed']} triples")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.deleteEntity("urn:uuid:e1a2b3c4-0001-0000-0000-000000000001");
console.log(`Deleted, removed ${result.triples_removed} triples`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X DELETE https://novyx-ram-api.fly.dev/v1/knowledge/entities/urn:uuid:e1a2b3c4-0001-0000-0000-000000000001 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "deleted": true,
  "triples_removed": 3
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Entity does not exist |
