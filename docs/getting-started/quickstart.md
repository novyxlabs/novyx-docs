---
sidebar_position: 1
title: "Novyx Quickstart — Submit a Protected Agent Action"
description: "Submit an AI agent action to Novyx, receive an allowed/blocked/pending_review verdict, and preserve the evidence needed for audit and recovery."
---

# Quickstart

Start with the product path Novyx is built around now: put a gate in front of one action that can change production.

## 1. Install

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```bash
pip install novyx
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

Sign up at [novyxlabs.com](https://www.novyxlabs.com) and create an API key.

:::tip MCP local mode
If you are using the [MCP Server](/mcp) for local development, you can start without an API key. Local mode uses SQLite at `~/.novyx/local.db`. Use cloud mode when you need shared audit evidence, approvals, or production action governance.
:::

## 3. Submit a protected action

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

result = nx.submit_action(
    "github.merge_pr",
    {
        "repo": "acme/api",
        "pr_number": 42,
        "environment": "production",
    },
    agent_id="deploy-agent",
)

print(result["status"])   # allowed, blocked, or pending_review
print(result["message"])  # reviewer-friendly explanation
```

  </TabItem>
  <TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const result = await nx.submitAction(
  "github.merge_pr",
  {
    repo: "acme/api",
    pr_number: 42,
    environment: "production",
  },
  { agent_id: "deploy-agent" },
);

console.log(result.status);  // allowed, blocked, or pending_review
console.log(result.message); // reviewer-friendly explanation
```

  </TabItem>
  <TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/actions \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "github.merge_pr",
    "params": {
      "repo": "acme/api",
      "pr_number": 42,
      "environment": "production"
    },
    "agent_id": "deploy-agent"
  }'
```

  </TabItem>
</Tabs>

The response tells your agent whether it may proceed, must wait for approval, or is blocked.

## What Novyx records

| Evidence | Why it matters |
|----------|----------------|
| Requested action | The exact operation the agent wanted to run |
| Policy result | Why the action was allowed, blocked, or sent to review |
| Approval state | Who approved or denied the action and when |
| Execution result | What happened after the gate cleared |
| Recovery context | Checkpoints, rollback notes, or compensation steps when available |

## Supporting features

Memory, semantic search, replay, eval, and rollback are supporting surfaces for investigation and recovery. Use them when you need context around an action. Do not treat them as a substitute for gating production-changing work before it runs.

## Next steps

- **[Approval workflows](/control/approval-workflows)** — Route risky actions to reviewers
- **[Custom policies](/control/custom-policies)** — Define action governance rules
- **[Actions API](/api-reference/actions)** — Full request and response fields
- **[MCP Server](/mcp)** — Expose governed actions to MCP-capable agents
