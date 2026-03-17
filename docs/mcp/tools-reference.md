---
title: Tools Reference
description: Complete reference for all 64 Novyx MCP Server tools, organized by category.
---

# Tools Reference

The Novyx MCP Server exposes **64 tools** that give AI agents full access to Novyx Core capabilities. Tools work in both **Cloud mode** (with `NOVYX_API_KEY`) and **Local mode** (offline SQLite).

Tier key: **Free** = available on all tiers including local mode | **Starter+** = requires Starter tier or higher | **Pro+** = requires Pro tier or higher | **Enterprise** = requires Enterprise tier

---

## Core Memory

Store, retrieve, and manage memories.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `remember` | Store a memory observation in Novyx. Auto-tags with the current git repo name. | `observation` (str), `tags` (list), `importance` (int, 1-10), `context` (str), `ttl_seconds` (int) | Free |
| `recall` | Search memories semantically using natural language. Scores combine cosine similarity, importance, and confidence. | `query` (str), `limit` (int), `tags` (list), `min_score` (float), `explain` (bool) | Free |
| `forget` | Delete a memory by its UUID. | `memory_id` (str) | Free |
| `list_memories` | List stored memories with optional tag filtering. | `limit` (int), `tags` (list) | Free |
| `supersede` | Mark a memory as superseded by a newer one. The old memory remains for audit purposes. | `old_memory_id` (str), `new_memory_id` (str) | Free |
| `link_memories` | Create a directed link between two memories (e.g. "related", "causes", "supports"). | `source_id` (str), `target_id` (str), `relation` (str) | Free |
| `unlink` | Remove a link between two memories. | `source_id` (str), `target_id` (str) | Free |
| `get_links` | Get all incoming and outgoing links for a memory. | `memory_id` (str), `relation` (str) | Free |
| `graph_edges` | Query the memory graph edges with filters on direction and relation type. | `memory_id` (str), `relation` (str), `direction` (str: outgoing/incoming/both), `limit` (int) | Free |

---

## Knowledge Graph

Build and query a subject-predicate-object knowledge graph.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `add_triple` | Add a knowledge graph triple (subject -> predicate -> object). Entities are auto-created. | `subject` (str), `predicate` (str), `object_name` (str) | Free |
| `query_triples` | Query triples with optional filters. At least one filter should be provided. | `subject` (str), `predicate` (str), `object_name` (str) | Free |
| `delete_triple` | Delete a knowledge graph triple by ID. | `triple_id` (str) | Free |
| `list_entities` | List knowledge graph entities (the nodes in your graph). | `limit` (int), `offset` (int), `entity_type` (str) | Free |
| `get_entity` | Get an entity and its associated triples. | `entity_id` (str) | Free |
| `delete_entity` | Delete an entity and all its triples. | `entity_id` (str) | Free |

---

## Context Spaces

Multi-agent collaboration through shared memory spaces.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `create_space` | Create a shared context space. The creator is the owner with full permissions. | `name` (str), `description` (str), `allowed_agents` (list), `tags` (list) | Free |
| `list_spaces` | List all context spaces you own or have access to. | — | Free |
| `space_memories` | List or search memories within a context space. | `space_id` (str), `query` (str), `limit` (int) | Free |
| `update_space` | Update a context space (owner only). | `space_id` (str), `name` (str), `description` (str), `allowed_agents` (list), `tags` (list) | Free |
| `delete_space` | Delete a context space (owner only). | `space_id` (str) | Free |
| `share_space` | Share a space/tag with another user by email. Cloud only. | `tag` (str), `email` (str), `permission` (str: read/write) | Starter+ |
| `accept_shared_context` | Accept a shared context invitation using a token. Cloud only. | `token` (str) | Starter+ |
| `shared_contexts` | List all shared contexts you have access to or have shared. Cloud only. | — | Starter+ |
| `revoke_shared_context` | Revoke a shared context invitation. Cloud only. | `token` (str) | Starter+ |

---

## Rollback & Recovery

Time-travel and undo operations on your memory store.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `rollback` | Rollback memory to a point in time. Supports ISO timestamps and relative expressions (e.g. "2 hours ago"). | `target` (str), `dry_run` (bool) | Starter+ |
| `rollback_preview` | Preview what a rollback would undo without executing it. Always use before an actual rollback. | `target` (str) | Starter+ |
| `rollback_history` | List past rollback operations with timestamps and undo counts. | `limit` (int) | Starter+ |

---

## Audit & Compliance

Cryptographic audit trail and integrity verification.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `audit` | Get the audit trail of memory operations (CREATE, UPDATE, DELETE, ROLLBACK). | `limit` (int), `operation` (str) | Free |
| `audit_verify` | Verify audit trail integrity. Checks the cryptographic hash chain (cloud) or entry consistency (local). | — | Starter+ |

---

## Execution Traces

Track and verify multi-step agent workflows.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `trace_create` | Create an execution trace to track a multi-step workflow. | `name` (str), `metadata` (JSON str) | Starter+ |
| `trace_step` | Add a step to an active execution trace. Include input/output for debugging. | `trace_id` (str), `step_name` (str), `input_data` (JSON str), `output_data` (JSON str) | Starter+ |
| `trace_complete` | Mark an execution trace as complete. The trace and steps become immutable. | `trace_id` (str) | Starter+ |
| `trace_verify` | Verify an execution trace's integrity. Confirms all steps are present and untampered. | `trace_id` (str) | Starter+ |

