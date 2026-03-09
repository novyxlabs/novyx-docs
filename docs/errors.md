---
title: Error Reference
description: HTTP status codes, error messages, and troubleshooting for Novyx API errors.
---

# Error Reference

All API errors return a consistent JSON shape:

```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "status": 400
}
```

## Status codes

| Code | Meaning | Common cause |
|------|---------|--------------|
| `400` | Bad Request | Missing required field, invalid parameter |
| `401` | Unauthorized | Missing or invalid API key |
| `403` | Forbidden | Feature requires a higher tier |
| `404` | Not Found | Memory, space, or resource doesn't exist |
| `409` | Conflict | Concurrent write conflict (see [conflict resolution](/concepts/conflict-resolution)) |
| `429` | Rate Limited | Exceeded plan rate limit or quota |
| `500` | Internal Error | Server error — retry or contact support |

## Rate limiting (429)

When you hit a rate limit, the response includes your current usage:

```json
{
  "error": "Rate limit exceeded",
  "code": "RATE_LIMITED",
  "status": 429,
  "usage": {
    "current": 5000,
    "limit": 5000,
    "plan": "free",
    "resets_at": "2026-04-01T00:00:00Z"
  },
  "upgrade_url": "https://www.novyxlabs.com/pricing"
}
```

:::info Your agent keeps working
We never crash your agent and never silently drop requests. Rate-limited responses always include usage stats and an upgrade path.
:::

## Tier gating (403)

When you call a Pro+ endpoint on a Free or Starter plan:

```json
{
  "error": "This feature requires Pro or higher",
  "code": "TIER_REQUIRED",
  "required_tier": "pro",
  "current_tier": "free"
}
```
