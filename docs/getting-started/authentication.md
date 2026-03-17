---
sidebar_position: 4
title: Authentication
description: How Novyx API keys work — HMAC-signed, scoped, and rotatable.
---

# Authentication

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Every API request requires a Bearer token. API keys are HMAC-signed and prefixed with `nram_`.

## Using your API key

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```python
from novyx import Novyx

# Pass directly
nx = Novyx(api_key="nram_your_key")

# Or use environment variable (recommended)
# export NOVYX_API_KEY=nram_your_key
nx = Novyx()  # reads from NOVYX_API_KEY
```

  </TabItem>
  <TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

// Pass directly
const nx = new Novyx({ apiKey: "nram_your_key" });

// Or use environment variable
// NOVYX_API_KEY=nram_your_key
const nx2 = new Novyx();  // reads from NOVYX_API_KEY
```

  </TabItem>
  <TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/memories \
  -H "Authorization: Bearer nram_your_key"
```

  </TabItem>
</Tabs>

## Key management

### Create a new key

<Tabs groupId="lang">
  <TabItem value="python" label="Python" default>

```python
key = nx.create_api_key(name="production-agent")
print(key["api_key"])  # nram_... — save this, it's shown only once
```

  </TabItem>
  <TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/keys \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"name": "production-agent"}'
```

  </TabItem>
</Tabs>

### Rotate a key

```python
new_key = nx.rotate_api_key(key_id="key-uuid")
# Old key has a 24-hour grace period before full invalidation
```

### List keys

```python
keys = nx.list_api_keys()
for k in keys:
    print(f"{k['name']} — created {k['created_at']}")
```

## Security model

| Feature | Detail |
|---------|--------|
| Key format | `nram_` prefix + HMAC-signed payload |
| Storage | Keys are hashed server-side — we never store plaintext |
| Rotation | Old key has 24-hour grace period after rotation |
| Audit | Every key usage is logged in the audit trail |
| Rate limiting | Per-key, per-plan (1,000–10,000 req/min) |

## Base URL

All API requests go to:

```
https://novyx-ram-api.fly.dev
```

:::info MCP local mode
The MCP server can run without an API key using local SQLite storage. See [MCP Local Mode](/mcp/local-mode).
:::
