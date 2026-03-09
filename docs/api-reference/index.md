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
| [Spaces](/api-reference/spaces) | 3 | Pro+ | Memory namespaces for multi-agent teams |
| [Traces](/api-reference/traces) | 8 | Pro+ | RSA-signed execution traces |
| [Knowledge Graph](/api-reference/knowledge-graph) | 6 | Pro+ | Subject-predicate-object triples |
| [Replay](/api-reference/replay) | 6 | Pro+ | Time-travel debugging |
| [Cortex](/api-reference/cortex) | 5 | Pro+ | Autonomous memory maintenance |
| [Eval](/api-reference/eval) | 7 | All | Memory health scoring & CI/CD gates |
| [Webhooks](/api-reference/webhooks) | 4 | Pro+ | Real-time event notifications |
| [Teams](/api-reference/teams) | 3 | Pro+ | Multi-tenant collaboration |
| [Milestones](/api-reference/milestones) | 3 | Pro+ | Tag points in your timeline |
| [Anomalies](/api-reference/anomalies) | 2 | Pro+ | Behavioral anomaly detection |
| [Sharing](/api-reference/sharing) | 6 | Pro+ | Space sharing and access tokens |
| [API Keys](/api-reference/api-keys) | 4 | All | Key management and rotation |
| [Export](/api-reference/export) | 1 | Starter+ | Memory export (Markdown, JSON, CSV) |
| [Usage](/api-reference/usage) | 1 | All | Plan usage and limits |
| [System](/api-reference/system) | 3 | Public | Health checks (no auth required) |

:::note Migration in progress
API reference pages are being migrated section by section. Check back as more routers are documented.
:::