---

## Replay

Time-travel debugging for memory state.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `replay_timeline` | Get the full timeline of memory operations. The tape you scrub through. | `since` (ISO str), `until` (ISO str), `operations` (comma-separated str), `limit` (int) | Pro+ |
| `replay_snapshot` | Reconstruct memory state at a specific point in time. Returns all memories and links as they existed. | `at` (ISO str), `limit` (int) | Pro+ |
| `replay_lifecycle` | Full biography of a single memory: creation, updates, recalls, links, and deletion. | `memory_id` (str) | Pro+ |
| `replay_diff` | Diff memory state between two timestamps. Shows added, removed, and modified memories. | `start` (ISO str), `end` (ISO str) | Pro+ |
| `replay_memory` | Get the full chronological history of a single memory. | `memory_id` (str) | Pro+ |
| `replay_recall` | Time-travel recall: what would search have returned at a past timestamp? | `query` (str), `at` (ISO str), `limit` (int) | Pro+ |
| `replay_memory_drift` | Detect memory drift between two timestamps. Compare state and show changes. | `from_ts` (ISO str), `to_ts` (ISO str) | Pro+ |

---

## Cortex

Autonomous memory intelligence -- consolidation, reinforcement, and insights.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `cortex_status` | Get Cortex status: enabled state, last run time, consolidation/reinforcement stats. | — | Pro+ |
| `cortex_run` | Manually trigger a Cortex cycle. Merges duplicates and adjusts importance based on recall frequency. | — | Pro+ |
| `cortex_config` | Get the current Cortex configuration: thresholds, decay rates, cycle schedule. | — | Pro+ |
| `cortex_insights` | List auto-generated memory insights. Cortex detects patterns across memories. | `limit` (int) | Enterprise |

---

## Eval

Memory quality scoring and CI gates.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `eval_run` | Run a memory health evaluation. Scores quality on a 0-1 scale based on staleness, conflicts, and superseded memories. | `min_score` (float) | Starter+ |
| `eval_gate` | CI gate: pass or fail based on memory health score. Use in CI/CD pipelines. | `min_score` (float) | Starter+ |
| `eval_history` | List past evaluation runs. Track quality over time. | `limit` (int) | Starter+ |
| `eval_drift` | Detect memory drift over a time period. Shows creates, deletes, and updates. | `days` (int) | Starter+ |

---

## Actions & Control

Governed agent actions with human-in-the-loop approval workflows.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `list_pending` | List pending Control approval requests awaiting human review. | `limit` (int) | Starter+ |
| `approve_action` | Approve a pending agent action. Triggers execution against the target connector (GitHub, Slack, Linear, PagerDuty, HTTP). | `approval_id` (str), `approver_id` (str), `reason` (str) | Starter+ |
| `check_policy` | Check the current Control policy profile. Shows which connectors require approval. | `connector` (str), `environment` (str) | Starter+ |
| `action_history` | List recent Control actions with their status (submitted, pending, approved, denied, executed, failed). | `limit` (int) | Starter+ |

---

## Memory Drafts

Propose, review, and merge memory changes before they become canonical.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `draft_memory` | Create a reviewable draft without writing to canonical memory. Returns similar memories and a review summary. | `observation` (str), `tags` (list), `importance` (int), `context` (str), `confidence` (float), `branch_id` (str) | Free |
| `memory_drafts` | List current memory drafts with optional status and branch filtering. | `status` (str: draft/merged/rejected), `branch_id` (str) | Free |
| `draft_diff` | Show a field-level diff for a memory draft, with a merge recommendation. | `draft_id` (str), `compare_to` (str) | Free |
| `merge_draft` | Merge a reviewed draft into canonical memory. Optionally supersede an older memory. | `draft_id` (str), `supersede_memory_id` (str) | Free |
| `reject_draft` | Reject a draft without creating a memory. | `draft_id` (str), `reason` (str) | Free |
| `memory_branch` | Get grouped review information for a branch/session of drafts. | `branch_id` (str) | Free |
| `merge_branch` | Merge all open drafts in a branch/session at once. | `branch_id` (str) | Free |
| `reject_branch` | Reject all open drafts in a branch/session. | `branch_id` (str), `reason` (str) | Free |

---

## System

Dashboard, statistics, and health monitoring.

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `dashboard` | Full dashboard overview combining stats, spaces, and recent activity. | — | Free |
| `memory_stats` | Get memory statistics: total count, average importance, tag distribution. | — | Free |
| `memory_health` | Check memory health on a 0-100 scale. Reports stale count, conflicts, and contradictions. | — | Free |
| `context_now` | Snapshot of current memory context: recent memories, stats, and audit activity. | — | Free |

---

## Tool Count by Category

| Category | Tools |
|----------|-------|
| Core Memory | 9 |
| Knowledge Graph | 6 |
| Context Spaces | 9 |
| Rollback & Recovery | 3 |
| Audit & Compliance | 2 |
| Execution Traces | 4 |
| Replay | 7 |
| Cortex | 4 |
| Eval | 4 |
| Actions & Control | 4 |
| Memory Drafts | 8 |
| System | 4 |
| **Total** | **64** |
