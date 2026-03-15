# get-ntfyd

A **notification gateway / control plane** powered by **ntfy**.

It gives backend apps a simple HTTP API to send notification intents (audience + message) without hardcoding ntfy topic conventions across multiple codebases.

## What works today

- ✅ Self-hostable bundle: **ntfy + Caddy (HTTPS) + gateway service** via Docker Compose
- ✅ ntfy is configured with security-minded defaults (`deny-all`, behind proxy, etc.)
- ✅ Helper scripts + Makefile (setup/start/backup/restore/service)
- ✅ Gateway has a health endpoint: `GET /api/health`

## What’s coming next (gateway becoming “real”)

- ⏳ `POST /api/v1/notify` will:
  - enforce producer authentication
  - validate payloads
  - publish to ntfy
  - write audit logs (and later: idempotency + retries)

See docs: `docs/concepts.md`

## Quickstart (Ubuntu/VPS)

### 1) Setup

```bash
make setup
```

This installs Docker + Docker Compose plugin, prepares folders, and creates `.env` from `.env.example`.

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

## Project layout

- `compose.yml` — runs ntfy + caddy + gateway
- `ntfy/` — ntfy server config
- `caddy/` — TLS reverse proxy config
- `gateway/` — FastAPI service (gateway/control plane)
- `docs/` — concepts and docs
- `scripts/` — setup/start/backup/restore/service scripts

## Notes

- The gateway is intended for **backend producers** (services/apps), not direct public browser use.
- Subscriptions and delivery UX remain with **ntfy** (apps/web UI).
