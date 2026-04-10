---
title: "Novyx Changelog — Release History & Updates"
description: "What's new in Novyx Core. Release notes for SDK updates, API improvements, MCP server changes, and new features."
---

# Changelog

## Phases 1-5 — April 10, 2026

**Novyx Control: governance shipment**

A five-phase upgrade to Novyx Control that turns governance into a first-class, tenant-authored, per-agent capability. The marketing site, SDKs, MCP server, and docs are all updated.

- **Phase 1 — Policy-as-code.** Author custom Control policies in YAML or JSON. Each rule has a regex `match`, `severity`, optional `context_requires`, and an optional `on_violation` outcome (`block`, `require_approval`, or `warn`). Severity-based defaults if omitted: CRITICAL→block, HIGH→require_approval, MEDIUM/LOW→warn. Tier-gated: Free=0, Starter=5, Pro=25, Enterprise=unlimited. Built-in `FinancialSafetyPolicy` and `DataExfiltrationPolicy` are always active. Full CRUD: `POST`/`GET`/`PUT`/`DELETE /v1/control/policies`. See [Custom Policies](./control/custom-policies).
- **Phase 2 — Approval workflows.** New action status `pending_review`. Real approval queue at `GET /v1/approvals` (returns latest event per `action_id` ordered by `sequence_number`, not timestamp — survives cross-worker clock drift). `POST /v1/approvals/{action_id}/decision` with 404 for unknown action and 409 for already-decided. Three approval modes: Solo (phrase + 5s delay), Team (different person OR 10min cooldown), Enterprise (multi-person chains with `min_approvals`). See [Approval Workflows](./control/approval-workflows).
- **Phase 3 — Multi-provider neutrality.** `novyx-agent` 1.x → 2.0: `provider` and `model` are now required keyword arguments on `Agent(...)`. The OpenAI default has been removed. Valid providers: `openai`, `anthropic`, `litellm` (with `litellm` covering Gemini, Mistral, Cohere, Ollama, etc.). Same change applies to `nx.create_agent()` (Python SDK 3.3.0), `nx.createAgent()` (JS SDK 3.1.0), and the `create_agent` MCP tool. New `ToolDef.to_provider_schema(provider)` dispatcher. **Breaking change.** See the [novyx-agent 2.0 upgrade guide](./agent-sdk/upgrade-to-2.0).
- **Phase 4 — Governance dashboard.** `GET /v1/control/dashboard?window=24h|7d|30d&bucket=hour|day` returns aggregated stats — totals, violations broken down by policy and agent, and a time-series. Postgres-only; tenants in file mode receive an empty-but-valid shape with `backend: "file"`. New `GET /v1/control/agents/{agent_id}/violations` for per-agent violation history. Tier: Starter+. See [Governance Dashboard](./control/dashboard).
- **Phase 5 — Agent-scoped policies.** The same policy name can have a tenant-wide version *and* per-agent overrides. Policy registry cache key is now `(tenant_id, agent_id_or_None)`. When both exist, agent-scoped wins for that agent only. All five policy CRUD endpoints accept optional `agent_id`. Tier: Pro+. See [Agent-Scoped Policies](./control/agent-scoped-policies).
- **Phase 6 — SDK wrappers.** Both SDKs now ship typed helpers for the new endpoints: Python `nx.create_policy`, `nx.list_policies`, `nx.get_policy`, `nx.update_policy`, `nx.delete_policy`, `nx.governance_dashboard`, `nx.agent_violations` (all in 3.3.0). JS equivalents in camelCase (3.1.0). All policy methods accept optional `agent_id`.

**Versions:** novyx (Python) 3.3.0 · novyx (JS) 3.1.0 · novyx-agent 2.0.0 · novyx-mcp 2.5.0 (now 119 tools, up from 107).

---

## v3.0.1 — March 11, 2026

**Security Hardening, MCP 91 Tools & JS SDK Parity**

