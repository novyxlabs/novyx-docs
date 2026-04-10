---
sidebar_position: 4
title: "Agent-Scoped Policies — Per-Agent Governance Overrides"
description: "The same policy name can have a tenant-wide version and per-agent overrides. Cache key is (tenant_id, agent_id_or_None). Agent-scoped wins on collision."
---

# Agent-Scoped Policies

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Custom policies are normally tenant-wide: you author one `pii_protection` policy and every agent in the tenant evaluates against it. **Agent-scoped policies** let you have the same policy name at both tenant-wide and per-agent levels — so `billing-bot` can run under stricter rules than `support-bot` without forking your policy library.

**Tier:** Agent-scoped policies require the `agent_scoped_policies` feature. Available on **Pro+**. Free and Starter tenants receive a 403 if they try to set `agent_id` on a policy.

---

## The concept

Inside the policy registry, each policy is keyed by **`(tenant_id, agent_id_or_None)`**:

- `agent_id = None` → tenant-wide policy. Applies to every agent in the tenant.
- `agent_id = "billing-bot"` → agent-scoped override. Applies only to that agent.

When `PolicyEvaluator` runs for a given agent, it merges the two scopes:

1. Agent-scoped policies (highest priority)
2. Tenant-wide policies — but only those whose name doesn't collide with an agent-scoped policy
3. Built-in policies (always active, never overridden)

If a policy name exists at both scopes for the same agent, **the agent-scoped version wins**. The tenant-wide version still applies to every other agent in the tenant.

Built-ins (`FinancialSafety`, `DataExfiltration`) are always active and cannot be overridden by either scope.

---

## Use case: billing-bot vs support-bot

A common pattern: most agents in your tenant use a relaxed `pii_protection` policy that warns on email/phone in external contexts. But your billing-bot handles real customer financial data, so you want it to **block** the same patterns instead of warning.

```text
Tenant-wide:                        Agent-scoped (billing-bot):
  pii_protection                      pii_protection
    (email|phone) → warn                (email|phone) → block
                                        (ssn|passport|routing) → block

Effective policies for support-bot:   pii_protection (tenant-wide, warns)
Effective policies for billing-bot:   pii_protection (agent-scoped, blocks)
                                       + FinancialSafety (built-in)
                                       + DataExfiltration (built-in)
```

`support-bot` and every other agent in the tenant continue to use the relaxed tenant-wide rules. Only `billing-bot` sees the stricter overrides — and it does so transparently, without any code changes on the agent side.

---

## End-to-end walkthrough

This example creates a tenant-wide policy, an agent-scoped override for `billing-bot`, submits an action as that agent, and inspects the result.

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

# 1. Create the relaxed tenant-wide policy
nx.create_policy(
    "pii_protection",
    description="Warn on PII patterns",
    rules=[
        {
            "match": "(email|phone)",
            "context_requires": "(external|public)",
            "severity": "medium",
            "on_violation": "warn",
        },
    ],
)

# 2. Create the strict agent-scoped override for billing-bot
nx.create_policy(
    "pii_protection",
    description="Block PII outright for billing-bot",
    rules=[
        {
            "match": "(email|phone|ssn|passport|routing)",
            "severity": "critical",
            "on_violation": "block",
            "reason": "PII blocked for billing-bot: {match}",
        },
    ],
    agent_id="billing-bot",
)

# 3. Submit an action as billing-bot — the agent-scoped policy fires
import requests

resp = requests.post(
    "https://novyx-ram-api.fly.dev/v1/actions",
    headers={"Authorization": "Bearer nram_your_key"},
    json={
        "action": "slack.send_message",
        "params": {
            "channel": "#external",
            "text": "Customer email: alice@example.com",
        },
        "agent_id": "billing-bot",
    },
)
result = resp.json()

print(result["status"])  # "blocked"
print(result["policy_result"].get("triggered_policy"))  # "pii_protection"

# 4. The same action submitted as support-bot (or with no agent_id)
#    would be allowed with a warning per the tenant-wide policy.

