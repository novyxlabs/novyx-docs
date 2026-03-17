---
sidebar_position: 15
title: Drafts & Branches
description: Reviewable memory drafts and branch-based merge workflows for safe memory updates.
---

# Drafts & Branches

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

The Drafts router provides a merge-before-persist workflow for memory changes. Instead of writing directly to canonical memory, agents create drafts that can be reviewed, diffed against existing memories, and then merged or rejected. Drafts can be grouped into branches for batch review.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** All tiers. Plan limits apply to open drafts and active branches.

**Plan limits:** Vary by tier (open draft count and active branch count are capped per plan).

---

## Create Draft

```
POST /v1/memory-drafts
```

Create a reviewable memory draft without mutating canonical memory. The draft is compared against existing memories to find similar entries and generate a review summary.

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `observation` | string | **Yes** | — | Memory content |
| `context` | string | No | — | Additional context |
| `context_ids` | string[] | No | `[]` | Linked context IDs |
| `agent_id` | string | No | — | Agent identifier |
| `tags` | string[] | No | `[]` | Tags for categorization |
| `importance` | number | No | `5` | Importance score (1-10) |
| `confidence` | number | No | `1.0` | Confidence score (0-1) |
| `space_id` | string | No | — | Context space to store into |
| `branch_id` | string | No | — | Branch/session identifier for grouping drafts |
| `ttl_seconds` | number | No | — | Time-to-live in seconds (sets expiry on merge) |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `draft_id` | string | Draft identifier |
| `branch_id` | string \| null | Branch this draft belongs to |
| `status` | string | `draft`, `merged`, or `rejected` |
| `created_at` | string | ISO 8601 timestamp |
| `updated_at` | string | ISO 8601 timestamp |
| `observation` | string | Memory content |
| `context` | string \| null | Additional context |
| `agent_id` | string \| null | Agent identifier |
| `tags` | string[] | Tags |
| `importance` | number | Importance score |
| `confidence` | number | Confidence score |
| `space_id` | string \| null | Context space |
| `review_summary` | object | Review summary with proposed changes, similar memory count, and matches |
| `merged_memory_id` | string \| null | ID of created memory (after merge) |
| `merged_at` | string \| null | Merge timestamp |
| `rejected_at` | string \| null | Rejection timestamp |
| `rejection_reason` | string \| null | Reason for rejection |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

