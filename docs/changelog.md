---
title: Changelog
description: What's new in Novyx Core. Release notes for SDK updates, API improvements, and new features.
---

# Changelog

## v3.0.1 — March 11, 2026

**Security Hardening, MCP 64 Tools & JS SDK Parity**

- **MCP Server v2.2.0:** Expanded from 23 to **64 tools** — full Core API coverage including eval, cortex, replay, actions, drafts, knowledge graph, and more
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
