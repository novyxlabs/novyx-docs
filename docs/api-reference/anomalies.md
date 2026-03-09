---
sidebar_position: 14
title: Anomalies
description: Behavioral anomaly detection surfaced through audit logs and memory operations.
---

# Anomalies

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Anomaly detection runs automatically on memory operations and surfaces through the [Audit](/api-reference/audit) router. Novyx monitors for unusual patterns — rapid bulk operations, unexpected deletions, and behavioral outliers — and flags them in your audit trail.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** Pro+

---

## How anomaly detection works

Anomaly detection is **not a separate API** — it runs inline during memory operations and reports through existing endpoints:

1. **Audit summary** — The `anomaly_count` field in `GET /v1/audit/summary` counts server errors (5xx) that may indicate anomalous behavior
2. **Audit verify** — `GET /v1/audit/verify` (Pro+) runs Sentinel validation to check SHA-256 integrity of all memories, detecting tampering
3. **Webhook alerts** — If you have webhooks configured, anomaly events are delivered in real-time

### Check for anomalies via audit summary

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

summary = nx.audit_summary(since="2026-03-08T00:00:00Z")
print(f"Total operations: {summary['total_operations']}")
print(f"Errors: {summary['error_count']}")
print(f"Anomalies: {summary['anomaly_count']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const summary = await nx.auditSummary({ since: "2026-03-08T00:00:00Z" });
console.log(`Total operations: ${summary.total_operations}`);
console.log(`Errors: ${summary.error_count}`);
console.log(`Anomalies: ${summary.anomaly_count}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/audit/summary?since=2026-03-08T00:00:00Z" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Verify memory integrity

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.audit_verify()
if result["valid"]:
    print("All memories pass integrity check")
else:
    print(f"Failures: {result['integrity_failures']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.auditVerify();
if (result.valid) {
  console.log("All memories pass integrity check");
} else {
  console.log(`Failures: ${result.integrity_failures}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/audit/verify \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "valid": true,
  "timestamp": "2026-03-09T12:00:00Z"
}
```

---

## Related endpoints

| Endpoint | What it tells you |
|----------|------------------|
| [`GET /v1/audit/summary`](/api-reference/audit) | `anomaly_count` — number of 5xx errors in the period |
| [`GET /v1/audit/verify`](/api-reference/audit) | SHA-256 integrity check across all memories |
| [`GET /v1/audit`](/api-reference/audit) | Full audit trail with per-entry status codes |
| [`POST /v1/webhooks`](/api-reference/webhooks) | Subscribe to anomaly events in real-time |
