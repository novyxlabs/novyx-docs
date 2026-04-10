---
sidebar_position: 1
title: "Custom Policies — Policy-as-Code for Novyx Control"
description: "Author governance rules in YAML. Custom policies are evaluated alongside built-ins on every agent action submission. Per-rule on_violation: block, require_approval, or warn."
---

# Custom Policies

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Novyx Control ships with two built-in policies (`FinancialSafety` and `DataExfiltration`) that are always active. **Custom policies** let you author your own governance rules in YAML or JSON — regex patterns, severity levels, and per-rule outcomes — without writing any Python.

Custom policies are evaluated alongside the built-ins on every action submission. Each rule has a `match` regex, a `severity`, and an optional `on_violation` outcome that decides what happens when the rule fires.

**Tier:** Custom policies require the `draft_policies` feature (Starter+). Free tenants get the built-ins only. Per-tier limits:

| Tier       | Custom policies |
|------------|-----------------|
| Free       | 0               |
| Starter    | 5               |
| Pro        | 25              |
| Enterprise | Unlimited       |

---

## Policy schema

A policy is a dict (or YAML doc) with the following top-level fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | **Yes** | Unique within scope. Alphanumeric, underscores, hyphens. Max 64 chars. |
| `description` | string | No | Human-readable description. |
| `step_types` | string[] | No | Which audit step types to evaluate. Defaults to `["ACTION"]`. Valid values: `thought`, `action`, `observation`, `output`, `error`, `policy_check`. |
| `whitelisted_domains` | string[] | No | Domains that bypass evaluation entirely. |
| `rules` | object[] | **Yes** | Non-empty list of rule dicts. |

Each rule has the following fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `match` | string | **Yes** | Regex pattern, compiled with `re.IGNORECASE`. Matches anywhere in the action payload. |
| `severity` | string | **Yes** | One of `critical`, `high`, `medium`, `low`. |
| `on_violation` | string | No | One of `block`, `require_approval`, `warn`. If omitted, defaults from severity (see below). |
| `reason` | string | No | Violation message template. `{match}` is replaced with the matched substring. |
| `context_requires` | string | No | Additional regex that must also match for the rule to fire. Used to scope a rule (e.g., only fire for "external" contexts). |
| `confidence` | float | No | 0.0–1.0. Defaults to 0.85. |

---

## The `on_violation` field

Every rule resolves to one of three outcomes when it fires:

| Value | Meaning |
|-------|---------|
| `block` | The action is rejected. The API returns status `blocked`. |
| `require_approval` | The action is held for human review. The API returns status `pending_review` and the action enters the [approval queue](./approval-workflows). |
| `warn` | The action proceeds. The API returns status `allowed`, but a warning is recorded in the `policy_result.warnings` array and logged in the audit chain. |

If you don't specify `on_violation`, Novyx falls back to a default based on the rule's severity:

| Severity | Default `on_violation` |
|----------|------------------------|
| `critical` | `block` |
| `high` | `require_approval` |
| `medium` | `warn` |
| `low` | `warn` |

You can always override the default per-rule. A `medium`-severity rule with `on_violation: block` will block; a `critical`-severity rule with `on_violation: warn` will warn.

