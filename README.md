# get-ntfyd

A **notification gateway / control plane** powered by **ntfy**.

It gives backend apps a simple HTTP API to send notification intents (`audience` + `message`) without hardcoding ntfy topic conventions across multiple codebases.

## What works today

- ✅ Self-hostable bundle: **ntfy + Caddy (HTTPS) + gateway service** via Docker Compose
- ✅ ntfy is configured with security-minded defaults (`deny-all`, behind proxy, etc.)
- ✅ Helper scripts + Makefile (setup/start/backup/restore/service)
- ✅ Gateway has a health endpoint: `GET /api/health`

## What’s coming next (gateway becoming “real”)

- ⏳ `POST /api/v1/notify` will:
  - enforce producer authentication (`Authorization: Bearer <GATEWAY_API_KEY>`)
  - validate payloads & resolve audiences (`{ "type": "user", "id": "..." }`)
  - publish to ntfy using stable topics (`t_{tenantId}.{audienceType}.{audienceId}`)
  - write audit logs (and later: idempotency + retries)

Check out [concepts.md](./docs/concepts.md) for more information.

## Quickstart (Ubuntu/VPS)

### 1) Setup

```bash
make setup
```

This installs Docker + Docker Compose plugin, prepares folders, and creates `.env` file.

### 2) Configure environment

Edit `.env`:

- `PUBLIC_HOST` (your domain)
- `EMAIL` (for TLS cert)
- `TZ` (timezone)

Optional (planned):

- `DEFAULT_TENANT_ID`
- `GATEWAY_API_KEY`

### 3) Start

```bash
make start
```

After start:

- ntfy: `https://<PUBLIC_HOST>/`
- gateway health: `https://<PUBLIC_HOST>/api/health`

## How topic routing works

Backend apps send intents to **audiences** instead of raw ntfy topics. The gateway translates these into predictable ntfy topics:

`t_{tenantId}.{audienceType}.{audienceId}`

- **Example Request (`POST /api/v1/notify`):**

```json
{
  "audience": { "type": "user", "id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d" },
  "title": "Order shipped",
  "message": "Your order #123 has been shipped"
}
```

- **Resolved ntfy Topic:** `t_main.user.9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d`

## Project layout

- `compose.yml` — runs ntfy + caddy + gateway
- `ntfy/` — ntfy server config
- `caddy/` — TLS reverse proxy config
- `gateway/` — FastAPI service (gateway/control plane)
- `docs/` — concepts and docs
- `scripts/` — setup/start/backup/restore/service scripts

> [!NOTE]
> The gateway is intended for **backend producers** (services/apps), not direct public browser use.
> Subscriptions and delivery UX remain with **ntfy** (apps/web UI).
