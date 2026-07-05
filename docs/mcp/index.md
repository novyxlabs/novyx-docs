---
title: "Novyx MCP Server — Governed Agent Access"
description: "Use MCP as a path for AI agents to request governed actions, attach context, read decisions, and inspect audit evidence."
---

# MCP Server

The Novyx MCP server is a developer access path into the action gate. It lets MCP-capable agents request governed actions, attach context, read decisions, and inspect audit evidence.

Current `novyx-mcp` builds register **102 tools**. Exact counts can change as experimental tools move in or out of the registry, so the useful adoption path is the workflow, not the count.

**Install:** `pip install novyx-mcp`

:::tip No API key needed for local memory work
novyx-mcp can run locally with SQLite at `~/.novyx/local.db`. Use cloud mode when you need shared audit evidence, approvals, or production action governance.
:::

## Modes

| Mode | Storage | API Key | Use case |
|------|---------|---------|----------|
| [Local](/mcp/local-mode) | SQLite (`~/.novyx/local.db`) | Not required | Personal context, local development, memory experiments |
| [Cloud](/mcp/cloud-mode) | Novyx API (Postgres) | Required | Protected actions, approvals, audit evidence, team workflows |

## Start with the action surface

| Workflow | Representative tools | Status |
|----------|----------------------|--------|
| Request a protected action | `submit_action`, `list_pending`, `approve_action`, `action_history` | Primary |
| Attach and inspect evidence | `audit`, `audit_verify`, `trace_create`, `trace_step`, `trace_complete` | Primary |
| Preserve context | `remember`, `recall`, `list_memories`, `context_now` | Supporting |
| Recovery review | `rollback_preview`, `rollback_history`, `create_checkpoint`, `rollback_to_checkpoint` | Supporting; scope varies by API |
| Experimental support | `cortex_*`, `eval_*`, replay snapshots | Off by default or product-dependent |

See the [full tools reference](/mcp/tools-reference) for parameters and response shapes.
