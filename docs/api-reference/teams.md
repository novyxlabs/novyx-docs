---
sidebar_position: 12
title: "Novyx API: Teams — 9 Endpoints for Organization Management"
description: "Manage team members, roles, permissions, and billing. Organization-level controls for multi-agent deployments."
---

# Teams

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

The Teams router lets you create multi-tenant teams, invite members by email, assign roles (admin, member, readonly), and manage membership.

**Base URL:** `https://novyx-ram-api.fly.dev`

**Tier:** Pro+

---

## Create Team

```
POST /v1/teams
```

Create a new team. You become the owner.

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | **Yes** | — | Team name (1–100 characters) |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `team_id` | string | Unique team identifier |
| `name` | string | Team name |
| `owner_tenant_id` | string | Owner's tenant ID |
| `members` | array | List of members with `tenant_id`, `role`, `joined_at` |
| `member_count` | number | Total members |
| `created_at` | string | ISO 8601 timestamp |
| `updated_at` | string | ISO 8601 timestamp |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
from novyx import Novyx

nx = Novyx(api_key="nram_your_key")

team = nx.create_team(name="engineering")
print(team["team_id"])
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
import { Novyx } from "novyx";

const nx = new Novyx({ apiKey: "nram_your_key" });

const team = await nx.createTeam({ name: "engineering" });
console.log(team.team_id);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/teams \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"name": "engineering"}'
```

</TabItem>
</Tabs>

### Response

```json
{
  "team_id": "team_a1b2c3d4",
  "name": "engineering",
  "owner_tenant_id": "tenant_abc123",
  "members": [
    {
      "tenant_id": "tenant_abc123",
      "role": "owner",
      "joined_at": "2026-03-09T12:00:00Z"
    }
  ],
  "member_count": 1,
  "created_at": "2026-03-09T12:00:00Z",
  "updated_at": "2026-03-09T12:00:00Z"
}
```

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Name is blank or too long |
| 403 | `FEATURE_NOT_AVAILABLE` | Requires Pro+ plan |

---

## List Teams

```
GET /v1/teams
```

List all teams you own or belong to.

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `teams` | array | Array of team objects |
| `total_count` | number | Total teams |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.list_teams()
for team in result["teams"]:
    print(f"{team['name']}: {team['member_count']} members")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.listTeams();
for (const team of result.teams) {
  console.log(`${team.name}: ${team.member_count} members`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/teams \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

---

## Get Team

```
GET /v1/teams/{team_id}
```

Retrieve a team with its full member list.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `team_id` | string | Team identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
team = nx.get_team("team_a1b2c3d4")
for member in team["members"]:
    print(f"  {member['tenant_id']}: {member['role']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const team = await nx.getTeam("team_a1b2c3d4");
for (const member of team.members) {
  console.log(`  ${member.tenant_id}: ${member.role}`);
}
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl https://novyx-ram-api.fly.dev/v1/teams/team_a1b2c3d4 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 404 | `NOT_FOUND` | Team does not exist |

---

## Update Team

```
PUT /v1/teams/{team_id}
```

Update team details. Requires owner or admin role.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `team_id` | string | Team identifier |

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | No | Updated team name (1–100 characters) |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
updated = nx.update_team("team_a1b2c3d4", name="platform-engineering")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const updated = await nx.updateTeam("team_a1b2c3d4", { name: "platform-engineering" });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X PUT https://novyx-ram-api.fly.dev/v1/teams/team_a1b2c3d4 \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"name": "platform-engineering"}'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FORBIDDEN` | Must be owner or admin |
| 404 | `NOT_FOUND` | Team does not exist |

---

## Delete Team

```
DELETE /v1/teams/{team_id}
```

Delete a team. Owner only.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `team_id` | string | Team identifier |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
nx.delete_team("team_a1b2c3d4")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
await nx.deleteTeam("team_a1b2c3d4");
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X DELETE https://novyx-ram-api.fly.dev/v1/teams/team_a1b2c3d4 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