# 5. Verify the agent-scoped policy is what fired
nx.get_policy("pii_protection", agent_id="billing-bot")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

// 1. Create the relaxed tenant-wide policy
await nx.createPolicy({
  name: "pii_protection",
  description: "Warn on PII patterns",
  rules: [
    {
      match: "(email|phone)",
      context_requires: "(external|public)",
      severity: "medium",
      on_violation: "warn",
    },
  ],
});

// 2. Create the strict agent-scoped override for billing-bot
await nx.createPolicy({
  name: "pii_protection",
  description: "Block PII outright for billing-bot",
  rules: [
    {
      match: "(email|phone|ssn|passport|routing)",
      severity: "critical",
      on_violation: "block",
      reason: "PII blocked for billing-bot: {match}",
    },
  ],
  agent_id: "billing-bot",
});

// 3. Submit an action as billing-bot — the agent-scoped policy fires
const submit = await fetch("https://novyx-ram-api.fly.dev/v1/actions", {
  method: "POST",
  headers: {
    "Authorization": "Bearer nram_your_key",
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    action: "slack.send_message",
    params: {
      channel: "#external",
      text: "Customer email: alice@example.com",
    },
    agent_id: "billing-bot",
  }),
});
const result = await submit.json();

console.log(result.status);  // "blocked"
console.log(result.policy_result?.triggered_policy);  // "pii_protection"

// 4. Verify the agent-scoped policy is what fired
await nx.getPolicy("pii_protection", { agent_id: "billing-bot" });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
# 1. Tenant-wide policy
curl -X POST https://novyx-ram-api.fly.dev/v1/control/policies \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "pii_protection",
    "description": "Warn on PII patterns",
    "rules": [{
      "match": "(email|phone)",
      "context_requires": "(external|public)",
      "severity": "medium",
      "on_violation": "warn"
    }]
  }'

# 2. Agent-scoped override
curl -X POST https://novyx-ram-api.fly.dev/v1/control/policies \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "pii_protection",
    "description": "Block PII outright for billing-bot",
    "agent_id": "billing-bot",
    "rules": [{
      "match": "(email|phone|ssn|passport|routing)",
      "severity": "critical",
      "on_violation": "block",
      "reason": "PII blocked for billing-bot: {match}"
    }]
  }'

# 3. Verify
curl "https://novyx-ram-api.fly.dev/v1/control/policies/pii_protection?agent_id=billing-bot" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

---

## API surface

All five policy CRUD endpoints accept an optional `agent_id` parameter — query param on `GET` and `DELETE`, body field on `POST` and `PUT`. See [Custom Policies](./custom-policies#endpoints) for the full reference. The relevant rules:

- **Omit `agent_id`** → operate on the tenant-wide policy.
- **Set `agent_id`** → operate on the agent-scoped version. The same name can exist at both scopes independently.
- **`get_policy` is scope-aware** — `nx.get_policy("pii_protection")` returns the tenant-wide version even if an agent-scoped one with the same name exists. Pass `agent_id` to get the scoped one.
- **`list_policies(agent_id="billing-bot")`** returns both the tenant-wide policies and any agent-scoped overrides for `billing-bot`, so you can see the full effective set in one call.

---

## Tier gating

| Tier | Tenant-wide custom policies | Agent-scoped policies |
|------|----------------------------|------------------------|
| Free | — | — |
| Starter | ✓ (limit: 5) | — |
| Pro | ✓ (limit: 25) | ✓ |
| Enterprise | ✓ (unlimited) | ✓ |

Setting `agent_id` on a policy from a Free or Starter tenant returns:

```json
{
  "error": "novyx_ram.v1.tier.feature_required",
  "code": "novyx_ram.v1.tier.feature_required",
  "message": "Feature 'agent_scoped_policies' requires Pro tier or higher"
}
```

---

## See also

- [Custom Policies](./custom-policies) — the policy schema and CRUD endpoints in full
- [Approval Workflows](./approval-workflows) — different agents can have different approval thresholds
- [Governance Dashboard](./dashboard) — `violations_by_agent` shows which agents are hitting which scoped policies
