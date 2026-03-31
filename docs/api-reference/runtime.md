---
sidebar_position: 11
title: "Novyx API: Runtime v2 — Agent Lifecycle & Orchestration"
description: "First-class agent lifecycle, goal-oriented missions, capability governance, checkpoints, and supervisor interventions. 16 endpoints for orchestrating autonomous agents."
---

# Runtime v2 — Agent Lifecycle

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Runtime v2 introduces first-class primitives for orchestrating autonomous agents. Create persistent agents, assign goal-oriented missions, govern which tools they can use, checkpoint progress, and intervene when decisions need human oversight.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** All plans

**MCP:** All 16 tools available via novyx-mcp v2.4.0+

---

## Agents

Agents are persistent identities that survive across sessions. Each agent has a name, model configuration, and a set of capability packs that define what tools it can use.

### Create Agent

```
POST /v1/agents
```

Register a new agent in the Novyx Runtime. The agent persists until explicitly deleted.

#### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | **Yes** | Human-readable agent name |
| `agent_id` | string | No | Custom ID (auto-generated if omitted) |
| `description` | string | No | What this agent does |
| `model` | string | No | LLM model name (default: `gpt-4o-mini`) |
| `provider` | string | No | LLM provider: `openai`, `anthropic`, `litellm` (default: `openai`) |
| `instructions` | string | No | System prompt / instructions |
| `capabilities` | string[] | No | Enabled capability pack names |

#### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

agent = nx.create_agent(
    name="research-agent",
    description="Investigates vendor contracts and compliance gaps",
    model="claude-sonnet-4-20250514",
    provider="anthropic",
    capabilities=["web-search", "file-read"]
)
print(agent["agent_id"])  # agt_f7a2...
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const agent = await nx.createAgent({
  name: "research-agent",
  description: "Investigates vendor contracts and compliance gaps",
  model: "claude-sonnet-4-20250514",
  provider: "anthropic",
  capabilities: ["web-search", "file-read"],
});
console.log(agent.agent_id);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/agents \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "research-agent",
    "description": "Investigates vendor contracts and compliance gaps",
    "model": "claude-sonnet-4-20250514",
    "provider": "anthropic",
    "capabilities": ["web-search", "file-read"]
  }'
```

</TabItem>
<TabItem value="mcp" label="MCP">

```
Tool: create_agent
Args: {
  "name": "research-agent",
  "description": "Investigates vendor contracts and compliance gaps",
  "model": "claude-sonnet-4-20250514",
  "provider": "anthropic",
  "capabilities": ["web-search", "file-read"]
}
```

</TabItem>
</Tabs>

### List Agents

```
GET /v1/agents
```

List all agents for the current tenant.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | No | Filter by status: `active`, `paused`, `archived` |
| `limit` | integer | No | Max results (default: 100) |

### Get Agent

```
GET /v1/agents/{agent_id}
```

Retrieve a single agent by ID, including its current status, capabilities, and active missions.

### Delete Agent

```
DELETE /v1/agents/{agent_id}
```

Permanently remove an agent. Active missions for this agent will be cancelled.

---

## Missions

Missions are goal-oriented tasks assigned to agents. They have a lifecycle — `queued → running → paused → completed` or `failed` — and can be constrained by success criteria and capability packs.

### Create Mission

```
POST /v1/missions
```

Assign a bounded job to an agent.

#### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `agent_id` | string | **Yes** | Agent to assign this mission to |
| `goal` | string | **Yes** | What the mission should accomplish |
| `constraints` | string[] | No | Constraints on execution |
| `success_criteria` | string[] | No | How to determine success |
| `allowed_capabilities` | string[] | No | Capability packs allowed for this mission |

#### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
mission = nx.create_mission(
    agent_id="agt_f7a2",
    goal="Audit Q1 vendor contracts for compliance gaps",
    constraints=["Read-only access", "No external API calls"],
    success_criteria=["All 12 contracts reviewed", "Risk report generated"],
    allowed_capabilities=["file-read"]
)
print(mission["mission_id"])  # msn_9c3d...
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const mission = await nx.createMission({
  agentId: "agt_f7a2",
  goal: "Audit Q1 vendor contracts for compliance gaps",
  constraints: ["Read-only access", "No external API calls"],
  successCriteria: ["All 12 contracts reviewed", "Risk report generated"],
  allowedCapabilities: ["file-read"],
});
console.log(mission.mission_id);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/missions \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_id": "agt_f7a2",
    "goal": "Audit Q1 vendor contracts for compliance gaps",
    "constraints": ["Read-only access", "No external API calls"],
    "success_criteria": ["All 12 contracts reviewed", "Risk report generated"],
    "allowed_capabilities": ["file-read"]
  }'
```

