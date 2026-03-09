---
title: MCP Server
description: 23 MCP tools for Cursor, Claude Code, and any MCP-compatible client.
---

# MCP Server

23 memory tools for Cursor, Claude Code, Claude Desktop, and any MCP-compatible client.

**Install:** `pip install novyx-mcp`

:::tip No API key needed
novyx-mcp runs locally with SQLite at `~/.novyx/local.db`. Add a Novyx API key later to sync to the cloud.
:::

## Modes

| Mode | Storage | API Key | Use case |
|------|---------|---------|----------|
| [Local](/mcp/local-mode) | SQLite (`~/.novyx/local.db`) | Not required | Personal projects, getting started |
| [Cloud](/mcp/cloud-mode) | Novyx API (Postgres) | Required | Production, multi-device sync |

## Tools (23)

| Category | Tools | Tier |
|----------|-------|------|
| Core Memory | remember, recall, list, get, update, delete, supersede, rollback, rollback_preview, create_link, get_links, delete_link | Free+ |
| Knowledge Graph | create_triple, query_triples, traverse_entity | Pro+ |
| Context | context_now, audit_trail, usage_stats | Free+ |
| Milestones | create_milestone, list_milestones, milestone_diff | Pro+ |
| Cortex | cortex_status, cortex_run | Pro+ |

See the [full tools reference](/mcp/tools-reference) for parameters and response shapes.
