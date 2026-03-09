---
sidebar_position: 1
title: Quickstart
description: Get persistent memory running in 30 seconds. Three lines of code.
---

# Quickstart

Get Novyx running in 30 seconds. Three lines of code.

## 1. Install

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```bash
pip install novyx
```

For async support (httpx):

```bash
pip install novyx[async]
```

  </TabItem>
  <TabItem value="typescript" label="TypeScript">

```bash
npm install novyx
```

  </TabItem>
  <TabItem value="curl" label="curl">

No installation needed. Use any HTTP client.

  </TabItem>
</Tabs>

## 2. Get an API key

Sign up at [novyxlabs.com](https://www.novyxlabs.com) and grab a free API key. Free tier includes 5,000 memories, 10 rollbacks/month, and full semantic search.

:::tip No API key needed for MCP local mode
If you're using the [MCP Server](/mcp), you can start without an API key — it runs locally with SQLite at `~/.novyx/local.db`. Add an API key later to sync to the cloud.
:::

## 3. Remember, Recall, Rollback

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

# Store a memory
nx.remember("User prefers dark mode", tags=["preferences"])

# Semantic search — ask a question, get ranked results
results = nx.recall("What does the user prefer?")
print(results[0]["observation"])  # "User prefers dark mode"

# Undo mistakes — rollback to any point in time
nx.rollback(target="2 hours ago")
```

  </TabItem>
  <TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

// Store a memory
await nx.remember({ observation: "User prefers dark mode", tags: ["preferences"] });

// Semantic search — ask a question, get ranked results
const results = await nx.recall("What does the user prefer?");
console.log(results[0].observation); // "User prefers dark mode"

// Undo mistakes — rollback to any point in time
await nx.rollback({ target: "2 hours ago" });
```

  </TabItem>
  <TabItem value="curl" label="curl">

```bash
# Store a memory
curl -X POST https://novyx-ram-api.fly.dev/v1/memories \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"observation": "User prefers dark mode", "tags": ["preferences"]}'

# Semantic search
curl "https://novyx-ram-api.fly.dev/v1/memories/search?q=user+preferences" \
  -H "Authorization: Bearer nram_your_key"

# Rollback to 2 hours ago
curl -X POST https://novyx-ram-api.fly.dev/v1/rollback \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"target": "2 hours ago"}'
```

  </TabItem>
</Tabs>

That's it. Your agent now has persistent memory that survives restarts, crashes, and redeployments.

## What you get on Free tier

| Feature | Limit |
|---------|-------|
| Memories | 5,000 |
| API calls | 5,000/month |
| Rollbacks | 10/month |
| Semantic search | Included |
| Audit trail | 7 days |
| Circuit breaker | Included |
| Eval runs | 3/day |

## Next steps

- **[Installation](/getting-started/installation)** — All install options (sync, async, MCP, framework integrations)
- **[First API call](/getting-started/first-api-call)** — Detailed walkthrough with response shapes
- **[API Reference](/api-reference)** — Every endpoint across 19 routers
- **[Guides](/guides)** — Rollback, eval, knowledge graph, framework integrations
