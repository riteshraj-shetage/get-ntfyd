#!/bin/bash

# backup.sh
# Description: Create timestamped backups of files or directories
# Usage: ./backup.sh <source> [destination]

set -e

if [[ $# -eq 0 ]]; then
    echo "❌ Usage: $0 <source> [destination]"
    echo "Example: $0 /path/to/file"
    echo "Example: $0 /path/to/directory /backups"
    exit 1
fi

SOURCE="$1"
DEST="${2:-./backups}"

if [[ ! -e "$SOURCE" ]]; then
    echo "❌ Error: Source '$SOURCE' does not exist"
    exit 1
fi

# Create destination directory if it doesn't exist
mkdir -p "$DEST"

# Get timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Get source basename
BASENAME=$(basename "$SOURCE")

# Create backup filename
BACKUP_NAME="${BASENAME}_${TIMESTAMP}"

if [[ -d "$SOURCE" ]]; then
    BACKUP_NAME="${BACKUP_NAME}.tar.gz"
    BACKUP_PATH="${DEST}/${BACKUP_NAME}"
    
    echo "📦 Creating compressed backup of directory..."
    echo "Source: $SOURCE"
    echo "Destination: $BACKUP_PATH"
    echo ""
    
    tar -czf "$BACKUP_PATH" -C "$(dirname "$SOURCE")" "$BASENAME"
    
    SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
    echo "✅ Backup created: $BACKUP_PATH ($SIZE)"
else
    BACKUP_PATH="${DEST}/${BACKUP_NAME}"
    
    echo "📄 Creating backup of file..."
    echo "Source: $SOURCE"
    echo "Destination: $BACKUP_PATH"
    echo ""
    
    cp "$SOURCE" "$BACKUP_PATH"
    
    SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
    echo "✅ Backup created: $BACKUP_PATH ($SIZE)"
fi
