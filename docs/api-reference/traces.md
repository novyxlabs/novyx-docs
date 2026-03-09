---
sidebar_position: 5
title: Traces
description: RSA-signed execution traces — record, verify, and certify your agent's reasoning chain.
---

# Traces

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Record every step of your agent's reasoning chain as a cryptographic trace. Each step is hash-chained to the previous one. Completed traces are RSA-4096 signed and independently verifiable. Export portable certificates for compliance or auditing.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** Pro+

---

## Start Trace

```
POST /v1/traces
```

Start a new trace session for recording an agent's reasoning chain.

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `agent_id` | string | **Yes** | — | Agent identifier |
| `description` | string | No | — | Trace description |
| `tags` | string[] | No | `[]` | Tags for filtering |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `trace_id` | string | Trace identifier |
| `status` | string | Trace status (`active`) |
| `created_at` | string | Creation timestamp |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

trace = nx.start_trace(
    agent_id="agent-001",
    description="Customer support conversation",
    tags=["support", "billing"],
)
trace_id = trace["trace_id"]
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const trace = await nx.startTrace({
  agentId: "agent-001",
  description: "Customer support conversation",
  tags: ["support", "billing"],
});
const traceId = trace.trace_id;
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/traces \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_id": "agent-001",
    "description": "Customer support conversation",
    "tags": ["support", "billing"]
  }'
```

</TabItem>
</Tabs>

### Response

```json
{
  "trace_id": "trc_a1b2c3d4e5f6",
  "status": "active",
  "created_at": "2026-03-09T15:00:00Z"
}
```

---

## Add Step

```
POST /v1/traces/{trace_id}/steps
```

Add a step to an active trace. Each step is integrity-chained — its hash includes the previous step's hash, forming an unbreakable chain.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `trace_id` | string | Trace identifier |

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `type` | string | **Yes** | — | Step type (see below) |
| `content` | string | **Yes** | — | Step content |
| `metadata` | object | No | `{}` | Additional metadata |

**Step types:**

| Type | Description |
|------|-------------|
| `THOUGHT` | Internal reasoning or planning |
| `ACTION` | External action taken (API call, tool use) |
| `OBSERVATION` | Result of an action |
| `OUTPUT` | Final output to user |
| `ERROR` | Error encountered |
| `POLICY_CHECK` | Safety or policy validation |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `step_id` | string | Step identifier |
| `integrity_chain_hash` | string | SHA-256 chain hash (includes previous step) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# Record the agent's reasoning chain
nx.add_trace_step(trace_id, type="THOUGHT", content="User is asking about their billing cycle")
nx.add_trace_step(trace_id, type="ACTION", content="Looking up account billing info")
nx.add_trace_step(trace_id, type="OBSERVATION", content="Account is on Pro plan, billing cycle starts March 1")
nx.add_trace_step(trace_id, type="OUTPUT", content="Your Pro plan renews on March 1st each month.")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// Record the agent's reasoning chain
await nx.addTraceStep(traceId, { type: "THOUGHT", content: "User is asking about their billing cycle" });
await nx.addTraceStep(traceId, { type: "ACTION", content: "Looking up account billing info" });
await nx.addTraceStep(traceId, { type: "OBSERVATION", content: "Account is on Pro plan, billing cycle starts March 1" });
await nx.addTraceStep(traceId, { type: "OUTPUT", content: "Your Pro plan renews on March 1st each month." });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/traces/trc_a1b2c3d4e5f6/steps \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"type": "THOUGHT", "content": "User is asking about their billing cycle"}'
```

</TabItem>
</Tabs>

### Response

```json
{
  "step_id": "stp_f6e5d4c3b2a1",
  "integrity_chain_hash": "a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a"
}
```

---

## Complete Trace

```
POST /v1/traces/{trace_id}/complete
```

