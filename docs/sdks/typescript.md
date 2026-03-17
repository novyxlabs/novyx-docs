---
title: TypeScript / JavaScript SDK
description: TypeScript SDK for Novyx Core — persistent memory, rollback, audit, and eval for AI agents.
---

# TypeScript / JavaScript SDK

`npm install novyx` — 50+ methods with full TypeScript types.

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

### Control (Actions & Approval)

```typescript
await nx.actionSubmit(action, tool, params, riskLevel)
await nx.actionStatus(actionId)
await nx.actionList(status)
await nx.policyCheck(action, tool, params)
await nx.approveAction(approvalId, { decision })
```

### Dashboard

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
