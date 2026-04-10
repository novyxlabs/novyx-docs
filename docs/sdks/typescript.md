---
title: "Novyx JavaScript SDK — TypeScript-First Agent Memory"
description: "npm install novyx. TypeScript-first SDK with full type definitions for building agents with persistent, inspectable memory."
---

# TypeScript / JavaScript SDK

`npm install novyx` — 60+ methods with full TypeScript types.

:::caution Breaking change in 3.1.0
`nx.createAgent()` now requires `provider` (typed as `"openai" | "anthropic" | "litellm"`) and `model`. The previous OpenAI default was removed in Phase 3 of the governance shipment. See the [novyx-agent 2.0 upgrade guide](../agent-sdk/upgrade-to-2.0).
:::

:::tip New in 3.2.0 — `nx.submitAction()`
Typed wrapper around `POST /v1/actions` for the main cloud governance flow. Distinct from the legacy `nx.actionSubmit()` which targets a separate Control instance via `control_url`. See the [Control section](../control/approval-workflows#polling-pattern) for the recommended pattern.
:::

## Installation

```bash
npm install novyx
# or
yarn add novyx
# or
pnpm add novyx
```

## Quick Start

```typescript
import { Novyx } from 'novyx';

const nx = new Novyx({ apiKey: 'nram_...' });

// Store a memory
const result = await nx.remember('User prefers dark mode', { tags: ['preferences'] });

// Recall semantically
const memories = await nx.recall('user preferences');

// Rollback
await nx.rollback('2 hours ago');
```

## Core Methods

The JS/TS SDK has full parity with the Python SDK. All methods return Promises.

### Memory

```typescript
await nx.remember(observation, { tags, importance, context, agentId, spaceId, ttlSeconds })
await nx.recall(query, { tags, limit, minScore })
await nx.memories({ tags, limit, offset })
await nx.memory(memoryId)
await nx.forget(memoryId)
await nx.supersede(oldId, newId)
await nx.stats()
await nx.memoryHealth()
```

### Rollback & Audit

```typescript
await nx.rollback(target)          // "2 hours ago", ISO timestamp
await nx.rollbackPreview(target)
await nx.rollbackHistory(limit)
await nx.audit({ limit, offset })
await nx.auditVerify()
```

### Knowledge Graph

```typescript
await nx.addTriple(subject, predicate, object)
await nx.queryTriples({ subject, predicate, object })
await nx.deleteTriple(tripleId)
await nx.listEntities({ limit, offset })
await nx.getEntity(entityId)
await nx.deleteEntity(entityId)
```

### Context Spaces

```typescript
await nx.createSpace(name, description)
await nx.listSpaces()
await nx.getSpace(spaceId)
await nx.updateSpace(spaceId, { name, description })
await nx.deleteSpace(spaceId)
await nx.spaceMemories(spaceId, { limit, offset })
await nx.shareContext({ tags, targetTenant })
```

### Replay (Pro+)

```typescript
await nx.replayTimeline({ limit, offset })
await nx.replaySnapshot(at, { limit })
await nx.replayMemory(memoryId)
await nx.replayRecall(query, at, { limit })
await nx.replayDiff(fromTs, toTs)
```

### Cortex (Pro+)

```typescript
await nx.cortexStatus()
await nx.cortexRun()
await nx.cortexInsights({ limit, offset })
```

### Eval

```typescript
await nx.evalRun({ minScore })
await nx.evalGate(minScore)        // Throws if health below threshold
await nx.evalHistory({ limit })
await nx.evalDrift({ days })
```

### Control — Actions & Approvals

```typescript
// Recommended: typed wrapper for the main cloud governance flow (3.2.0+)
await nx.submitAction(action, params, { agent_id })
//   → { action, status, policy_result, message, trace_id }
//     status is one of "allowed" | "blocked" | "pending_review"

await nx.actionStatus(actionId)
await nx.actionList({ status, limit })
await nx.policyCheck()
await nx.listApprovals({ limit, statusFilter })
await nx.approveAction(approvalId, { decision, reason, approverId })
await nx.explainAction(actionId)

// Legacy: separate Control instance via control_url (strata.action.v0 envelope)
await nx.actionSubmit(connector, operation, payload)
```

### Control — Custom Policies (new in 3.1.0)

```typescript
await nx.createPolicy({
  name: 'pii_protection',
  rules: [{ match: '(ssn|passport)', severity: 'critical' }],
  description: 'Block PII exposure',
  whitelisted_domains: ['internal.company.com'],
  agent_id: 'billing-bot',  // optional — Pro+ for agent-scoped
})

await nx.listPolicies({ agent_id: 'billing-bot' })
await nx.getPolicy('pii_protection', { agent_id: 'billing-bot' })
await nx.updatePolicy('pii_protection', { rules: [...] })
await nx.deletePolicy('pii_protection', { agent_id: 'billing-bot' })
```

All five accept optional `agent_id` for [agent-scoped policies](../control/agent-scoped-policies) (Pro+).

### Control — Governance Dashboard (new in 3.1.0)

```typescript
// Aggregated governance stats — totals, violations by policy/agent, time-series
await nx.governanceDashboard({ window: '7d', bucket: 'day' })

// Per-agent violation history
await nx.agentViolations('billing-bot', { limit: 20, since: '2026-04-01T00:00:00Z' })
```

Both require the `governance_dashboard` feature (Starter+).

### Tenant Dashboard

```typescript
await nx.dashboard()  // Aggregated stats — memory count, tier, usage, pressure
```

## Error Handling

```typescript
import { Novyx, NovyxError } from 'novyx';

try {
  await nx.remember('something');
} catch (e) {
  if (e instanceof NovyxError) {
    console.error(`${e.statusCode}: ${e.message}`);
  }
}
```

## Configuration

```typescript
const nx = new Novyx({
  apiKey: 'nram_...',           // Required (or set NOVYX_API_KEY env var)
  baseUrl: 'https://...',      // Optional, defaults to Novyx Cloud
  timeout: 30000,              // Optional, request timeout in ms
});
```
