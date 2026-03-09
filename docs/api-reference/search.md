---
sidebar_position: 2
title: Search
description: Semantic search across memories with filters, scoring, and recency weighting.
---

# Search

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Semantic search across your memory corpus. Returns ranked results with relevance scores, cosine similarity, and match confidence. Supports tag filtering, agent scoping, recency weighting, and minimum score thresholds.

**Base URL:** `https://novyx-ram-api.fly.dev`

---

## Semantic Search

```
GET /v1/memories/search
```

Search memories by semantic similarity. The query is embedded and compared against all stored memory embeddings. Results are ranked by a blended score combining cosine similarity and optional recency weighting.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `q` | string | **Yes** | — | Search query (natural language) |
| `limit` | number | No | `5` | Max results (1–100) |
| `min_score` | number | No | `0` | Minimum similarity score (0–1). Results below this threshold are excluded |
| `tags` | string | No | — | Comma-separated tag filter. Only memories with at least one matching tag are returned |
| `agent_id` | string | No | — | Filter by agent identifier |
| `space_id` | string | No | — | Filter by space namespace (Pro+) |
| `recency_weight` | number | No | `0` | Blend recency into scoring (0–1). `0` = pure semantic, `1` = heavily favor recent memories |
| `include_superseded` | boolean | No | `false` | Include memories that have been superseded by newer versions |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `query` | string | Original search query |
| `total_results` | number | Number of results returned |
| `memories` | array | Ranked array of memory results |
| `memories[].uuid` | string | Memory ID |
| `memories[].observation` | string | Memory content |
| `memories[].score` | number | Combined relevance score (0–1) |
| `memories[].similarity` | number | Raw cosine similarity (0–1) |
| `memories[].match_confidence` | number | Match confidence indicator |
| `memories[].tags` | string[] | Memory tags |
| `memories[].importance` | number | Importance score |
| `memories[].created_at` | string | Creation timestamp |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

# Basic semantic search
results = nx.recall("user preferences")
for mem in results["memories"]:
    print(f"{mem['score']:.2f} — {mem['observation']}")

# Filtered search with minimum score
results = nx.recall(
    "dark mode settings",
    tags="preferences",
    min_score=0.7,
    limit=3,
)

# Recency-weighted search
results = nx.recall(
    "what did the user say recently?",
    recency_weight=0.8,
    limit=10,
)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

// Basic semantic search
const results = await nx.recall("user preferences");
for (const mem of results.memories) {
  console.log(`${mem.score.toFixed(2)} — ${mem.observation}`);
}

// Filtered search with minimum score
const filtered = await nx.recall("dark mode settings", {
  tags: "preferences",
  minScore: 0.7,
  limit: 3,
});

// Recency-weighted search
const recent = await nx.recall("what did the user say recently?", {
  recencyWeight: 0.8,
  limit: 10,
});
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# Basic semantic search
curl "https://novyx-ram-api.fly.dev/v1/memories/search?q=user+preferences" \
  -H "Authorization: Bearer nram_your_key"

# Filtered search with minimum score
curl "https://novyx-ram-api.fly.dev/v1/memories/search?q=dark+mode+settings&tags=preferences&min_score=0.7&limit=3" \
  -H "Authorization: Bearer nram_your_key"

# Recency-weighted search
curl "https://novyx-ram-api.fly.dev/v1/memories/search?q=what+did+the+user+say+recently&recency_weight=0.8&limit=10" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "query": "user preferences",
  "total_results": 3,
  "memories": [
    {
      "uuid": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "observation": "User prefers dark mode and compact layouts",
      "score": 0.92,
      "similarity": 0.92,
      "match_confidence": 0.95,
      "tags": ["preferences", "ui"],
      "importance": 8,
      "created_at": "2026-03-09T12:00:00Z"
    },
    {
      "uuid": "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "observation": "User timezone is America/New_York",
      "score": 0.78,
      "similarity": 0.78,
      "match_confidence": 0.82,
      "tags": ["preferences"],
      "importance": 6,
      "created_at": "2026-03-08T10:30:00Z"
    }
  ]
}
```

### How scoring works

The `score` field is a blended relevance score:

- **Without recency weighting** (`recency_weight=0`): Score equals cosine similarity between the query embedding and memory embedding.
- **With recency weighting** (`recency_weight=0.5`): Score blends similarity with temporal proximity. Recent memories score higher even with slightly lower semantic match.

The `similarity` field always contains the raw cosine similarity, regardless of recency weighting. Use this when you need the unblended semantic match.

The `match_confidence` field indicates how reliable the match is — factoring in the memory's recall frequency and importance.

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Missing `q` parameter or invalid `limit` range |
| 429 | `RATE_LIMITED` | Exceeded plan API call quota |

### Tips

- Use `min_score` to filter out low-quality matches. Start with `0.6` and adjust based on your use case.
- Tag filtering happens _before_ semantic ranking — it narrows the candidate set, not the final results.
- `recency_weight` is useful for conversational agents where recent context matters more than historical knowledge.
- Set `include_superseded=true` if you need to search the full history including replaced memories.
