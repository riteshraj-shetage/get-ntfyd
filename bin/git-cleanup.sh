#!/bin/bash

# git-cleanup.sh
# Description: Clean up merged Git branches (both local and remote tracking)
# Usage: ./git-cleanup.sh [--dry-run]

set -e

DRY_RUN=false

# Parse arguments
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "🔍 DRY RUN MODE - No changes will be made"
    echo ""
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"
echo ""

# Get default branch (main or master)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
echo "🌳 Default branch: $DEFAULT_BRANCH"
echo ""

# Fetch latest changes
echo "🔄 Fetching latest changes..."
git fetch --prune

echo ""
echo "🧹 Merged branches to delete:"
echo "----------------------------"

# Find merged branches
MERGED_BRANCHES=$(git branch --merged "$DEFAULT_BRANCH" | grep -v "^\*" | grep -v "$DEFAULT_BRANCH" | grep -v "master" | grep -v "main" || true)

if [[ -z "$MERGED_BRANCHES" ]]; then
    echo "✨ No merged branches to clean up!"
else
    echo "$MERGED_BRANCHES"
    echo ""
    
    if [[ "$DRY_RUN" == false ]]; then
        echo "🗑️  Deleting merged branches..."
        echo "$MERGED_BRANCHES" | xargs git branch -d
        echo "✅ Cleanup complete!"
    else
        echo "ℹ️  Run without --dry-run to delete these branches"
    fi
fi
