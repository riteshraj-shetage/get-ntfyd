#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [[ -f "$PROJECT_DIR/.env" ]]; then
    set -a
    source "$PROJECT_DIR/.env"
    set +a
fi

cd "$PROJECT_DIR"

BACKUP_DIR="./backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="ntfy-backup-${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

mkdir -p "${BACKUP_PATH}"/{ntfy,caddy,config}

docker cp ntfy:/var/lib/ntfy "${BACKUP_PATH}/ntfy/data" 2>/dev/null || true
docker cp ntfy:/var/cache/ntfy "${BACKUP_PATH}/ntfy/cache" 2>/dev/null || true

cp -r ./ntfy "${BACKUP_PATH}/config/"
cp -r ./caddy "${BACKUP_PATH}/config/"
cp .env "${BACKUP_PATH}/config/" 2>/dev/null || true
cp compose.yml "${BACKUP_PATH}/config/"

docker cp caddy:/data "${BACKUP_PATH}/caddy/data" 2>/dev/null || true

cd "${BACKUP_DIR}"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"

echo "Backup created: ${BACKUP_NAME}.tar.gz"
