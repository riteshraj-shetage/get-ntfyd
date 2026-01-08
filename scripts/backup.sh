#!/usr/bin/env bash
set -euo pipefail

TS=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="./backup/$TS"

mkdir -p "$BACKUP_DIR"

# Copy critical files
cp -a ./ntfy/users.db "$BACKUP_DIR/"
cp -a ./data "$BACKUP_DIR/data"
cp -a ./ntfy/server.yml ./caddy/Caddyfile ./.env "$BACKUP_DIR/"

# Archive
tar -czf "./backup/ntfy-backup-$TS.tar.gz" -C "$BACKUP_DIR" .
rm -rf "$BACKUP_DIR"

echo "Backup created: ./backup/ntfy-backup-$TS.tar.gz"
