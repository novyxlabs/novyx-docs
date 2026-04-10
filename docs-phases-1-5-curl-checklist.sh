#!/usr/bin/env bash
#
# docs-phases-1-5-curl-checklist.sh
# ---------------------------------
# Verifies that the response shapes documented in:
#   - docs/control/custom-policies.md
#   - docs/control/approval-workflows.md
#   - docs/control/dashboard.md
#   - docs/control/agent-scoped-policies.md
#   - docs/api-reference/actions.md (governance updates)
#
# match what the live API at https://novyx-ram-api.fly.dev actually returns.
#
# Usage:
#   export NOVYX_API_KEY=nram_your_real_key
#   bash docs-phases-1-5-curl-checklist.sh
#
# Each section prints the curl, runs it, and pipes the output through `jq .`
# (if installed) for readability. Compare each response against the docs.
# If a response shape doesn't match what's documented, send the diff back
# and we'll patch the doc — per the project rule, the API is right and the
# doc is wrong.
#
# This script is idempotent except for sections marked DESTRUCTIVE — those
# create/update/delete real policies in your tenant. Read the comment before
# running each one.

set -uo pipefail

API="${NOVYX_BASE_URL:-https://novyx-ram-api.fly.dev}"
KEY="${NOVYX_API_KEY:?Set NOVYX_API_KEY before running}"
AUTH=(-H "Authorization: Bearer $KEY")
JSON=(-H "Content-Type: application/json")
JQ() { command -v jq >/dev/null && jq . || cat; }

step() { printf '\n\n\033[1;36m─── %s ───\033[0m\n' "$1"; }
note() { printf '\033[2m%s\033[0m\n' "$1"; }

# ============================================================================
# CUSTOM POLICIES (Phase 1)
# ============================================================================

step "1.1  GET /v1/control/policies — list active policies (tenant-wide)"
note "Expected: 200, JSON with 'policies' array. Built-ins should have source='builtin'."
curl -sS "$API/v1/control/policies" "${AUTH[@]}" | JQ

step "1.2  POST /v1/control/policies — create the PII protection policy  [DESTRUCTIVE]"
note "Expected: 201, {policy_name, agent_id:null, action:'created', version, message}."
note "If a policy named 'pii_protection' already exists, this upserts it (action:'updated')."
curl -sS -X POST "$API/v1/control/policies" "${AUTH[@]}" "${JSON[@]}" -d '{
  "name": "pii_protection",
  "description": "Block PII exposure to external systems",
  "rules": [
    {
      "match": "(ssn|social.security|passport)",
      "severity": "critical",
      "on_violation": "block",
      "reason": "PII detected: {match}"
    },
    {
      "match": "(email|phone)",
      "context_requires": "(external|public)",
      "severity": "high",
      "on_violation": "require_approval"
    }
  ],
  "whitelisted_domains": ["internal.company.com"]
}' | JQ

step "1.3  GET /v1/control/policies/pii_protection — fetch tenant-wide version"
note "Expected: 200, {name, description, source:'custom', agent_id:null, scope:'tenant', enabled:true, version, config, created_at, updated_at}."
curl -sS "$API/v1/control/policies/pii_protection" "${AUTH[@]}" | JQ

step "1.4  PUT /v1/control/policies/pii_protection — update + version bump  [DESTRUCTIVE]"
note "Expected: 200, action:'updated', version > previous."
curl -sS -X PUT "$API/v1/control/policies/pii_protection" "${AUTH[@]}" "${JSON[@]}" -d '{
  "name": "pii_protection",
  "description": "Block PII exposure (updated by checklist)",
  "rules": [
    {"match": "(ssn|passport|driver.license)", "severity": "critical"}
  ]
}' | JQ

step "1.5  GET /v1/control/policies?agent_id=billing-bot — list with agent scope"
note "Expected: tenant-wide policies + any agent-scoped policies for billing-bot. (Pro+ if any agent-scoped exist.)"
curl -sS "$API/v1/control/policies?agent_id=billing-bot" "${AUTH[@]}" | JQ

step "1.6  DELETE /v1/control/policies/pii_protection — soft delete  [DESTRUCTIVE]"
note "Expected: 200, action:'disabled'. The policy still exists but is disabled."
curl -sS -X DELETE "$API/v1/control/policies/pii_protection" "${AUTH[@]}" | JQ

step "1.7  DELETE /v1/control/policies/FinancialSafety — should 403"
note "Expected: 403, code 'novyx_ram.v1.control.cannot_delete_builtin'. Built-ins cannot be deleted."
note "NOTE: built-in policy names are 'FinancialSafety' and 'DataExfiltration' — no 'Policy' suffix."
curl -sS -X DELETE "$API/v1/control/policies/FinancialSafety" "${AUTH[@]}" | JQ

# ============================================================================
# APPROVAL WORKFLOWS (Phase 2)
# ============================================================================

step "2.1  GET /v1/approvals — current pending queue"
note "Expected: 200, {approvals:[], total:n}. Each entry should have action_id, action, agent_id, status:'pending_review', submitted_at, risk_score, triggered_policy."
curl -sS "$API/v1/approvals?limit=20" "${AUTH[@]}" | JQ