- **MCP Server v2.2.0:** Expanded from 23 to **91 tools** — full Core API coverage including eval, cortex, replay, actions, drafts, knowledge graph, threat intelligence, auto-defense, and cross-tenant correlation
- **JS/TS SDK v2.11.0:** 27 new methods for full API parity with Python SDK
- **Security audit fixes:** SSRF DNS resolution hardened, credential leak prevention, TTL bypass fixed, search filter push-down for Postgres
- **Control integration:** Governed actions, approval flows, policy engine wired into Core audit trail
- **Eval gate:** GitHub Action for CI/CD memory health quality gates (marketplace-ready)
- **Cortex enhancements:** Real-time contradiction detection, `explain_action`, webhook bus
- **Event bus:** Real-time SSE streams for memory events
- **Revenue loop:** Payment failure handling, value preview on tier limit 403s, `/v1/usage/insights` endpoint, first-memory activation tracking

## v3.0.0 — March 8, 2026

**Eval System, AsyncNovyx & CI/CD Quality Gates**

- **Eval system:** Memory health scoring with composite score (0–100) from recall consistency, drift, conflicts, and staleness
- **CI/CD quality gate:** `POST /v1/eval/gate` blocks deploys when memory health drops below your threshold (Pro+)
- **Baseline regression testing:** Save recall queries as baselines, detect when results degrade across eval runs
- **Drift analysis:** Track how memory composition changes over time — count deltas, importance shifts, topic churn
- **AsyncNovyx:** Full async client with httpx — `pip install novyx[async]`. Complete parity with sync client
- **Eval history:** Track health scores over time with per-tier retention (Free: 7d, Starter: 30d, Pro: 90d, Enterprise: 365d)
- **7 new SDK methods:** `eval_run()`, `eval_gate()`, `eval_history()`, `eval_drift()`, `eval_baseline_create()`, `eval_baselines()`, `eval_baseline_delete()`

## v2.11.0 — March 5, 2026

**Compensation Webhooks, Memory Export & Slack/Discord Formatting**

- Compensations API (Pro+): preview, list, get, and acknowledge rollback compensation plans
- New webhook event: `rollback.compensations` — fires when a rollback detects ACTION trace steps
- Memory Export: export memories as Markdown, JSON, or CSV via `GET /v1/memories/export`
- Slack and Discord native webhook formatting
- GitHub Action for CI/CD memory sync and rollback validation

## v2.10.0 — March 3, 2026

**Pro Tier Expansion, Milestones API & LlamaIndex**

- Cortex Insights and Insight Config moved from Enterprise to Pro+
- Replay Counterfactual Recall and Drift Analysis moved from Enterprise to Pro+
- Milestones API (Pro+): tag meaningful points in your memory timeline
- novyx-llamaindex v1.0.0 — LlamaIndex integration
- Webhooks (Pro+): real-time HMAC-signed notifications
- Teams & RBAC (Pro+): multi-tenant collaboration

## v2.9.2 — February 27, 2026

**SDK 2.9.2 — Context Spaces, Replay & Cortex Methods**

- 13 new SDK methods across Python and JS/TS
- Context Spaces: `create_space()`, `list_spaces()`, `space_memories()`, `update_space()`, `delete_space()`, `share_space()`
- Replay: `replay_timeline()`, `replay_snapshot()`, `replay_lifecycle()`, `replay_diff()`
- Cortex: `cortex_status()`, `cortex_run()`, `cortex_insights()`
- Full API parity between Python and JS/TS SDKs

## MCP v2.0.0 — February 26, 2026

**MCP Server 2.0 — Tools, Resources & Prompts**

- Initial MCP release with core memory, context spaces, replay, and cortex tools
- 6 resources: `novyx://memories`, `novyx://stats`, `novyx://usage`, `novyx://spaces`, and per-ID lookups
- 3 prompts: `memory-context`, `session-summary`, `space-context`
- Context spaces for multi-agent collaboration via MCP
- Graceful tier gating — tools return clear upgrade messages on lower tiers
