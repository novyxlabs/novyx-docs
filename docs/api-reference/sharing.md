---
sidebar_position: 15
title: Sharing
description: Share memory spaces across tenants with token-based invitations and role-based access.
---

# Sharing

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Share memory spaces with other Novyx tenants using secure, token-based invitations. Grant read or write access, rotate tokens, and revoke access at any time.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** Pro+

---

## Share Space

```
POST /v1/spaces/share
```

Create a share invitation for a memory space. Sends a token the recipient can use to join.

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `tag` | string | **Yes** | — | Tag or space to share (1–50 characters) |
| `email` | string | **Yes** | — | Recipient's email address |
| `permission` | string | No | `"read"` | Access level: `read` or `write` |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `token` | string | Share token for the recipient |
| `share_url` | string | Full invitation URL |
| `tag` | string | Shared tag/space |
| `shared_with_email` | string | Recipient email |
| `permission` | string | Access level |
| `expires_at` | string \| null | Token expiry (ISO 8601) |
| `message` | string | Confirmation message |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

share = nx.share_space(
    tag="customer-support",
    email="alice@example.com",
    permission="write",
)
print(share["share_url"])
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const share = await nx.shareSpace({
  tag: "customer-support",
  email: "alice@example.com",
  permission: "write",
});
console.log(share.share_url);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/spaces/share \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "tag": "customer-support",
    "email": "alice@example.com",
    "permission": "write"
  }'
```

</TabItem>
</Tabs>

### Response

```json
{
  "token": "shr_x1y2z3a4b5c6",
  "share_url": "https://novyx-ram-api.fly.dev/v1/spaces/join?token=shr_x1y2z3a4b5c6",
  "tag": "customer-support",
  "shared_with_email": "alice@example.com",
  "permission": "write",
  "expires_at": null,
  "message": "Space shared successfully"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Invalid tag or email |
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |

---

## List Shared Spaces

```
GET /v1/spaces/shared
```

List spaces you've shared and spaces shared with you.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `shared_by_me` | array | Spaces you've shared (owner view) |
| `shared_with_me` | array | Spaces shared to you |

Each entry includes:

| Field | Type | Description |
|-------|------|-------------|
| `token` | string | Share token |
| `tag` | string | Shared tag/space |
| `permission` | string | `read` or `write` |
| `owner_tenant_id` | string | Owner's tenant ID |
| `shared_with_email` | string | Recipient email |
| `accepted` | boolean | Whether the invitation was accepted |
| `accepted_by_tenant` | string \| null | Accepting tenant ID |
| `created_at` | string | ISO 8601 timestamp |
| `expires_at` | string \| null | Token expiry |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.list_shared()
for share in result["shared_by_me"]:
    status = "accepted" if share["accepted"] else "pending"
    print(f"{share['tag']} → {share['shared_with_email']} ({status})")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.listShared();
for (const share of result.shared_by_me) {
  const status = share.accepted ? "accepted" : "pending";
  console.log(`${share.tag} → ${share.shared_with_email} (${status})`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/spaces/shared \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

---

## Preview Share Token

```
GET /v1/spaces/token/{token}
```

Preview a share invitation before accepting it. No authentication required.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `token` | string | Share token |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `valid` | boolean | Whether the token is valid |
| `owner_tenant_id` | string | Owner's tenant ID (if valid) |
| `tag` | string | Shared space (if valid) |
| `permission` | string | Access level (if valid) |
| `already_accepted` | boolean | Whether already accepted |
| `expires_at` | string \| null | Token expiry |
| `error` | string \| null | Error message (if invalid) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
info = nx.preview_share("shr_x1y2z3a4b5c6")
if info["valid"]:
    print(f"Space: {info['tag']} ({info['permission']} access)")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const info = await nx.previewShare("shr_x1y2z3a4b5c6");
if (info.valid) {
  console.log(`Space: ${info.tag} (${info.permission} access)`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/spaces/token/shr_x1y2z3a4b5c6
```

</TabItem>
</Tabs>

---

## Accept Share

```
POST /v1/spaces/join
```

Accept a share invitation and gain access to the shared space.

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `token` | string | **Yes** | Share token from the invitation |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Whether join succeeded |
| `tag` | string | Shared space |
| `owner_tenant_id` | string | Owner's tenant ID |
| `permission` | string | Granted access level |
| `expires_at` | string \| null | Access expiry |
| `message` | string | Confirmation message |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.join_space(token="shr_x1y2z3a4b5c6")
print(f"Joined {result['tag']} with {result['permission']} access")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.joinSpace({ token: "shr_x1y2z3a4b5c6" });
console.log(`Joined ${result.tag} with ${result.permission} access`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/spaces/join \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"token": "shr_x1y2z3a4b5c6"}'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `INVALID_TOKEN` | Token expired or invalid |
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |

---

## Rotate Share Token

```
POST /v1/spaces/share/{token}/rotate
```

Generate a new token for an existing share, invalidating the old one. Owner only.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `token` | string | Current share token |

### Response fields

Same as [Share Space](#share-space) with the new token.

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.rotate_share("shr_x1y2z3a4b5c6")
print(f"New token: {result['token']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.rotateShare("shr_x1y2z3a4b5c6");
console.log(`New token: ${result.token}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/spaces/share/shr_x1y2z3a4b5c6/rotate \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FORBIDDEN` | Not the share owner |
| 404 | `NOT_FOUND` | Token does not exist |

---

## Revoke Share

```
DELETE /v1/spaces/share/{token}
```

Revoke a share invitation and remove the recipient's access. Owner only.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `token` | string | Share token to revoke |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
nx.revoke_share("shr_x1y2z3a4b5c6")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
await nx.revokeShare("shr_x1y2z3a4b5c6");
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X DELETE https://novyx-ram-api.fly.dev/v1/spaces/share/shr_x1y2z3a4b5c6 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

Returns `204 No Content` on success.

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FORBIDDEN` | Not the share owner |
| 404 | `NOT_FOUND` | Token does not exist |
