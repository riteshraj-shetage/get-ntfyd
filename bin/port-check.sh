#!/bin/bash

# port-check.sh
# Description: Check what process is using a specific port
# Usage: ./port-check.sh <port>

set -e

if [[ $# -eq 0 ]]; then
    echo "❌ Usage: $0 <port>"
    echo "Example: $0 8080"
    exit 1
fi

PORT=$1

# Validate port number
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "❌ Error: Invalid port number. Must be between 1 and 65535."
    exit 1
fi

echo "🔍 Checking port $PORT..."
echo ""

# Check if port is in use
if command -v lsof &> /dev/null; then
    # Using lsof (macOS/Linux)
    PROCESS=$(lsof -i ":$PORT" -P -n 2>/dev/null || true)
    
    if [[ -z "$PROCESS" ]]; then
        echo "✅ Port $PORT is available"
    else
        echo "🚨 Port $PORT is in use:"
        echo "$PROCESS"
    fi
elif command -v netstat &> /dev/null; then
    # Using netstat (Linux/Windows)
    PROCESS=$(netstat -tulpn 2>/dev/null | grep ":$PORT " || true)
    
    if [[ -z "$PROCESS" ]]; then
        echo "✅ Port $PORT is available"
    else
        echo "🚨 Port $PORT is in use:"
        echo "$PROCESS"
    fi
else
    echo "❌ Neither lsof nor netstat found. Cannot check port."
    exit 1
fi
