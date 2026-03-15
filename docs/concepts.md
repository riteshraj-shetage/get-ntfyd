# Notification Gateway (powered by ntfy)

This project provides a **Notification Gateway** that apps can call using a simple HTTP API.

Instead of every app integrating directly with ntfy (and learning topic rules, auth, ACL decisions, etc.), your app sends a **notification intent** to this gateway and the gateway takes care of the rest.

## What it is

A small service that your backend can call like:

> “Notify _this audience_ with _this message_.”

The gateway then:

- figures out the **ntfy topic** to use (using a stable naming convention)
- applies **basic safety rules** (auth, validation, limits — evolving over time)
- publishes the message to **ntfy**
- keeps an **audit trail** (planned / part of the direction)

## What it is NOT

- Not a replacement for ntfy
- Not a new push notification system
- Not a UI for users to manage notifications

**ntfy stays the core**:

- ntfy handles delivery (push/web push/email features), clients, and subscriptions
- the gateway handles “producer integration” and “control plane” concerns

## Why this is useful

This gateway is valuable when:

- you have **multiple services/apps** that need to send notifications
- you want **one standard API** for sending alerts
- you want to avoid spreading ntfy details across codebases
- you care about future needs like:
  - per-tenant API keys
  - rate limits / quotas
  - templates (“order shipped”, “price drop”, etc.)
  - retries / outbox (so transient outages don’t lose notifications)
  - auditing (“what was sent, by whom, when?”)

## Key idea: audiences

Apps don’t send to raw ntfy topics. They send to an **audience**.

Examples:

- `app` → general broadcasts
- `user` → notifications for one user (all their devices)
- `order` → order updates (optional model)
- `product` → price drops / deal alerts for watchers
- `role` → ops/admin/team broadcasts

Your app decides the audience IDs. Prefer IDs that are not guessable (UUIDs/hashes) where possible.

## Topic naming (how routing works)

The gateway generates an ntfy topic using:

`t_{tenantId}.{audienceType}.{audienceId}`

Example:

`t_shop.user.9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d`

This is intentionally stable and predictable:

- easy to debug
- easy to isolate tenants by prefix
- works well with ACL ideas

Apps **do not need** to hardcode this format. They only send `{type, id}`.

## Single-tenant and multi-tenant

This project is designed to be:

- **single-tenant by default** (simple, one deployment for one app)
- **multi-tenant by architecture** (upgrade path when needed)

The same API can support both. The main difference is how the gateway resolves `tenantId`.

## Email (simple by default)

Email is important, but it can add complexity if done too early.

Direction:

- **Default**: use ntfy’s email support (configure SMTP on the ntfy side)
- **Later (optional)**: allow sending email via a dedicated provider directly from the gateway if deeper control is needed

This keeps the system useful without turning it into a huge platform.

## Reliability (what we can and cannot promise)

This gateway can make notification _processing_ reliable (auth, validation, retries, audit).

No system can guarantee a user’s phone receives a push instantly (devices can be offline, OS restrictions, notifications disabled, etc.).

The goal here is:

- apps can send notification intents safely and consistently
- the system is observable (you can see what was attempted and what happened)

## API (v1, starting point)

### `POST /v1/notify`

Send a notification intent.

Example request body:

```json
{
  "audience": { "type": "user", "id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d" },
  "title": "Order shipped",
  "message": "Your order #123 has been shipped",
  "link": "https://shop.example.com/orders/123"
}
```

Example response (shape):

```json
{
  "ok": true,
  "topic": "t_shop.user.9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "published": true
}
```

### Authentication (v1)

The API is intended for **backend producers**, not public browsers.

Direction for v1:

- `Authorization: Bearer <GATEWAY_API_KEY>`

## What’s next (project direction)

Near-term priorities that make this “real”:

- publish to ntfy for real (not a stub)
- enforce authentication
- validate payloads properly
- add a small database for:
  - tenant/api-key mapping
  - audit logs
  - idempotency (avoid duplicates when producers retry)

Longer-term:

- rate limits / quotas
- templates
- outbox + retries for higher reliability
