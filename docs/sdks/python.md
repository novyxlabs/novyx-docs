---
title: "Novyx Python SDK Reference — Complete API"
description: "Full API reference for the Novyx Python SDK. Every method documented with parameters, return types, and usage examples."
---

# Python SDK

`pip install novyx` — 85+ methods for persistent memory, rollback, audit, knowledge graph, eval, governance, and more.

:::caution Breaking change in 3.3.0
`nx.create_agent()` now requires `provider` and `model` keyword arguments. The previous OpenAI default was removed in Phase 3 of the governance shipment. See the [novyx-agent 2.0 upgrade guide](../agent-sdk/upgrade-to-2.0) for the same change in the higher-level Agent class.
:::

:::tip New in 3.4.0 — `nx.submit_action()`
Typed wrapper around `POST /v1/actions` for the main cloud governance flow. Distinct from the legacy `nx.action_submit()` which targets a separate Control instance via `control_url`. See the [Control section](../control/approval-workflows#polling-pattern) for the recommended pattern.
:::

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

### Control — Actions & Approvals

| Method | Description |
|--------|-------------|
| `nx.submit_action(action, params=None, *, agent_id=None)` | **Recommended.** Submit an action to the main cloud governance flow (`POST /v1/actions`). Evaluates against built-in + custom YAML policies. Returns status `allowed`, `blocked`, or `pending_review`. New in 3.4.0. |
| `nx.action_status(action_id)` | Check action status, including post-approval result. |
| `nx.action_list(status=None, *, limit=None)` | List recent Control actions. |
| `nx.policy_check(agent_id=None, connector=None, operation=None)` | Read the active policy profile. |
| `nx.list_approvals(*, limit=50, status_filter=None)` | List pending action approvals. |
| `nx.approve_action(approval_id, *, decision="approve", reason=None, approver_id=None)` | Approve or deny a pending action. |
| `nx.explain_action(action_id)` | Get the full causal chain for an action — policies, approval, memories, audit. |
| `nx.action_submit(connector, operation, payload)` | **Legacy.** Submit a `strata.action.v0` envelope to a separate Control instance. Requires `control_url` set on the client. Use `submit_action()` for the main API. |

### Control — Custom Policies (new in 3.3.0)

| Method | Description |
|--------|-------------|
| `nx.create_policy(name, *, rules, description="", step_types=None, whitelisted_domains=None, enabled=True, agent_id=None)` | Create or update a custom YAML/dict policy. Upserts on existing name. |
| `nx.list_policies(*, agent_id=None)` | List active policies. Pass `agent_id` to also include agent-scoped overrides. |
| `nx.get_policy(policy_name, *, agent_id=None)` | Fetch one policy's full configuration. Scope-aware. |
| `nx.update_policy(policy_name, *, rules, description="", ...)` | Replace an existing policy's rules. Increments `version`. |
| `nx.delete_policy(policy_name, *, agent_id=None)` | Soft-delete (disable) a custom policy. Built-ins cannot be deleted. |

All five accept optional `agent_id` for [agent-scoped policies](../control/agent-scoped-policies) (Pro+).

### Control — Governance Dashboard (new in 3.3.0)

| Method | Description |
|--------|-------------|
| `nx.governance_dashboard(*, window="7d", bucket=None)` | Aggregated stats: totals, violations by policy, by agent, time-series. Window: `24h`, `7d`, `30d`. Starter+. |
| `nx.agent_violations(agent_id, *, limit=50, since=None, until=None)` | Per-agent violation history from the audit chain. Starter+. |

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