> **Heads up — `warn` is not a separate action status.** A `warn` rule causes the action to be `allowed`. The warning is surfaced through the `warnings` array in `policy_result`, not through a distinct top-level status. See [Approval Workflows](./approval-workflows#action-statuses-vs-rule-outcomes) for the full mental model.

---

## PII protection example

A complete custom policy that blocks SSN/passport patterns and routes email/phone in external contexts to human approval:

```yaml
name: pii_protection
description: Block actions exposing PII to external systems
rules:
  - match: "(ssn|social.security|passport)"
    severity: critical
    on_violation: block
    reason: "PII detected: {match}"
  - match: "(email|phone)"
    context_requires: "(external|public)"
    severity: high
    on_violation: require_approval
whitelisted_domains:
  - internal.company.com
```

The first rule fires on any payload containing SSN or passport keywords and blocks the action outright. The second only fires when the payload also matches an "external" or "public" context — a billing-bot sending an email to an internal address won't trigger it, but the same bot sending to an external domain will route to approval.

---

## Endpoints

All policy CRUD endpoints accept an optional `agent_id` parameter. When `agent_id` is set, the policy applies only to that agent and overrides any tenant-wide policy with the same name. See [Agent-Scoped Policies](./agent-scoped-policies) for details. Agent-scoped policies require the `agent_scoped_policies` feature (Pro+).

### Create or update a policy

```
POST /v1/control/policies
```

The endpoint upserts: posting a policy with an existing name updates it and increments `version`.

#### Request body

| Field | Type | Required |
|-------|------|----------|
| `name` | string | **Yes** |
| `rules` | object[] | **Yes** |
| `description` | string | No |
| `step_types` | string[] | No |
| `whitelisted_domains` | string[] | No |
| `enabled` | boolean | No (default `true`) |
| `agent_id` | string | No |

#### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

nx.create_policy(
    "pii_protection",
    description="Block PII exposure to external systems",
    rules=[
        {
            "match": "(ssn|social.security|passport)",
            "severity": "critical",
            "reason": "PII detected: {match}",
        },
        {
            "match": "(email|phone)",
            "context_requires": "(external|public)",
            "severity": "high",
        },
    ],
    whitelisted_domains=["internal.company.com"],
)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

await nx.createPolicy({
  name: "pii_protection",
  description: "Block PII exposure to external systems",
  rules: [
    {
      match: "(ssn|social.security|passport)",
      severity: "critical",
      reason: "PII detected: {match}",
    },
    {
      match: "(email|phone)",
      context_requires: "(external|public)",
      severity: "high",
    },
  ],
  whitelisted_domains: ["internal.company.com"],
});
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/control/policies \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "pii_protection",
    "description": "Block PII exposure to external systems",
    "rules": [
      {
        "match": "(ssn|social.security|passport)",
        "severity": "critical",
        "reason": "PII detected: {match}"
      },
      {
        "match": "(email|phone)",
        "context_requires": "(external|public)",
        "severity": "high"
      }
    ],
    "whitelisted_domains": ["internal.company.com"]
  }'
