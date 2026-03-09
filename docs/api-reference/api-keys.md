---
sidebar_position: 16
title: API Keys
description: Create accounts, verify emails, rotate and revoke API keys.
---

# API Keys

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Manage API keys — sign up for a new account, verify your email, rotate keys with grace periods, list active keys, and revoke compromised ones.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** All (signup is public)

---

## Sign Up

```
POST /v1/keys
```

Create a new Novyx account. Sends a verification email — your API key activates after verification.

:::note Public endpoint
No authentication required. Rate limited to 2 signups per IP per 30 days.
:::

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `email` | string | **Yes** | Valid email address (disposable domains rejected) |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `api_key` | null | Always null until email is verified |
| `tier` | string | `free` |
| `created_at` | string | ISO 8601 timestamp |
| `message` | string | Instructions to check email |
| `requires_verification` | boolean | Always `true` |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
import requests

r = requests.post(
    "https://novyx-ram-api.fly.dev/v1/keys",
    json={"email": "alice@example.com"},
)
print(r.json()["message"])  # Check your email to verify
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const res = await fetch("https://novyx-ram-api.fly.dev/v1/keys", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ email: "alice@example.com" }),
});
const data = await res.json();
console.log(data.message);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/keys \
  -H "Content-Type: application/json" \
  -d '{"email": "alice@example.com"}'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Disposable email domain |
| 429 | `RATE_LIMITED` | Too many signups from this IP or email |

---

## Verify Email

```
POST /v1/verify
```

Verify your email and activate your API key using the token from the verification email.

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `token` | string | **Yes** | Verification token from email |
| `email` | string | **Yes** | Email address |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `api_key` | string | Your activated API key |
| `tier` | string | Account tier |
| `message` | string | Confirmation message |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
r = requests.post(
    "https://novyx-ram-api.fly.dev/v1/verify",
    json={"token": "abc123", "email": "alice@example.com"},
)
print(r.json()["api_key"])  # nram_...
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const res = await fetch("https://novyx-ram-api.fly.dev/v1/verify", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ token: "abc123", email: "alice@example.com" }),
});
const data = await res.json();
console.log(data.api_key); // nram_...
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/verify \
  -H "Content-Type: application/json" \
  -d '{"token": "abc123", "email": "alice@example.com"}'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `INVALID_TOKEN` | Token expired or invalid |
| 404 | `NOT_FOUND` | No pending key for this email |

---

## Rotate Key

```
POST /v1/keys/rotate
```

Generate a new API key and deprecate the old one. The old key remains valid during a grace period.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `new_key` | string | Your new API key |
| `grace_expires_at` | string \| null | When the old key stops working (ISO 8601) |
| `message` | string | Confirmation message |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

result = nx.rotate_key()
print(f"New key: {result['new_key']}")
print(f"Old key valid until: {result['grace_expires_at']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const result = await nx.rotateKey();
console.log(`New key: ${result.new_key}`);
console.log(`Old key valid until: ${result.grace_expires_at}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/keys/rotate \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "new_key": "nram_new_abc123_...",
  "grace_expires_at": "2026-03-16T12:00:00Z",
  "message": "Key rotated. Old key valid during grace period."
}
```

---

## List Keys

```
GET /v1/keys
```

List all API keys for your account with their status.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `keys` | array | Array of key info objects |

Each key includes:

| Field | Type | Description |
|-------|------|-------------|
| `key_id` | string | Key identifier |
| `key_prefix` | string | First characters of the key |
| `tier` | string | Plan tier |
| `created_at` | string | Creation timestamp |
| `expires_at` | string \| null | Expiry timestamp |
| `grace_expires_at` | string \| null | Grace period end |
| `revoked_at` | string \| null | Revocation timestamp |
| `status` | string | `active`, `expired`, `revoked`, or `grace` |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.list_keys()
for key in result["keys"]:
    print(f"{key['key_prefix']}... ({key['status']})")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.listKeys();
for (const key of result.keys) {
  console.log(`${key.key_prefix}... (${key.status})`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/keys \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

```json
{
  "keys": [
    {
      "key_id": "key_a1b2c3d4",
      "key_prefix": "nram_abc12",
      "tier": "starter",
      "created_at": "2026-03-01T10:00:00Z",
      "expires_at": null,
      "grace_expires_at": null,
      "revoked_at": null,
      "status": "active"
    }
  ]
}
```

---

## Revoke Key

```
POST /v1/keys/revoke
```

Immediately revoke an API key. Use this if a key is compromised.

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `key_id` | string | **Yes** | Key ID or prefix to revoke |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `revoked_key_id` | string | ID of revoked key |
| `message` | string | Confirmation message |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.revoke_key("key_a1b2c3d4")
print(result["message"])
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.revokeKey("key_a1b2c3d4");
console.log(result.message);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/keys/revoke \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"key_id": "key_a1b2c3d4"}'
```

</TabItem>
</Tabs>

### Response

```json
{
  "revoked_key_id": "key_a1b2c3d4",
  "message": "Key revoked successfully"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Key does not exist |
