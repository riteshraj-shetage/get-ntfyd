#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

if [[ -f "$PROJECT_DIR/.env" ]]; then
    set -a
    source "$PROJECT_DIR/.env"
    set +a
fi

[ $# -eq 0 ] && echo "Usage: $0 <backup-archive.tar.gz>" && exit 1

BACKUP_ARCHIVE="$1"
[ ! -f "${BACKUP_ARCHIVE}" ] && echo "Error: Backup archive not found" && exit 1

docker compose down

TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

tar -xzf "${BACKUP_ARCHIVE}" -C "${TEMP_DIR}"
BACKUP_NAME=$(basename "${BACKUP_ARCHIVE}" .tar.gz)
BACKUP_PATH="${TEMP_DIR}/${BACKUP_NAME}"

NTFY_DATA_VOLUME="ntfy-data"
NTFY_CACHE_VOLUME="ntfy-cache"
CADDY_DATA_VOLUME="caddy-data"

[ -d "${BACKUP_PATH}/ntfy/data" ] && docker run --rm \
    -v "${NTFY_DATA_VOLUME}:/restore-target" \
    -v "${BACKUP_PATH}/ntfy/data:/backup:ro" \
    alpine sh -c "rm -rf /restore-target/* /restore-target/.[!.]* 2>/dev/null; cp -a /backup/. /restore-target/"

[ -d "${BACKUP_PATH}/ntfy/cache" ] && docker run --rm \
    -v "${NTFY_CACHE_VOLUME}:/restore-target" \
    -v "${BACKUP_PATH}/ntfy/cache:/backup:ro" \
    alpine sh -c "rm -rf /restore-target/* /restore-target/.[!.]* 2>/dev/null; cp -a /backup/. /restore-target/"

[ -d "${BACKUP_PATH}/caddy/data" ] && docker run --rm \
    -v "${CADDY_DATA_VOLUME}:/restore-target" \
    -v "${BACKUP_PATH}/caddy/data:/backup:ro" \
    alpine sh -c "rm -rf /restore-target/* /restore-target/.[!.]* 2>/dev/null; cp -a /backup/. /restore-target/"

if [ -d "${BACKUP_PATH}/config" ]; then
    [ -d "${BACKUP_PATH}/config/ntfy" ] && cp -a "${BACKUP_PATH}/config/ntfy/." ./ntfy/
    [ -d "${BACKUP_PATH}/config/caddy" ] && cp -a "${BACKUP_PATH}/config/caddy/." ./caddy/
    [ -f "${BACKUP_PATH}/config/.env" ] && cp "${BACKUP_PATH}/config/.env" ./.env
    [ -f "${BACKUP_PATH}/config/compose.yml" ] && cp "${BACKUP_PATH}/config/compose.yml" ./compose.yml
fi

docker compose up -d

echo "Restore complete."
