# Gateway API (planned)

This document defines the planned **Gateway API** that sits in front of ntfy.

Goal:

- Keep **ntfy as the core**
- Make integrations **reusable across apps**
- Apps send structured audience identifiers, the gateway generates ntfy topics.

## Concepts

### Tenant

A tenant represents an adopting app/org. The gateway is multi-tenant internally but supports a "default tenant mode" for simple single-app installs.

### Audience

Audience is a structured recipient scope. Example audience types:

- `course`
- `class`
- `org`
- `role`
- `team`

Audience IDs should be **opaque** (not guessable), e.g. UUIDs.

### Topic generation

The gateway generates an ntfy topic as:

`t_{tenantId}.{audienceType}.{audienceId}`

Example:

- tenantId: `9f2c1a`
- audienceType: `course`
- audienceId: `a3f6b2c0d9f14b8e`

Topic:

- `t_9f2c1a.course.a3f6b2c0d9f14b8e`

Apps do not need to know this naming format; they only send the structured audience fields.

## Authentication (v1)

Simplest form for v1:

- `Authorization: Bearer <GATEWAY_API_KEY>`

Later versions can support:

- multiple keys mapped to tenant IDs
- JWTs
- per-tenant quotas/rate-limits

## Endpoint: POST /v1/notify (v1)

Creates a message and publishes it to ntfy.

### Request body (JSON)

```json
{
  "audience": { "type": "course", "id": "a3f6b2c0d9f14b8e" },
  "title": "New resource uploaded",
  "message": "Week 4 slides are available",
  "link": "https://erp.example.com/resources/123"
}
```

### Behavior

- resolve tenantId:
  - if the API key maps to a tenant → use that
  - else if `DEFAULT_TENANT_ID` is configured → use that
  - else reject
- generate topic from `{tenantId, audience.type, audience.id}`
- publish to ntfy topic
- return publish result

### Response (example)

```json
{
  "ok": true,
  "topic": "t_9f2c1a.course.a3f6b2c0d9f14b8e",
  "published": true
}
```