draft = nx.draft_memory(
    observation="User prefers dark mode with compact layouts",
    tags=["preferences", "ui"],
    importance=7,
    branch_id="session-2026-03-15"
)
print(f"Draft ID: {draft['draft_id']}")
print(f"Similar memories: {draft['review_summary']['similar_count']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const draft = await nx.draftMemory({
  observation: "User prefers dark mode with compact layouts",
  tags: ["preferences", "ui"],
  importance: 7,
  branchId: "session-2026-03-15",
});
console.log(`Draft ID: ${draft.draft_id}`);
console.log(`Similar: ${draft.review_summary.similar_count}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/memory-drafts \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "observation": "User prefers dark mode with compact layouts",
    "tags": ["preferences", "ui"],
    "importance": 7,
    "branch_id": "session-2026-03-15"
  }'
```

</TabItem>
</Tabs>

### Response

```json
{
  "draft_id": "draft_a1b2c3d4",
  "branch_id": "session-2026-03-15",
  "status": "draft",
  "created_at": "2026-03-15T14:00:00Z",
  "updated_at": "2026-03-15T14:00:00Z",
  "observation": "User prefers dark mode with compact layouts",
  "context": null,
  "agent_id": null,
  "tags": ["preferences", "ui"],
  "importance": 7,
  "confidence": 1.0,
  "space_id": null,
  "review_summary": {
    "proposed_changes": ["observation", "tags", "importance"],
    "similar_count": 1,
    "similar_memories": [
      {
        "uuid": "mem_xyz789",
        "observation": "User likes dark mode",
        "similarity": 0.87
      }
    ]
  },
  "merged_memory_id": null,
  "merged_at": null,
  "rejected_at": null,
  "rejection_reason": null
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `draft_limit_reached` | Open draft limit exceeded for your plan |
| 403 | `branch_limit_reached` | Active branch limit exceeded for your plan |

---

## List Drafts

```
GET /v1/memory-drafts
```

List memory drafts for the current tenant, optionally filtered by status or branch.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `status` | string | No | — | Filter by status: `draft`, `merged`, or `rejected` |
| `branch_id` | string | No | — | Filter by branch/session identifier |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `total_count` | number | Total drafts matching the filter |
| `drafts` | array | Array of draft objects (same structure as Create Draft response) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
drafts = nx.memory_drafts(status="draft")
print(f"Open drafts: {drafts['total_count']}")
for d in drafts["drafts"]:
    print(f"  {d['draft_id']}: {d['observation'][:50]}...")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const drafts = await nx.memoryDrafts({ status: "draft" });
console.log(`Open drafts: ${drafts.total_count}`);
for (const d of drafts.drafts) {
  console.log(`  ${d.draft_id}: ${d.observation.slice(0, 50)}...`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/memory-drafts?status=draft" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

---

## Get Draft

```
GET /v1/memory-drafts/{draft_id}
```

Fetch a single memory draft by ID.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `draft_id` | string | Draft identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
draft = nx.get_draft("draft_a1b2c3d4")
print(f"Status: {draft['status']}")
print(f"Observation: {draft['observation']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const draft = await nx.getDraft("draft_a1b2c3d4");
console.log(`Status: ${draft.status}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/memory-drafts/draft_a1b2c3d4 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `drafts.not_found` | Draft does not exist |

---

## Draft Diff

```
GET /v1/memory-drafts/{draft_id}/diff
```

Show a field-level diff between a draft and an existing memory. If no comparison target is specified, the closest matching memory is used automatically.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `draft_id` | string | Draft identifier |

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `compare_to` | string | No | — | Existing memory UUID to compare against |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `draft_id` | string | Draft identifier |
| `compared_memory_id` | string \| null | Memory being compared against |
| `comparison_basis` | string | `explicit`, `closest_match`, or `none` |
| `recommendation` | string | `merge_new`, `merge_or_supersede`, `merge_update`, or `check_duplicate` |
| `changed_fields` | array | Field-level diff for each comparable field |
| `current_memory` | object \| null | The existing memory (if comparing) |
| `proposed_memory` | object | The draft as a memory object |

Each changed field includes:

| Field | Type | Description |
|-------|------|-------------|
| `field` | string | Field name |
| `current` | any | Current value in existing memory |
| `proposed` | any | Proposed value in draft |
| `changed` | boolean | Whether the field differs |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
diff = nx.draft_diff("draft_a1b2c3d4")
print(f"Recommendation: {diff['recommendation']}")
for field in diff["changed_fields"]:
    if field["changed"]:
        print(f"  {field['field']}: {field['current']} -> {field['proposed']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const diff = await nx.draftDiff("draft_a1b2c3d4");
console.log(`Recommendation: ${diff.recommendation}`);
for (const field of diff.changed_fields) {
  if (field.changed) {
    console.log(`  ${field.field}: ${field.current} -> ${field.proposed}`);
  }
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/memory-drafts/draft_a1b2c3d4/diff" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "draft_id": "draft_a1b2c3d4",
  "compared_memory_id": "mem_xyz789",
  "comparison_basis": "closest_match",
  "recommendation": "merge_or_supersede",
  "changed_fields": [
    {"field": "observation", "current": "User likes dark mode", "proposed": "User prefers dark mode with compact layouts", "changed": true},
    {"field": "importance", "current": 5, "proposed": 7, "changed": true},
    {"field": "tags", "current": ["preferences"], "proposed": ["preferences", "ui"], "changed": true}
  ],
  "current_memory": {
    "uuid": "mem_xyz789",
    "observation": "User likes dark mode"
  },
  "proposed_memory": {
    "uuid": "draft_a1b2c3d4",
    "observation": "User prefers dark mode with compact layouts"
  }
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `drafts.not_found` | Draft does not exist |
| 404 | `memories.not_found` | Comparison memory not found |

---

## Merge Draft

```
POST /v1/memory-drafts/{draft_id}/merge
```

Merge a reviewed draft into canonical memory. Optionally supersede an existing memory in the same operation.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `draft_id` | string | Draft identifier |

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `supersede_memory_id` | string | No | — | Existing memory to supersede on merge |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `draft_id` | string | Draft identifier |
| `status` | string | `merged` |
| `memory_id` | string | ID of the created canonical memory |
| `hash` | string | Integrity hash of the new memory |
| `created_at` | string | ISO 8601 timestamp |
| `message` | string | Confirmation message |
| `superseded_memory_id` | string \| null | ID of the superseded memory (if applicable) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.merge_draft("draft_a1b2c3d4")
print(f"Merged! Memory ID: {result['memory_id']}")

# Merge and supersede an existing memory
result = nx.merge_draft(
    "draft_a1b2c3d4",
    supersede_memory_id="mem_xyz789"
)
print(f"Superseded: {result['superseded_memory_id']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.mergeDraft("draft_a1b2c3d4");
console.log(`Merged! Memory ID: ${result.memory_id}`);

// Merge and supersede
const result2 = await nx.mergeDraft("draft_a1b2c3d4", {
  supersedeMemoryId: "mem_xyz789",
});
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/memory-drafts/draft_a1b2c3d4/merge \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"supersede_memory_id": "mem_xyz789"}'
```

</TabItem>
</Tabs>

### Response

```json
{
  "draft_id": "draft_a1b2c3d4",
  "status": "merged",
  "memory_id": "mem_new456",
  "hash": "sha256:abc123...",
  "created_at": "2026-03-15T14:05:00Z",
  "message": "Draft merged into canonical memory",
  "superseded_memory_id": "mem_xyz789"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `drafts.not_found` | Draft does not exist |
| 404 | `memories.not_found` | Superseding target not found |
| 409 | `drafts.invalid_state` | Draft is not in `draft` status (already merged or rejected) |
| 403 | `memory_limit_reached` | Memory limit for your plan reached |

---

## Reject Draft

```
POST /v1/memory-drafts/{draft_id}/reject
```

Reject a draft without mutating canonical memory.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `draft_id` | string | Draft identifier |

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `reason` | string | No | — | Reason for rejection |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.reject_draft("draft_a1b2c3d4", reason="Duplicate of existing memory")
print(f"Status: {result['status']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.rejectDraft("draft_a1b2c3d4", {
  reason: "Duplicate of existing memory",
});
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/memory-drafts/draft_a1b2c3d4/reject \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Duplicate of existing memory"}'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `drafts.not_found` | Draft does not exist |
| 409 | `drafts.invalid_state` | Draft is not in `draft` status |

---

## Get Branch

```
GET /v1/memory-branches/{branch_id}
```

Get grouped review information for a branch/session of drafts, including draft counts by status and merge recommendations.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `branch_id` | string | Branch/session identifier |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `branch_id` | string | Branch identifier |
| `total_drafts` | number | Total drafts in this branch |
| `open_drafts` | number | Drafts still in `draft` status |
| `merged_drafts` | number | Merged drafts |
| `rejected_drafts` | number | Rejected drafts |
| `recommendations` | object | Recommendation counts (e.g., `{"merge_new": 2, "check_duplicate": 1}`) |
| `drafts` | array | All draft objects in this branch |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
branch = nx.memory_branch("session-2026-03-15")
print(f"Open: {branch['open_drafts']}, Merged: {branch['merged_drafts']}")
print(f"Recommendations: {branch['recommendations']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const branch = await nx.memoryBranch("session-2026-03-15");
console.log(`Open: ${branch.open_drafts}, Merged: ${branch.merged_drafts}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/memory-branches/session-2026-03-15 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `drafts.branch_not_found` | No drafts found for this branch |

---

## Merge Branch

```
POST /v1/memory-branches/{branch_id}/merge
```

Merge all open drafts in a branch into canonical memory in a single operation.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `branch_id` | string | Branch/session identifier |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `branch_id` | string | Branch identifier |
| `merged_count` | number | Number of drafts merged |
| `merged_memory_ids` | string[] | IDs of the created canonical memories |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.merge_branch("session-2026-03-15")
print(f"Merged {result['merged_count']} drafts")
for mid in result["merged_memory_ids"]:
    print(f"  -> {mid}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.mergeBranch("session-2026-03-15");
console.log(`Merged ${result.merged_count} drafts`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/memory-branches/session-2026-03-15/merge \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "branch_id": "session-2026-03-15",
  "merged_count": 3,
  "merged_memory_ids": ["mem_001", "mem_002", "mem_003"]
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `drafts.branch_not_found` | No open drafts found for this branch |

---

## Reject Branch

```
POST /v1/memory-branches/{branch_id}/reject
```

Reject all open drafts in a branch.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `branch_id` | string | Branch/session identifier |

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `reason` | string | No | — | Reason for rejection |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.reject_branch(
    "session-2026-03-15",
    reason="Session contained hallucinated memories"
)
print(f"Rejected {result['rejected_drafts']} drafts")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.rejectBranch("session-2026-03-15", {
  reason: "Session contained hallucinated memories",
});
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/memory-branches/session-2026-03-15/reject \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Session contained hallucinated memories"}'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `drafts.branch_not_found` | No open drafts found for this branch |
