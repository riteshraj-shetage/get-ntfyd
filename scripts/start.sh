#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

[ -f "compose.yml" ] || { echo "Error: compose.yml not found"; exit 1; }
[ -f ".env" ] || { echo "Error: .env not found"; exit 1; }

set -a
source .env
set +a

sudo timedatectl set-timezone "$TZ"

[ -z "$DOMAIN" ] && { echo "Error: DOMAIN not set"; exit 1; }
[ -z "$EMAIL" ] && { echo "Error: EMAIL not set"; exit 1; }
[ -z "$NTFY_BASE_URL" ] && { echo "Error: NTFY_BASE_URL not set"; exit 1; }

if ! docker ps >/dev/null 2>&1; then
  echo -e "\033[1;33mIMPORTANT:\033[0m Run \033[7mnewgrp docker\033[0m (or log out/in) then try again."
  exit 1
fi

docker compose up -d

echo "gateway is starting at https://${DOMAIN}/api/health"
echo "ntfy is starting at https://${DOMAIN}"
