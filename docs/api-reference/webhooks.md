---
sidebar_position: 11
title: "Novyx API: Webhooks — 6 Endpoints for Event Notifications"
description: "Get notified when memories change. Register webhook endpoints for memory events, rollbacks, and audit alerts."
---

# Webhooks

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Register HTTPS endpoints to receive real-time notifications when memory events occur. Supports raw JSON, Slack, and Discord payload formats.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** Pro+

---

## Create Webhook

```
POST /v1/webhooks
```

Register a new webhook endpoint to receive memory events.

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `url` | string | **Yes** | — | HTTPS URL to receive events |
| `events` | string[] | **Yes** | — | Event types to subscribe to |
| `description` | string | No | — | Human-readable description (max 200 chars) |
| `format` | string | No | `"raw"` | Payload format: `raw`, `slack`, or `discord` |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `webhook_id` | string | Unique webhook identifier |
| `url` | string | Registered URL |
| `events` | string[] | Subscribed event types |
| `active` | boolean | Whether the webhook is active |
| `description` | string \| null | Description |
| `format` | string | Payload format |
| `created_at` | string | ISO 8601 timestamp |
| `updated_at` | string | ISO 8601 timestamp |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

webhook = nx.create_webhook(
    url="https://example.com/hooks/novyx",
    events=["memory.created", "memory.deleted", "rollback.completed"],
    description="Production memory alerts",
)
print(webhook["webhook_id"])
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const webhook = await nx.createWebhook({
  url: "https://example.com/hooks/novyx",
  events: ["memory.created", "memory.deleted", "rollback.completed"],
  description: "Production memory alerts",
});
console.log(webhook.webhook_id);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/webhooks \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/hooks/novyx",
    "events": ["memory.created", "memory.deleted", "rollback.completed"],
    "description": "Production memory alerts"
  }'
```

</TabItem>
</Tabs>

### Response

```json
{
  "webhook_id": "wh_a1b2c3d4",
  "url": "https://example.com/hooks/novyx",
  "events": ["memory.created", "memory.deleted", "rollback.completed"],
  "active": true,
  "description": "Production memory alerts",
  "format": "raw",
  "created_at": "2026-03-09T12:00:00Z",
  "updated_at": "2026-03-09T12:00:00Z"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |
| 422 | `VALIDATION_ERROR` | Invalid URL (must be HTTPS) or empty events list |

---

## List Webhooks

```
GET /v1/webhooks
```

List all registered webhooks.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `webhooks` | array | Array of webhook objects |
| `total_count` | number | Total webhooks |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.list_webhooks()
for wh in result["webhooks"]:
    print(f"{wh['webhook_id']}: {wh['url']} ({', '.join(wh['events'])})")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.listWebhooks();
for (const wh of result.webhooks) {
  console.log(`${wh.webhook_id}: ${wh.url} (${wh.events.join(", ")})`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/webhooks \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

---

## Get Webhook

```
GET /v1/webhooks/{webhook_id}
```

Retrieve a single webhook by ID.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhook_id` | string | Webhook identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
webhook = nx.get_webhook("wh_a1b2c3d4")
print(f"Active: {webhook['active']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const webhook = await nx.getWebhook("wh_a1b2c3d4");
console.log(`Active: ${webhook.active}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/webhooks/wh_a1b2c3d4 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Webhook does not exist |

---

## Update Webhook

```
PUT /v1/webhooks/{webhook_id}
```

Update a webhook. Send only the fields you want to change.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhook_id` | string | Webhook identifier |

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `url` | string | No | New HTTPS URL |
| `events` | string[] | No | Updated event types |
| `active` | boolean | No | Enable or disable |
| `description` | string | No | Updated description (max 200 chars) |
| `format` | string | No | Payload format: `raw`, `slack`, or `discord` |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
updated = nx.update_webhook(
    "wh_a1b2c3d4",
    events=["memory.created", "memory.updated", "memory.deleted"],
    format="slack",
)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const updated = await nx.updateWebhook("wh_a1b2c3d4", {
  events: ["memory.created", "memory.updated", "memory.deleted"],
  format: "slack",
});
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X PUT https://novyx-ram-api.fly.dev/v1/webhooks/wh_a1b2c3d4 \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "events": ["memory.created", "memory.updated", "memory.deleted"],
    "format": "slack"
  }'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Webhook does not exist |
| 422 | `VALIDATION_ERROR` | Invalid URL or event types |

---

## Delete Webhook

```
DELETE /v1/webhooks/{webhook_id}
```

Delete a webhook and stop receiving events.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhook_id` | string | Webhook identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.delete_webhook("wh_a1b2c3d4")
print(result["success"])  # True
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.deleteWebhook("wh_a1b2c3d4");
console.log(result.success); // true
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X DELETE https://novyx-ram-api.fly.dev/v1/webhooks/wh_a1b2c3d4 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "success": true,
  "webhook_id": "wh_a1b2c3d4"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Webhook does not exist |

---

## Delivery History

```
GET /v1/webhooks/{webhook_id}/deliveries
```

View recent delivery attempts for a webhook.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `webhook_id` | string | Webhook identifier |

### Query parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | number | No | `20` | Max results (1–100) |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `deliveries` | array | Array of delivery records |
| `total_count` | number | Total deliveries |

Each delivery includes:

| Field | Type | Description |
|-------|------|-------------|
| `delivery_id` | string | Delivery identifier |
| `event_type` | string | Event that triggered the delivery |
| `status_code` | number | HTTP response status |
| `success` | boolean | Whether delivery succeeded |
| `attempt` | number | Attempt number |
| `error` | string \| null | Error message if failed |
| `created_at` | string | ISO 8601 timestamp |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
deliveries = nx.webhook_deliveries("wh_a1b2c3d4", limit=10)
for d in deliveries["deliveries"]:
    status = "ok" if d["success"] else f"failed ({d['error']})"
    print(f"{d['event_type']}: {status}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const deliveries = await nx.webhookDeliveries("wh_a1b2c3d4", { limit: 10 });
for (const d of deliveries.deliveries) {
  const status = d.success ? "ok" : `failed (${d.error})`;
  console.log(`${d.event_type}: ${status}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl "https://novyx-ram-api.fly.dev/v1/webhooks/wh_a1b2c3d4/deliveries?limit=10" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "deliveries": [
    {
      "delivery_id": "del_x1y2z3",
      "event_type": "memory.created",
      "status_code": 200,
      "success": true,
      "attempt": 1,
      "error": null,
      "created_at": "2026-03-09T14:30:00Z"
    }
  ],
  "total_count": 24
}
```
