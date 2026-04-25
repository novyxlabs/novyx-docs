---
title: "Novyx MCP Server — 120 Tools for Claude, Cursor & Cline"
description: "The most complete MCP memory server. Remember, recall, rollback, knowledge graph, eval, and governed actions. Zero-config local mode or Novyx Cloud."
---

# MCP Server

120 tools for Cursor, Claude Code, Claude Desktop, and any MCP-compatible client.

**Install:** `pip install novyx-mcp`

:::tip No API key needed
novyx-mcp runs locally with SQLite at `~/.novyx/local.db`. Add a Novyx API key later to sync to the cloud.
:::

## Modes

| Mode | Storage | API Key | Use case |
|------|---------|---------|----------|
| [Local](/mcp/local-mode) | SQLite (`~/.novyx/local.db`) | Not required | Personal projects, getting started |
| [Cloud](/mcp/cloud-mode) | Novyx API (Postgres) | Required | Production, multi-device sync |

## Tool Categories

| Category | Tools | Tier |
|----------|-------|------|
| Core Memory | remember, recall, forget, list_memories, memory_stats, memory_health | Free+ |
| Knowledge Graph | add_triple, query_triples, delete_triple, list_entities, get_entity, delete_entity, get_links, link_memories, unlink, graph_edges | Pro+ |
| Context Spaces | create_space, list_spaces, update_space, delete_space, share_space, space_memories, shared_contexts, accept_shared_context, revoke_shared_context | Free+ |
| Rollback & Audit | rollback, rollback_preview, rollback_history, audit, audit_verify | Free+ |
| Replay | replay_timeline, replay_snapshot, replay_diff, replay_lifecycle, replay_memory, replay_memory_drift, replay_recall | Pro+ |
| Cortex | cortex_run, cortex_config, cortex_status, cortex_insights | Pro+ |
| Eval | eval_run, eval_gate, eval_history, eval_drift | All |
| Actions/Control | list_pending, approve_action, check_policy, action_history | Pro+ |
| Memory Drafts | draft_memory, merge_draft, reject_draft, draft_diff, memory_drafts | Starter+ |
| Other | dashboard, context_now, supersede, memory_branch, merge_branch, reject_branch, trace_create, trace_step, trace_complete, trace_verify | Varies |

See the [full tools reference](/mcp/tools-reference) for parameters and response shapes.
