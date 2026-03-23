---
sidebar_position: 4
title: "Novyx API: Audit — Cryptographic Memory Trail"
description: "Tamper-proof audit trail for every memory operation. Hash-chain verification, RSA signatures, and compliance-ready logging."
---

# Audit

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Every memory operation in Novyx is SHA-256 hashed and timestamped in a tamper-proof audit trail. Query the trail by operation type and time range, or export it for compliance.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Retention:** Free: 7 days · Starter: 14 days · Pro: 30 days · Enterprise: 90 days

---

## Audit Trail

```
GET /v1/audit
```

Get the cryptographic audit trail. Returns a paginated list of audit entries, each containing the operation type, affected memory, content hash, and timestamp.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | number | No | `50` | Max entries (1–1000) |
| `offset` | number | No | `0` | Pagination offset |
| `since` | string | No | — | ISO 8601 start timestamp. Only entries after this time are returned |
| `until` | string | No | — | ISO 8601 end timestamp. Only entries before this time are returned |
| `event_type` | string | No | — | Comma-separated filter: `create`, `update`, `delete`, `rollback` |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `entries` | array | Array of audit entries |
| `entries[].timestamp` | string | Operation timestamp (ISO 8601) |
| `entries[].operation` | string | Operation type: `create`, `update`, `delete`, `rollback` |
| `entries[].memory_id` | string | Affected memory ID |
| `entries[].content_hash` | string | SHA-256 hash of the content at that point |
| `entries[].agent_id` | string | Agent that performed the operation (if set) |
| `entries[].metadata` | object | Additional metadata (varies by operation) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

# Get recent audit entries
audit = nx.audit(limit=20)
for entry in audit["entries"]:
    print(f"[{entry['timestamp']}] {entry['operation']} — {entry['memory_id']}")

# Filter by operation type
creates = nx.audit(event_type="create", limit=50)

# Filter by time range
from_yesterday = nx.audit(since="2026-03-08T00:00:00Z")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

// Get recent audit entries
const audit = await nx.audit({ limit: 20 });
for (const entry of audit.entries) {
  console.log(`[${entry.timestamp}] ${entry.operation} — ${entry.memory_id}`);
}

// Filter by operation type
const creates = await nx.audit({ event_type: "create", limit: 50 });

// Filter by time range
const fromYesterday = await nx.audit({ since: "2026-03-08T00:00:00Z" });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# Get recent audit entries
curl "https://novyx-ram-api.fly.dev/v1/audit?limit=20" \
  -H "Authorization: Bearer nram_your_key"

# Filter by operation type
curl "https://novyx-ram-api.fly.dev/v1/audit?event_type=create&limit=50" \
  -H "Authorization: Bearer nram_your_key"

# Filter by time range
curl "https://novyx-ram-api.fly.dev/v1/audit?since=2026-03-08T00:00:00Z" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "entries": [
    {
      "timestamp": "2026-03-09T14:30:00Z",
      "operation": "create",
      "memory_id": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "content_hash": "e3b0c44298fc1c149afbf4c8996fb924...",
      "agent_id": "agent-001",
      "metadata": {}
    },
    {
      "timestamp": "2026-03-09T14:25:00Z",
      "operation": "update",
      "memory_id": "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "content_hash": "a7ffc6f8bf1ed76651c14756a061d662...",
      "agent_id": null,
      "metadata": {
        "fields_changed": ["observation", "importance"]
      }
    },
    {
      "timestamp": "2026-03-09T14:00:00Z",
      "operation": "rollback",
      "memory_id": null,
      "content_hash": null,
      "agent_id": null,
      "metadata": {
        "target": "2026-03-09T12:00:00Z",
        "restored": 3,
        "removed": 7
      }
    }
  ]
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Invalid `since`/`until` timestamp format or unknown event type filter |
| 429 | `RATE_LIMITED` | Exceeded plan API call quota |

---

## Export Audit Logs

```
GET /v1/audit/export
```

Export audit logs in CSV or JSON format for compliance, reporting, or external archival.

**Tier:** Starter+

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `format` | string | No | `"csv"` | Export format: `csv` or `json` |
| `since` | string | No | — | ISO 8601 start timestamp |
| `until` | string | No | — | ISO 8601 end timestamp |

### Response

Returns a file download:

| Format | Content-Type |
|--------|-------------|
| `csv` | `text/csv` |
| `json` | `application/json` |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
# Export as CSV
csv_data = nx.audit_export(format="csv")

# Export a specific time range as JSON
json_data = nx.audit_export(
    format="json",
    since="2026-03-01T00:00:00Z",
    until="2026-03-09T00:00:00Z",
)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
// Export as CSV
const csvData = await nx.auditExport({ format: "csv" });

// Export a specific time range as JSON
const jsonData = await nx.auditExport({
  format: "json",
  since: "2026-03-01T00:00:00Z",
  until: "2026-03-09T00:00:00Z",
});
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# Export as CSV
curl "https://novyx-ram-api.fly.dev/v1/audit/export?format=csv" \
  -H "Authorization: Bearer nram_your_key" \
  -o audit.csv

# Export a specific time range as JSON
curl "https://novyx-ram-api.fly.dev/v1/audit/export?format=json&since=2026-03-01T00:00:00Z&until=2026-03-09T00:00:00Z" \
  -H "Authorization: Bearer nram_your_key" \
  -o audit.json
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `TIER_REQUIRED` | Audit export requires Starter plan or higher |

---

## How the audit trail works

Every memory operation (create, update, delete, rollback) generates an audit entry with:

1. **Timestamp** — when the operation happened (server time, UTC)
2. **Operation** — what happened (`create`, `update`, `delete`, `rollback`)
3. **Memory ID** — which memory was affected (null for rollback operations)
4. **Content hash** — SHA-256 hash of the memory content at that point

The audit trail is **append-only** — entries cannot be modified or deleted. This makes it suitable for compliance scenarios where you need a tamper-proof record of all data operations.

### Verification

You can independently verify any audit entry by:

1. Retrieving the memory content at the recorded timestamp
2. Computing the SHA-256 hash
3. Comparing it to the `content_hash` in the audit entry

For cryptographic chain verification with RSA signatures, see the [Traces API](/api-reference/traces).