step "2.2  POST /v1/approvals/does_not_exist_xyz/decision — should 404"
note "Expected: 404, code 'control.approval_not_found'."
curl -sS -X POST "$API/v1/approvals/does_not_exist_xyz/decision" "${AUTH[@]}" "${JSON[@]}" -d '{
  "decision": "approve"
}' | JQ

step "2.3  Submit an action that triggers require_approval  [DESTRUCTIVE]"
note "Synthetic Slack action via the SDK pattern: connector + operation in the path (no URL encoding)."
note "Expected: 200 with status 'allowed' (if no rule fires) or 'pending_review'."
note "If you have a custom policy with on_violation:require_approval that matches 'email' in 'external' context, this should trip it."
curl -sS -X POST "$API/v1/actions/slack/messages/send" "${AUTH[@]}" "${JSON[@]}" -d '{
  "agent_id": "checklist-test",
  "channel": "#external-customers",
  "text": "Customer email: alice@example.com"
}' | JQ

step "2.4  POST decision twice on a real action_id — second call should 409"
note "Replace ACTION_ID with a real pending action_id from step 2.1, then run this twice. Second call should return 409 control.approval_already_decided."
note "Skipped automatically — uncomment and edit to run."
# ACTION_ID=act_replace_me
# curl -sS -X POST "$API/v1/approvals/$ACTION_ID/decision" "${AUTH[@]}" "${JSON[@]}" -d '{"decision":"approve","reason":"checklist test"}' | JQ
# curl -sS -X POST "$API/v1/approvals/$ACTION_ID/decision" "${AUTH[@]}" "${JSON[@]}" -d '{"decision":"approve","reason":"checklist test"}' | JQ

# ============================================================================
# GOVERNANCE DASHBOARD (Phase 4)
# ============================================================================

step "4.1  GET /v1/control/dashboard?window=7d — full dashboard"
note "Expected: 200, {window, bucket, backend, totals, violations_by_policy, violations_by_agent, time_series}."
note "If tenant is on Free tier: 403 tier.feature_required."
note "If tenant is on file backend: same shape with all zeros and backend:'file'."
curl -sS "$API/v1/control/dashboard?window=7d" "${AUTH[@]}" | JQ

step "4.2  GET /v1/control/dashboard?window=24h&bucket=hour"
note "Expected: hourly buckets in time_series."
curl -sS "$API/v1/control/dashboard?window=24h&bucket=hour" "${AUTH[@]}" | JQ

step "4.3  GET /v1/control/agents/checklist-test/violations"
note "Expected: 200, {agent_id, total, backend, violations:[]}. Will likely be empty if checklist-test has no real history."
curl -sS "$API/v1/control/agents/checklist-test/violations?limit=20" "${AUTH[@]}" | JQ

step "4.4  GET /v1/control/agents/checklist-test/violations with time range"
note "Expected: same shape, filtered by since/until."
note "KNOWN BUG (April 2026): the live API currently returns novyx_ram.v1.control.violations_failed when since/until are passed."
note "Until that's fixed, omit since/until and filter client-side."
curl -sS "$API/v1/control/agents/checklist-test/violations?since=2026-04-01T00:00:00Z&until=2026-04-30T00:00:00Z" "${AUTH[@]}" | JQ

# ============================================================================
# AGENT-SCOPED POLICIES (Phase 5)
# ============================================================================
#
# These steps require Pro+. If you're on Starter or Free, they'll return 403
# with code 'tier.feature_required'.

step "5.1  POST /v1/control/policies — create agent-scoped override for billing-bot  [DESTRUCTIVE, Pro+]"
note "Expected: 201, agent_id:'billing-bot', scope:'agent'."
curl -sS -X POST "$API/v1/control/policies" "${AUTH[@]}" "${JSON[@]}" -d '{
  "name": "pii_protection",
  "agent_id": "billing-bot",
  "description": "Strict PII rules for billing-bot",
  "rules": [
    {
      "match": "(email|phone|ssn|passport|routing)",
      "severity": "critical",
      "on_violation": "block",
      "reason": "PII blocked for billing-bot: {match}"
    }
  ]
}' | JQ

step "5.2  GET /v1/control/policies/pii_protection?agent_id=billing-bot"
note "Expected: returns the agent-scoped version (scope:'agent'), not the tenant-wide one."
curl -sS "$API/v1/control/policies/pii_protection?agent_id=billing-bot" "${AUTH[@]}" | JQ

step "5.3  GET /v1/control/policies/pii_protection — without agent_id"
note "Expected: returns the tenant-wide version (scope:'tenant'), independent of the scoped one."
curl -sS "$API/v1/control/policies/pii_protection" "${AUTH[@]}" | JQ

step "5.4  DELETE /v1/control/policies/pii_protection?agent_id=billing-bot  [DESTRUCTIVE]"
note "Expected: 200, action:'disabled'. Only the scoped version is disabled — tenant-wide is unaffected."
curl -sS -X DELETE "$API/v1/control/policies/pii_protection?agent_id=billing-bot" "${AUTH[@]}" | JQ

# ============================================================================
# DONE
# ============================================================================

step "Checklist complete"
note "Compare each response above against:"
note "  • docs/control/custom-policies.md"
note "  • docs/control/approval-workflows.md"
note "  • docs/control/dashboard.md"
note "  • docs/control/agent-scoped-policies.md"
note ""
note "Anything that doesn't match — send back the diff and we'll patch the doc."
