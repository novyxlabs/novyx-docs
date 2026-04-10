---
sidebar_position: 1
title: "novyx-agent 2.0 — Upgrade Guide"
description: "Breaking change: provider and model are now required keyword arguments on Agent(...). Migration guide for novyx-agent 1.x → 2.0."
---

# Upgrading to novyx-agent 2.0

`novyx-agent` 2.0 makes Novyx's provider-agnostic positioning real at the SDK level. The headline change: **`provider` and `model` are now required keyword arguments** when constructing an `Agent`. There is no default — passing neither raises `ValueError` immediately.

This is a breaking change. Anyone on `novyx-agent` 1.x will hit a hard error on first construction after upgrading.

---

## What changed

In 1.x, `novyx-agent` defaulted to OpenAI's `gpt-4o` if you didn't specify a provider or model. The default existed for ergonomic reasons but contradicted the entire point of the package: **Novyx is a horizontal layer over any provider**, and shipping a default that picked one of them undermined that.

In 2.0, the constructor requires you to make the choice explicitly:

```python
# 1.x — implicit OpenAI default
agent = Agent(api_key=key, instructions="...")

# 2.0 — explicit
agent = Agent(
    api_key=key,
    provider="anthropic",
    model="claude-sonnet-4-6",
    instructions="...",
)
```

Construction in 2.0 raises `ValueError` if either is missing:

```python
agent = Agent(api_key=key, instructions="...")
# ValueError: provider is required — choose 'openai', 'anthropic', or 'litellm'
```

---

## Migration

For most callers, the migration is mechanical: add `provider` and `model` to your `Agent(...)` constructors, mapped to whichever LLM you were already using.

### Before (1.x)

```python
from novyx_agent import Agent

agent = Agent(
    api_key="nram_your_key",
    instructions="You are a helpful research assistant.",
    temperature=0.5,
)
```

### After (2.0) — OpenAI

```python
from novyx_agent import Agent

agent = Agent(
    api_key="nram_your_key",
    provider="openai",
    model="gpt-4o",
    instructions="You are a helpful research assistant.",
    temperature=0.5,
)
```

### After (2.0) — Anthropic

```python
agent = Agent(
    api_key="nram_your_key",
    provider="anthropic",
    model="claude-sonnet-4-6",
    instructions="You are a helpful research assistant.",
    temperature=0.5,
)
```

### After (2.0) — anything else (via LiteLLM)

```python
agent = Agent(
    api_key="nram_your_key",
    provider="litellm",
    model="gemini/gemini-2.0-flash",  # or mistral/, cohere/, ollama/, etc.
    instructions="You are a helpful research assistant.",
    temperature=0.5,
)
```

---

## The three valid providers

| Provider | What it covers | Example models |
|----------|---------------|----------------|
| `openai` | OpenAI's official API | `gpt-4o`, `gpt-4o-mini`, `o1`, `o1-mini` |
| `anthropic` | Anthropic's official API | `claude-sonnet-4-6`, `claude-opus-4-6`, `claude-haiku-4-5-20251001` |
| `litellm` | Everything else, via LiteLLM | `gemini/gemini-2.0-flash`, `mistral/mistral-large-latest`, `cohere/command-r-plus`, `ollama/llama3.2`, etc. |

`litellm` is the escape hatch. If your model isn't directly supported by either of the official APIs, pass it through LiteLLM and use whatever model string LiteLLM expects. Novyx forwards the call without inspecting the string.

Construction validates the provider value:

```python
agent = Agent(api_key=key, provider="cohere", model="command-r")
# ValueError: Unknown provider 'cohere'. Choose 'openai', 'anthropic', or 'litellm'
#             (use litellm for Gemini, Mistral, Cohere, etc.).
```

---

## `ToolDef.to_provider_schema(provider)`

Most users never touch tool serialization directly — `novyx-agent` handles it under the hood. But if you're building a custom tool serializer or wrapping `ToolDef` for your own agent runtime, 2.0 ships a new dispatcher:

```python
from novyx_agent.types import ToolDef

tool = ToolDef(
    name="search_db",
    description="Search the customer database",
    parameters={"type": "object", "properties": {"query": {"type": "string"}}},
)

# Dispatch by provider
openai_schema = tool.to_provider_schema("openai")
anthropic_schema = tool.to_provider_schema("anthropic")
litellm_schema = tool.to_provider_schema("litellm")  # same shape as OpenAI
```

The dispatch logic:

- `provider="openai"` → returns OpenAI function-calling format
- `provider="litellm"` → returns OpenAI format (LiteLLM accepts OpenAI-shaped tool schemas and translates internally)
- `provider="anthropic"` → returns Anthropic tool-use format
- Anything else → raises `ValueError`

---

## Related: MCP `create_agent` tool

The same change applies to the `create_agent` MCP tool in `novyx-mcp` 2.5.0. If you have Claude Code or another MCP client that creates agents through the MCP server, it now needs to pass `provider` and `model`:

```json
{
  "tool": "create_agent",
  "arguments": {
    "name": "research-bot",
    "provider": "anthropic",
    "model": "claude-sonnet-4-6",
    "instructions": "You are a researcher."
  }
}
```

Calls without `provider` or `model` return an error string immediately, before any API call is made:

```json
{"error": "Invalid provider 'None'. Choose 'openai', 'anthropic', or 'litellm' (use litellm for Gemini, Mistral, Cohere, etc.)."}
```

See the [MCP tools reference](../mcp/tools-reference) for the full `create_agent` signature.

---

## Why this is a breaking change worth taking

Defaults in libraries quietly steer users. `novyx-agent` 1.x defaulting to OpenAI meant that every developer who installed the package and ran `Agent(...)` ended up locked into OpenAI without making a deliberate choice. That contradicted the entire premise of running a horizontal governance layer over any model provider.

2.0 makes the choice deliberate. The migration is one line of code per agent. The payoff is consistency: novyx-agent, `novyx.create_agent()` (Python SDK 3.3.0), `nx.createAgent()` (JS SDK 3.1.0), and the `create_agent` MCP tool all enforce the same contract — provider and model are first-class, not implementation details.

---

## See also

- [Python SDK reference](../sdks/python) — `nx.create_agent()` signature
- [TypeScript SDK reference](../sdks/typescript) — `nx.createAgent()` signature
- [MCP tools reference](../mcp/tools-reference) — `create_agent` MCP tool
- [Changelog](../changelog) — full Phases 1-5 entry