</TabItem>
<TabItem value="mcp" label="MCP">

```
Tool: create_mission
Args: {
  "agent_id": "agt_f7a2",
  "goal": "Audit Q1 vendor contracts for compliance gaps",
  "constraints": ["Read-only access", "No external API calls"],
  "success_criteria": ["All 12 contracts reviewed", "Risk report generated"],
  "allowed_capabilities": ["file-read"]
}
```

</TabItem>
</Tabs>

### List Missions

```
GET /v1/missions
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `agent_id` | string | No | Filter by agent |
| `status` | string | No | Filter: `queued`, `running`, `paused`, `completed`, `failed` |
| `limit` | integer | No | Max results (default: 100) |

### Get Mission

```
GET /v1/missions/{mission_id}
```

### Pause Mission

```
POST /v1/missions/{mission_id}/pause
```

Pause a running mission. The agent stops execution and can be resumed later.

### Resume Mission

```
POST /v1/missions/{mission_id}/resume
```

Resume a paused mission from where it left off.

### Cancel Mission

```
POST /v1/missions/{mission_id}/cancel
```

Cancel a mission permanently. Cannot be resumed after cancellation.

---

## Capability Packs

Capability packs define which tools an agent can use and the risk level of each tool. This is policy enforcement at the orchestration layer — agents can only use tools in their assigned capability packs.

### Create Capability Pack

```
POST /v1/capabilities
```

#### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | **Yes** | Pack name (e.g., `web-search`, `file-write`) |
| `description` | string | No | What this pack enables |
| `tools` | object[] | No | Tool definitions with schemas |
| `risk_levels` | object | No | Risk level per tool: `{ "tool_name": "low" \| "medium" \| "high" \| "critical" }` |

#### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
cap = nx.create_capability(
    name="web-search",
    description="Search the web and fetch pages",
    tools=[
        {"name": "search", "description": "Web search"},
        {"name": "fetch_url", "description": "Fetch a URL"}
    ],
    risk_levels={"search": "low", "fetch_url": "medium"}
)
```

</TabItem>
<TabItem value="mcp" label="MCP">

```
Tool: create_capability
Args: {
  "name": "web-search",
  "description": "Search the web and fetch pages",
  "tools": [
    {"name": "search", "description": "Web search"},
    {"name": "fetch_url", "description": "Fetch a URL"}
  ],
  "risk_levels": {"search": "low", "fetch_url": "medium"}
}
```

</TabItem>
</Tabs>

### List Capability Packs

```
GET /v1/capabilities
```

List all registered capability packs for the current tenant.

---

## Checkpoints

Checkpoints save the state of a mission at a point in time. If something goes wrong, you can roll back the mission to any previous checkpoint.

### Create Checkpoint

```
POST /v1/missions/{mission_id}/checkpoints
```

#### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `mission_id` | string | **Yes** | Mission to checkpoint |
| `label` | string | No | Human-readable label (e.g., `"pre-deploy"`, `"after-review"`) |

#### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
checkpoint = nx.create_checkpoint(
    mission_id="msn_9c3d",
    label="after-contract-review"
)
print(checkpoint["checkpoint_id"])  # chk_07...
```

</TabItem>
<TabItem value="mcp" label="MCP">

```
Tool: create_checkpoint
Args: {
  "mission_id": "msn_9c3d",
  "label": "after-contract-review"
}
```

</TabItem>
</Tabs>

### List Checkpoints

```
GET /v1/missions/{mission_id}/checkpoints
```

List all checkpoints for a mission, ordered by creation time.

### Rollback to Checkpoint

```
POST /v1/missions/{mission_id}/rollback
```

Restore a mission to a previous checkpoint. All state after the checkpoint is discarded.

#### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `mission_id` | string | **Yes** | Mission to rollback |
| `checkpoint_id` | string | **Yes** | Target checkpoint |
| `reason` | string | No | Why the rollback is needed |

#### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.rollback_to_checkpoint(
    mission_id="msn_9c3d",
    checkpoint_id="chk_03",
    reason="Agent hallucinated compliance status for vendor #7"
)
```

</TabItem>
<TabItem value="mcp" label="MCP">

```
Tool: rollback_to_checkpoint
Args: {
  "mission_id": "msn_9c3d",
  "checkpoint_id": "chk_03",
  "reason": "Agent hallucinated compliance status for vendor #7"
}
```

</TabItem>
</Tabs>

---

## Supervisor Interventions

Interventions are human-in-the-loop controls. When an agent needs oversight — approving a risky action, pausing a misbehaving mission, or escalating a decision — supervisors record interventions that become part of the audit trail.

### Create Intervention

```
POST /v1/interventions
```

#### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `intervention_type` | string | **Yes** | One of: `approve`, `reject`, `pause`, `escalate`, `reroute`, `annotate`, `rollback_request` |
| `mission_id` | string | No | Related mission |
| `action_id` | string | No | Related action |
| `agent_id` | string | No | Related agent |
| `rationale` | string | No | Why this intervention was made |

#### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
intervention = nx.create_intervention(
    intervention_type="reject",
    mission_id="msn_9c3d",
    agent_id="agt_c3b8",
    rationale="Agent attempted to deploy to prod without staging verification"
)
```

</TabItem>
<TabItem value="mcp" label="MCP">

```
Tool: create_intervention
Args: {
  "intervention_type": "reject",
  "mission_id": "msn_9c3d",
  "agent_id": "agt_c3b8",
  "rationale": "Agent attempted to deploy to prod without staging verification"
}
```

</TabItem>
</Tabs>

### List Interventions

```
GET /v1/interventions
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `mission_id` | string | No | Filter by mission |
| `agent_id` | string | No | Filter by agent |
| `intervention_type` | string | No | Filter by type |
| `limit` | integer | No | Max results (default: 100) |

---

## MCP Tools Summary

All 16 Runtime v2 tools available via `novyx-mcp` v2.4.0+:

| Tool | Description | Key Parameters | Tier |
|------|-------------|----------------|------|
| `create_agent` | Register a persistent agent | `name` (str), `model` (str), `provider` (str), `capabilities` (list) | Free |
| `list_agents` | List all agents | `status` (str), `limit` (int) | Free |
| `get_agent` | Get agent by ID | `agent_id` (str) | Free |
| `delete_agent` | Delete an agent | `agent_id` (str) | Free |
| `create_mission` | Assign a goal to an agent | `agent_id` (str), `goal` (str), `constraints` (list) | Free |
| `list_missions` | List missions | `agent_id` (str), `status` (str), `limit` (int) | Free |
| `get_mission` | Get mission by ID | `mission_id` (str) | Free |
| `pause_mission` | Pause a running mission | `mission_id` (str) | Free |
| `resume_mission` | Resume a paused mission | `mission_id` (str) | Free |
| `cancel_mission` | Cancel a mission | `mission_id` (str) | Free |
| `create_capability` | Register a capability pack | `name` (str), `tools` (list), `risk_levels` (object) | Free |
| `list_capabilities` | List capability packs | — | Free |
| `create_checkpoint` | Save mission state | `mission_id` (str), `label` (str) | Free |
| `list_checkpoints` | List checkpoints | `mission_id` (str) | Free |
| `rollback_to_checkpoint` | Restore to checkpoint | `mission_id` (str), `checkpoint_id` (str) | Free |
| `create_intervention` | Record supervisor action | `intervention_type` (str), `mission_id` (str), `rationale` (str) | Free |
| `list_interventions` | List interventions | `mission_id` (str), `agent_id` (str) | Free |