Returns `204 No Content` on success.

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FORBIDDEN` | Owner only |
| 404 | `NOT_FOUND` | Team does not exist |

---

## Invite Member

```
POST /v1/teams/{team_id}/invite
```

Invite a user to join the team by email. Requires owner or admin role.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `team_id` | string | Team identifier |

### Request body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `email` | string | **Yes** | — | Invitee's email address |
| `role` | string | No | `"member"` | Role: `admin`, `member`, or `readonly` |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `invitation_id` | string | Invitation identifier |
| `team_id` | string | Team identifier |
| `email` | string | Invitee email |
| `role` | string | Assigned role |
| `expires_at` | string | Invitation expiry (ISO 8601) |
| `message` | string | Confirmation message |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
invite = nx.invite_member(
    "team_a1b2c3d4",
    email="alice@example.com",
    role="admin",
)
print(invite["invitation_id"])
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const invite = await nx.inviteMember("team_a1b2c3d4", {
  email: "alice@example.com",
  role: "admin",
});
console.log(invite.invitation_id);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/teams/team_a1b2c3d4/invite \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"email": "alice@example.com", "role": "admin"}'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Invalid email or role |
| 403 | `FORBIDDEN` | Must be owner or admin |

---

## Join Team

```
POST /v1/teams/join
```

Accept a team invitation using the invitation token.

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `invitation_id` | string | **Yes** | Invitation ID from the invite email |

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `team_id` | string | Joined team ID |
| `team_name` | string | Team name |
| `role` | string | Assigned role |
| `message` | string | Confirmation message |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
result = nx.join_team(invitation_id="inv_x1y2z3")
print(f"Joined {result['team_name']} as {result['role']}")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
const result = await nx.joinTeam({ invitationId: "inv_x1y2z3" });
console.log(`Joined ${result.team_name} as ${result.role}`);
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X POST https://novyx-ram-api.fly.dev/v1/teams/join \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"invitation_id": "inv_x1y2z3"}'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `INVALID_TOKEN` | Invitation expired or invalid |

---

## Update Member Role

```
PUT /v1/teams/{team_id}/members/{tenant_id}
```

Change a team member's role. Requires owner or admin role.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `team_id` | string | Team identifier |
| `tenant_id` | string | Member's tenant ID |

### Request body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `role` | string | **Yes** | New role: `admin`, `member`, or `readonly` |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
nx.update_member_role("team_a1b2c3d4", "tenant_xyz789", role="admin")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
await nx.updateMemberRole("team_a1b2c3d4", "tenant_xyz789", { role: "admin" });
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X PUT https://novyx-ram-api.fly.dev/v1/teams/team_a1b2c3d4/members/tenant_xyz789 \
  -H "Authorization: Bearer nram_your_key" \
  -H "Content-Type: application/json" \
  -d '{"role": "admin"}'
```

</TabItem>
</Tabs>

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 400 | `VALIDATION_ERROR` | Invalid role |
| 403 | `FORBIDDEN` | Must be owner or admin |

---

## Remove Member

```
DELETE /v1/teams/{team_id}/members/{tenant_id}
```

Remove a member from the team. Requires owner or admin role.

### Path parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `team_id` | string | Team identifier |
| `tenant_id` | string | Member's tenant ID |

### Examples

<Tabs groupId="lang">
<TabItem value="python" label="Python" default>

```python
nx.remove_member("team_a1b2c3d4", "tenant_xyz789")
```

</TabItem>
<TabItem value="typescript" label="TypeScript">

```typescript
await nx.removeMember("team_a1b2c3d4", "tenant_xyz789");
```

</TabItem>
<TabItem value="curl" label="curl">

```bash
curl -X DELETE https://novyx-ram-api.fly.dev/v1/teams/team_a1b2c3d4/members/tenant_xyz789 \
  -H "Authorization: Bearer nram_your_key"
```

</TabItem>
</Tabs>

### Response

Returns `204 No Content` on success.

### Errors

| Status | Code | Cause |
|--------|------|-------|
| 403 | `FORBIDDEN` | Must be owner or admin |
| 404 | `NOT_FOUND` | Member not found in team |
