---
sidebar_position: 1
title: API Reference
description: Complete API reference for Novyx Core — 120+ endpoints across 19 routers.
---

# API Reference

Complete reference for the Novyx Core API. 120+ endpoints across 19 routers.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Authentication:** Bearer token (`Authorization: Bearer nram_your_key`)

## Routers

| Router | Endpoints | Tier | Description |
|--------|-----------|------|-------------|
| [Memories](/api-reference/memories) | 7 | All | Store, get, update, delete memories |
| [Search](/api-reference/search) | 1 | All | Semantic search with recency weighting |
| [Rollback](/api-reference/rollback) | 2 | All | Point-in-time restore with preview |
| [Audit](/api-reference/audit) | 2 | All | SHA-256 hashed operation logs |
| [Spaces](/api-reference/spaces) | 6 | All | Memory namespaces for multi-agent teams |
| [Traces](/api-reference/traces) | 8 | Pro+ | RSA-signed execution traces |
| [Knowledge Graph](/api-reference/knowledge-graph) | 7 | Pro+ | Subject-predicate-object triples and entities |
| [Replay](/api-reference/replay) | 4 | Pro+ | Time-travel debugging |
| [Cortex](/api-reference/cortex) | 5 | Pro+ | Autonomous memory maintenance |
| [Eval](/api-reference/eval) | 7 | All | Memory health scoring & CI/CD gates |
| [Webhooks](/api-reference/webhooks) | 6 | Pro+ | Real-time event notifications |
| [Teams](/api-reference/teams) | 9 | Pro+ | Multi-tenant collaboration |
| [Milestones](/api-reference/milestones) | 1 | All | Account achievement tracking |
| [Anomalies](/api-reference/anomalies) | — | Pro+ | Behavioral anomaly detection (via Audit) |
| [Sharing](/api-reference/sharing) | 6 | Pro+ | Space sharing and access tokens |
| [API Keys](/api-reference/api-keys) | 5 | All | Key management and rotation |
| [Export](/api-reference/export) | 1 | Starter+ | Audit log export (CSV, JSON, JSONL) |
| [Actions](/api-reference/actions) | 5+ | Pro+ | Governed actions, approval flows, policy engine |
| [Usage](/api-reference/usage) | 2 | All | Plan usage, limits, and dashboard |
| [System](/api-reference/system) | 4 | Public | Health checks, status, milestones |