Seal and cryptographically sign a trace. After completion, no more steps can be added. The trace is signed with RSA-4096, producing a verifiable signature.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `trace_id` | string | Trace identifier |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `integrity_root_hash` | string | Root hash of the integrity chain |
| `signature` | string | RSA-4096 signature of the root hash |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.complete_trace(trace_id)
print(f"Root hash: {result['integrity_root_hash']}")
print(f"Signature: {result['signature'][:40]}...")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.completeTrace(traceId);
console.log(`Root hash: ${result.integrity_root_hash}`);
console.log(`Signature: ${result.signature.slice(0, 40)}...`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/traces/trc_a1b2c3d4e5f6/complete \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "integrity_root_hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "signature": "MGYCMQDJnGm1LQ3..."
}
```

---

## List Traces

```
GET /v1/traces
```

List traces with optional filters by agent, status, and pagination.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `agent_id` | string | No | — | Filter by agent |
| `status` | string | No | — | Filter: `active`, `completed`, `failed`, `interrupted` |
| `limit` | number | No | `20` | Max results (1–100) |
| `offset` | number | No | `0` | Pagination offset |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `traces` | array | Array of trace objects |
| `total` | number | Total matching traces |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# List all traces
traces = nx.list_traces(limit=10)

# Filter by agent and status
completed = nx.list_traces(agent_id="agent-001", status="completed")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// List all traces
const traces = await nx.listTraces({ limit: 10 });

// Filter by agent and status
const completed = await nx.listTraces({ agentId: "agent-001", status: "completed" });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# List all traces
curl "https://novyx-ram-api.fly.dev/v1/traces?limit=10" \
  -H "Authorization: Bearer nram_your_key"

# Filter by agent and status
curl "https://novyx-ram-api.fly.dev/v1/traces?agent_id=agent-001&status=completed" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

---

## Get Trace

```
GET /v1/traces/{trace_id}
```

Get a trace with all its steps. Returns the full reasoning chain in order.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `trace_id` | string | Trace identifier |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `trace` | object | Trace metadata (id, agent_id, status, created_at, completed_at) |
| `steps` | array | Ordered array of step objects |
| `step_count` | number | Total steps in the trace |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
trace = nx.get_trace("trc_a1b2c3d4e5f6")
print(f"Status: {trace['trace']['status']}")
print(f"Steps: {trace['step_count']}")
for step in trace["steps"]:
    print(f"  [{step['type']}] {step['content']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const trace = await nx.getTrace("trc_a1b2c3d4e5f6");
console.log(`Status: ${trace.trace.status}`);
console.log(`Steps: ${trace.step_count}`);
for (const step of trace.steps) {
  console.log(`  [${step.type}] ${step.content}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/traces/trc_a1b2c3d4e5f6 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "trace": {
    "trace_id": "trc_a1b2c3d4e5f6",
    "agent_id": "agent-001",
    "status": "completed",
    "description": "Customer support conversation",
    "created_at": "2026-03-09T15:00:00Z",
    "completed_at": "2026-03-09T15:02:30Z"
  },
  "steps": [
    {
      "step_id": "stp_001",
      "step_index": 0,
      "type": "THOUGHT",
      "content": "User is asking about their billing cycle",
      "integrity_hash": "e3b0c442...",
      "chain_hash": "a7ffc6f8...",
      "previous_chain_hash": null,
      "created_at": "2026-03-09T15:00:01Z"
    },
    {
      "step_id": "stp_002",
      "step_index": 1,
      "type": "ACTION",
      "content": "Looking up account billing info",
      "integrity_hash": "b8c1d553...",
      "chain_hash": "c9e2f664...",
      "previous_chain_hash": "a7ffc6f8...",
      "created_at": "2026-03-09T15:00:02Z"
    }
  ],
  "step_count": 4
}
```

---

## Verify Trace Integrity

```
POST /v1/traces/{trace_id}/verify
```

Verify the cryptographic integrity of a completed trace. Checks that the hash chain is intact and the RSA signature is valid.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `trace_id` | string | Trace identifier |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `valid` | boolean | Overall validity (chain + signature) |
| `chain_valid` | boolean | Whether the hash chain is intact |
| `signature_valid` | boolean | Whether the RSA signature is valid |
| `discrepancies` | array | List of any integrity issues (empty if valid) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.verify_trace("trc_a1b2c3d4e5f6")
if result["valid"]:
    print("Trace integrity verified — chain and signature are valid")
else:
    print(f"Integrity issues: {result['discrepancies']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.verifyTrace("trc_a1b2c3d4e5f6");
if (result.valid) {
  console.log("Trace integrity verified — chain and signature are valid");
} else {
  console.log(`Integrity issues: ${JSON.stringify(result.discrepancies)}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/traces/trc_a1b2c3d4e5f6/verify \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "valid": true,
  "chain_valid": true,
  "signature_valid": true,
  "discrepancies": []
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `TRACE_NOT_COMPLETED` | Trace must be completed before verification |
| 404 | `NOT_FOUND` | Trace does not exist |

---

## Get Trace Certificate

```
GET /v1/traces/{trace_id}/certificate
```

Get a portable integrity certificate for a completed trace. The certificate includes the trace metadata, root hash, RSA signature, and the public key needed for independent verification.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `trace_id` | string | Trace identifier |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `trace_id` | string | Trace identifier |
| `integrity_root_hash` | string | Root hash of the integrity chain |
| `signature` | string | RSA-4096 signature |
| `public_key` | string | Public key (PEM format) for independent verification |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
cert = nx.get_trace_certificate("trc_a1b2c3d4e5f6")
print(f"Root hash: {cert['integrity_root_hash']}")
# Save certificate for external verification
import json
with open("trace_certificate.json", "w") as f:
    json.dump(cert, f, indent=2)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const cert = await nx.getTraceCertificate("trc_a1b2c3d4e5f6");
console.log(`Root hash: ${cert.integrity_root_hash}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/traces/trc_a1b2c3d4e5f6/certificate \
  -H "Authorization: Bearer nram_your_key" \
  -o trace_certificate.json
```

</TabItem>
</Tabs>

---

## Get Public Key

```
GET /v1/traces/public-key
```

Get the public key used for verifying trace signatures. **No authentication required** — anyone can verify a trace independently.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `public_key` | string | RSA public key (PEM format) |
| `algorithm` | string | Signing algorithm (e.g. `RSA-SHA256`) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# No auth required
import requests
resp = requests.get("https://novyx-ram-api.fly.dev/v1/traces/public-key")
public_key = resp.json()["public_key"]
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// No auth required
const resp = await fetch("https://novyx-ram-api.fly.dev/v1/traces/public-key");
const { public_key } = await resp.json();
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# No authentication needed
curl https://novyx-ram-api.fly.dev/v1/traces/public-key
```

</TabItem>
</Tabs>

---

## End-to-end workflow

A complete trace lifecycle:

```
1. Start trace        → POST /v1/traces
2. Add steps          → POST /v1/traces/{id}/steps  (repeat)
3. Complete trace     → POST /v1/traces/{id}/complete
4. Verify integrity   → POST /v1/traces/{id}/verify
5. Export certificate  → GET  /v1/traces/{id}/certificate
```

### Independent verification

Anyone can verify a Novyx trace certificate without an API key:

1. **Get the public key** from `/v1/traces/public-key`
2. **Compute** the SHA-256 hash of the trace steps in order
3. **Verify** the RSA signature against the root hash using the public key

This makes traces suitable for regulatory compliance, legal evidence, and third-party auditing.
