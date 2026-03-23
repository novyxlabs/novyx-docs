---
title: "Novyx Python SDK Reference — Complete API"
description: "Full API reference for the Novyx Python SDK. Every method documented with parameters, return types, and usage examples."
---

# Python SDK

`pip install novyx` — 78+ methods for persistent memory, rollback, audit, knowledge graph, eval, and more.

## Installation

```bash
pip install novyx          # Sync client
pip install novyx[async]   # Async client (httpx)
```

## Quick Start

```python
from novyx import Novyx

nx = Novyx(api_key="nram_...")

# Store a memory
result = nx.remember("User prefers dark mode", tags=["preferences"])

# Recall semantically
memories = nx.recall("user preferences")

# Rollback to a point in time
nx.rollback("2 hours ago")
```

## Async Client

```python
from novyx import AsyncNovyx

nx = AsyncNovyx(api_key="nram_...")
result = await nx.remember("User prefers dark mode")
memories = await nx.recall("user preferences")
```

## Core Methods

### Memory

| Method | Description |
|--------|-------------|
| `nx.remember(observation, *, tags, importance, context, agent_id, space_id, ttl_seconds)` | Store a memory |
| `nx.recall(query, *, tags, limit, min_score)` | Semantic search across memories |
| `nx.memories(*, tags, limit, offset)` | List memories with optional filtering |
| `nx.memory(memory_id)` | Get a single memory by ID |
| `nx.forget(memory_id)` | Delete a memory |
| `nx.supersede(old_id, new_id)` | Mark one memory as superseding another |
| `nx.stats()` | Memory count, tag distribution, importance stats |
| `nx.memory_health()` | Composite health score (0–100) |

### Rollback & Audit

| Method | Description |
|--------|-------------|
| `nx.rollback(target)` | Undo operations after a timestamp (supports "2 hours ago") |
| `nx.rollback_preview(target)` | Preview what a rollback would change |
| `nx.rollback_history(limit=50)` | List past rollback operations |
| `nx.audit(*, limit, offset)` | View the cryptographic audit trail |
| `nx.audit_verify()` | Verify hash chain integrity |
| `nx.audit_export(format="csv")` | Export audit log as CSV or JSON |

### Knowledge Graph

| Method | Description |
|--------|-------------|
| `nx.triple(subject, predicate, object)` | Add a subject-predicate-object triple |
| `nx.triples(*, subject, predicate, object)` | Query triples |
| `nx.delete_triple(triple_id)` | Delete a triple |
| `nx.entities(*, limit, offset)` | List entities in the graph |
| `nx.entity(entity_id)` | Get entity details |
| `nx.delete_entity(entity_id)` | Delete an entity |
| `nx.graph(*, limit)` | Get graph edges |

### Context Spaces

| Method | Description |
|--------|-------------|
| `nx.create_space(name, description)` | Create an isolated memory namespace |
| `nx.list_spaces()` | List all spaces |
| `nx.get_space(space_id)` | Get space details |
| `nx.update_space(space_id, *, name, description)` | Update a space |
| `nx.delete_space(space_id)` | Delete a space |
| `nx.space_memories(space_id, *, limit, offset)` | List memories in a space |
| `nx.share_context(*, tags, target_tenant)` | Share tagged memories with another tenant |
| `nx.shared_contexts()` | List shared contexts |

### Replay (Pro+)

| Method | Description |
|--------|-------------|
| `nx.replay_timeline(*, limit, offset)` | Full timeline of memory changes |
| `nx.replay_snapshot(at, *, limit)` | Point-in-time memory snapshot |
| `nx.replay_memory(memory_id)` | Full lifecycle of a single memory |
| `nx.replay_recall(query, at, *, limit)` | "What would recall have returned at time X?" |
| `nx.replay_diff(from_ts, to_ts)` | Compare memory state between two timestamps |
| `nx.replay_drift(from_ts, to_ts)` | Analyze how memory composition drifted |

### Cortex (Pro+)

| Method | Description |
|--------|-------------|
| `nx.cortex_status()` | Check Cortex analysis status |
| `nx.cortex_config()` | Get current Cortex configuration |
| `nx.cortex_update_config(**kwargs)` | Update Cortex settings |
| `nx.cortex_run()` | Trigger autonomous memory maintenance |
| `nx.cortex_insights(*, limit, offset)` | Get AI-generated insights |

### Eval

| Method | Description |
|--------|-------------|
| `nx.eval_run(*, min_score)` | Run memory health evaluation |
| `nx.eval_gate(min_score)` | CI/CD quality gate — fails if health below threshold |
| `nx.eval_history(*, limit, offset)` | Past evaluation results |
| `nx.eval_drift(*, days)` | Memory drift analysis over time |
| `nx.eval_baseline_create(query, expected)` | Create a recall baseline |
| `nx.eval_baselines()` | List baselines |
| `nx.eval_baseline_delete(baseline_id)` | Delete a baseline |

### Control (Actions & Approval)

| Method | Description |
|--------|-------------|
| `nx.action_submit(action, tool, params, risk_level)` | Submit an action for policy evaluation |
| `nx.action_status(action_id)` | Check action status (allowed/blocked/pending) |
| `nx.action_list(status=None)` | List actions |
| `nx.policy_check(action, tool, params)` | Check if an action would be allowed |
| `nx.approve_action(approval_id, *, decision)` | Approve or reject a pending action |
| `nx.list_approvals(*, limit, status_filter)` | List pending approvals |
| `nx.list_policies()` | List active policies |
| `nx.explain_action(action_id)` | Get detailed explanation of policy decision |

### Memory Drafts

| Method | Description |
|--------|-------------|
| `nx.draft_memory(observation, *, tags, importance)` | Create a draft (not yet committed) |
| `nx.memory_drafts(*, status, branch_id)` | List drafts |
| `nx.draft_diff(draft_id)` | Compare draft to current state |
| `nx.merge_draft(draft_id)` | Commit a draft to memory |
| `nx.reject_draft(draft_id, *, reason)` | Reject a draft |

### Streaming

| Method | Description |
|--------|-------------|
| `nx.stream(event_types)` | Subscribe to real-time SSE memory events |
| `nx.stream_status()` | Check stream connection status |

## Error Handling

```python
from novyx import Novyx, NovyxError

nx = Novyx(api_key="nram_...")

try:
    nx.remember("something")
except NovyxError as e:
    print(f"Error: {e.status_code} — {e.message}")
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `NOVYX_API_KEY` | Your API key (alternative to passing in constructor) |
| `NOVYX_BASE_URL` | Override the API base URL (default: `https://novyx-ram-api.fly.dev`) |
