#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

[ -f "compose.yml" ] || { echo "Error: compose.yml not found"; exit 1; }
[ -f ".env" ] || { echo "Error: .env not found"; exit 1; }

docker compose logs -f