```

</TabItem>
</Tabs>

#### Response

```json
{
  "policy_name": "pii_protection",
  "agent_id": null,
  "action": "created",
  "version": 1,
  "message": "Policy 'pii_protection' created"
}
```

#### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `novyx_ram.v1.control.invalid_policy` | Invalid YAML/JSON, missing required fields, or invalid regex. |
| 403 | `novyx_ram.v1.tier.feature_required` | Tenant tier does not include `draft_policies` (Free tier) or `agent_scoped_policies` (when `agent_id` is set on Free/Starter). |
| 403 | `novyx_ram.v1.tier.limit_exceeded` | Tenant has reached its `custom_policies_limit`. |

---

### List policies

```
GET /v1/control/policies
```

Lists active built-in and custom policies. Each policy includes its `source` (`builtin` or `custom`), `agent_id`, `scope`, `version`, and timestamps. Pass `agent_id` to also include agent-scoped policies for that agent.

#### Query parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `agent_id` | string | If set, includes agent-scoped policies for this agent alongside tenant-wide policies. |

#### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
policies = nx.list_policies()
for p in policies["policies"]:
    print(f"{p['name']} — {p['source']} (v{p.get('version', '—')})")

# Include billing-bot's scoped overrides
nx.list_policies(agent_id="billing-bot")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const policies = await nx.listPolicies();
for (const p of policies.policies) {
  console.log(`${p.name} — ${p.source} (v${p.version ?? "—"})`);
}

// Include billing-bot's scoped overrides
await nx.listPolicies({ agent_id: "billing-bot" });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/control/policies \
  -H "Authorization: Bearer nram_your_key"

# With agent scope
curl "https://novyx-ram-api.fly.dev/v1/control/policies?agent_id=billing-bot" \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

#### Response

```json
{
  "policies": [
    {
      "name": "FinancialSafety",
      "enabled": true,
      "description": "Policy to prevent unauthorized financial operations.",
      "source": "builtin",
      "agent_id": null
    },
    {
      "name": "DataExfiltration",
      "enabled": true,
      "description": "Policy to prevent data exfiltration attempts.",
      "source": "builtin",
      "agent_id": null
    },
    {
      "name": "pii_protection",
      "enabled": true,
      "description": "Block PII exposure to external systems",
      "source": "custom",
      "agent_id": null,
      "scope": "tenant",
      "version": 1,
      "created_at": "2026-04-10T14:30:00Z",
      "updated_at": "2026-04-10T14:30:00Z"
    }
  ],
  "mode": "enforcement",
  "connectors": ["github", "slack", "linear", "pagerduty", "http"],
  "approval_modes": ["solo", "team", "enterprise"]
}
```

> Built-in policies (`FinancialSafety`, `DataExfiltration`) only return `name`, `enabled`, `description`, `source`, and `agent_id`. Custom policies additionally include `scope`, `version`, `created_at`, and `updated_at`.

---

### Get a single policy

```
GET /v1/control/policies/{policy_name}
```

Fetches one policy's full configuration. The same name can exist at both tenant-wide and agent-scoped levels independently — pass `agent_id` to fetch the agent-scoped version, omit it for the tenant-wide one.

#### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
policy = nx.get_policy("pii_protection")
print(policy["config"]["rules"])

# Agent-scoped version
nx.get_policy("pii_protection", agent_id="billing-bot")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const policy = await nx.getPolicy("pii_protection");
console.log(policy.config.rules);

// Agent-scoped version
await nx.getPolicy("pii_protection", { agent_id: "billing-bot" });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/control/policies/pii_protection \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

#### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `novyx_ram.v1.control.policy_not_found` | No policy with that name at the requested scope. |

---

### Update a policy

```
PUT /v1/control/policies/{policy_name}
```

Replaces the policy's rules and metadata, increments `version`. Same field semantics as create. Pass `agent_id` to target the agent-scoped version.

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
nx.update_policy(
    "pii_protection",
    rules=[
        {"match": "(ssn|passport|driver.license)", "severity": "critical"},
    ],
    description="Updated to include driver license",
)
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
await nx.updatePolicy("pii_protection", {
  rules: [
    { match: "(ssn|passport|driver.license)", severity: "critical" },
  ],
  description: "Updated to include driver license",
});
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X PUT https://novyx-ram-api.fly.dev/v1/control/policies/pii_protection \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "pii_protection",
    "description": "Updated to include driver license",
    "rules": [
      {"match": "(ssn|passport|driver.license)", "severity": "critical"}
    ]
  }'
```

</TabItem>
</Tabs>

---

### Delete (disable) a policy

```
DELETE /v1/control/policies/{policy_name}
```

Soft delete — sets `enabled = false`. Built-in policies (`FinancialSafety`, `DataExfiltration`) cannot be deleted and return 403.

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
nx.delete_policy("pii_protection")

# Disable an agent-scoped version without touching tenant-wide
nx.delete_policy("billing_block", agent_id="billing-bot")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
await nx.deletePolicy("pii_protection");

// Disable an agent-scoped version without touching tenant-wide
await nx.deletePolicy("billing_block", { agent_id: "billing-bot" });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X DELETE https://novyx-ram-api.fly.dev/v1/control/policies/pii_protection \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

#### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `novyx_ram.v1.control.cannot_delete_builtin` | Built-in policies cannot be deleted. |
| 404 | `novyx_ram.v1.control.policy_not_found` | No policy with that name at the requested scope. |

---

## See also

- [Approval Workflows](./approval-workflows) — what happens when a `require_approval` rule fires
- [Agent-Scoped Policies](./agent-scoped-policies) — per-agent overrides
- [Governance Dashboard](./dashboard) — see which policies are firing and how often
