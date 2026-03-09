---
sidebar_position: 17
title: Export
description: Export audit logs as CSV, JSON, or JSONL files with date range filtering.
---

# Export

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Export your audit trail as a downloadable file. Supports CSV, JSON, and JSONL formats with optional date range filtering.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** Starter+

:::tip
Memory export is available via `GET /v1/memories/export` — see the [Memories](/api-reference/memories#export-memories) reference. This page covers audit log export.
:::

---

## Export Audit Logs

```
GET /v1/audit/export
```

Download your audit trail as a file.

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `format` | string | No | `"csv"` | Export format: `csv`, `json`, or `jsonl` |
| `since` | string | No | — | Start of range (ISO 8601) |
| `until` | string | No | — | End of range (ISO 8601) |

### Response

Returns a file download. Content-Type varies by format:

| Format | Content-Type |
|--------|-------------|
| `csv` | `text/csv` |
| `json` | `application/json` |
| `jsonl` | `application/x-ndjson` |

CSV columns: `timestamp`, `operation`, `agent_id`, `artifact_id`, `content_hash`

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

# Export as CSV
data = nx.export_audit(format="csv")

# Export with date range
data = nx.export_audit(
    format="json",
    since="2026-03-01T00:00:00Z",
    until="2026-03-09T00:00:00Z",
)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

// Export as CSV
const data = await nx.exportAudit({ format: "csv" });

// Export with date range
const filtered = await nx.exportAudit({
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

# Export as JSON with date range
curl "https://novyx-ram-api.fly.dev/v1/audit/export?format=json&since=2026-03-01T00:00:00Z" \
  -H "Authorization: Bearer nram_your_key" \
  -o audit.json
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Starter+ plan |
| 422 | `INVALID_RANGE` | `since` must be before `until` |
