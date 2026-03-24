---
sidebar_position: 2
title: "Install Novyx — pip install novyx"
description: "Install Novyx via pip, npm, or the MCP server. Python SDK, JavaScript SDK, and CLI options for every platform."
---

# Installation

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

## Core SDK

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```bash
pip install novyx
```

**Requirements:** Python 3.9+

The Python SDK includes the CLI — after installing, you can use both `from novyx import Novyx` and the `novyx` command in your terminal.

### Async support

For async/await with httpx:

```bash
pip install novyx[async]
```

```python
from novyx import AsyncNovyx

nx = AsyncNovyx(api_key="nram_your_key")
await nx.remember("User prefers dark mode")
results = await nx.recall("user preferences")
```

`AsyncNovyx` has full parity with the sync client — every method is available as an async variant.

  </TabItem>
  <TabItem value="typescript" label="TypeScript">

```bash
npm install novyx
```

**Requirements:** Node.js 18+ or any modern browser

```typescript
import { Novyx } from "novyx";
const nx = new Novyx({ apiKey: "nram_your_key" });
```

Zero dependencies. Full TypeScript types included. Dual CJS/ESM — works everywhere. 50+ methods with full API parity (eval methods coming soon).

</TabItem>
</Tabs>

## Framework integrations

<Tabs>
  <TabItem value="langchain" label="LangChain" default>

```bash
pip install novyx-langchain
```

```python
from novyx_langchain import NovyxMemory
from langchain.chains import ConversationChain
from langchain_openai import ChatOpenAI

memory = NovyxMemory(api_key="nram_your_key", session_id="user-123")
chain = ConversationChain(llm=ChatOpenAI(), memory=memory)
```

  </TabItem>
  <TabItem value="crewai" label="CrewAI">

```bash
pip install novyx-crewai
```

```python
from novyx_crewai import NovyxStorage
from crewai import Crew

storage = NovyxStorage(api_key="nram_your_key", memory_type="short_term")
crew = Crew(agents=[...], tasks=[...], memory=True, storage=storage)
```

  </TabItem>
  <TabItem value="llamaindex" label="LlamaIndex">

```bash
pip install novyx-llamaindex
```

```python
from novyx_llamaindex import NovyxChatStore
from llama_index.core.memory import ChatMemoryBuffer

chat_store = NovyxChatStore(api_key="nram_your_key")
memory = ChatMemoryBuffer.from_defaults(
    chat_store=chat_store,
    chat_store_key="user-123",
    token_limit=3000,
)
```

  </TabItem>
</Tabs>

## MCP Server

For Cursor, Claude Code, Claude Desktop, or any MCP-compatible client:

```bash
pip install novyx-mcp
```

:::tip No API key needed
novyx-mcp runs locally with SQLite — just install and go. Memories are stored in `~/.novyx/local.db`. Add a Novyx API key later to sync to the cloud.
:::

<Tabs>
  <TabItem value="claude-code" label="Claude Code" default>

```bash
claude mcp add novyx-memory -- uvx novyx-mcp
```

  </TabItem>
  <TabItem value="cursor" label="Cursor">

Add to `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "novyx-memory": {
      "command": "uvx",
      "args": ["novyx-mcp"]
    }
  }
}
```

  </TabItem>
  <TabItem value="claude-desktop" label="Claude Desktop">

Add to your MCP config:

```json
{
  "mcpServers": {
    "novyx-memory": {
      "command": "uvx",
      "args": ["novyx-mcp"]
    }
  }
}
```

  </TabItem>
</Tabs>

## Verify installation

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```python
from novyx import Novyx
nx = Novyx(api_key="nram_your_key")
print(nx.usage())  # Shows your plan, limits, and current usage
```

  </TabItem>
  <TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";
const nx = new Novyx({ apiKey: "nram_your_key" });
console.log(await nx.usage());
```

  </TabItem>
  <TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/usage \
  -H "Authorization: Bearer nram_your_key"
```

  </TabItem>
</Tabs>

## All packages

| Package | Install | Description |
|---------|---------|-------------|
| `novyx` | `pip install novyx` | Python SDK + CLI (78 methods) |
| `novyx[async]` | `pip install novyx[async]` | Async client with httpx |
| `novyx` (npm) | `npm install novyx` | TypeScript/JavaScript SDK |
| `novyx-mcp` | `pip install novyx-mcp` | MCP server (91 tools) |
| `novyx-langchain` | `pip install novyx-langchain` | LangChain memory backend |
| `novyx-crewai` | `pip install novyx-crewai` | CrewAI storage backend |
| `novyx-llamaindex` | `pip install novyx-llamaindex` | LlamaIndex chat store |
