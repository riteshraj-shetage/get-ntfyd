#!/bin/bash

# file-organizer.sh
# Description: Organize files in a directory by their extensions
# Usage: ./file-organizer.sh [directory]

set -e

# Get target directory (default to current directory)
TARGET_DIR="${1:-.}"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "❌ Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

echo "📂 Organizing files in: $TARGET_DIR"
echo ""

# Change to target directory
cd "$TARGET_DIR"

# Count files to organize
FILE_COUNT=$(find . -maxdepth 1 -type f | wc -l)
echo "📊 Found $FILE_COUNT files to organize"
echo ""

# Organize files by extension
for file in *; do
    # Skip if no files match or if it's a directory
    [[ -f "$file" ]] || continue
    
    # Skip files without extensions
    [[ "$file" == *.* ]] || continue
    
    # Get file extension
    extension="${file##*.}"
    extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    # Create directory for extension if it doesn't exist
    if [[ ! -d "$extension_lower" ]]; then
        mkdir -p "$extension_lower"
        echo "📁 Created directory: $extension_lower/"
    fi
    
    # Move file to its extension directory
    if [[ -f "$file" ]]; then
        mv "$file" "$extension_lower/"
        echo "  ➡️  Moved: $file → $extension_lower/"
    fi
done

echo ""
echo "✅ Organization complete!"
