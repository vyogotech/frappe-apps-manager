#!/usr/bin/env bash
#
# sync-skills.sh - Sync skills from source to .cursor/ and .gemini/ directories
#
# The source of truth for all skills is:
#   frappe-apps-manager/skills/<skill-name>/SKILL.md
#
# This script copies them to:
#   .cursor/skills/<skill-name>/SKILL.md
#   .gemini/skills/<skill-name>/SKILL.md
#
# Run this after adding, modifying, or removing skills in the source directory.
#
# Usage:
#   chmod +x sync-skills.sh
#   ./sync-skills.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SOURCE_DIR="frappe-apps-manager/skills"
CURSOR_DIR=".cursor/skills"
GEMINI_DIR=".gemini/skills"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source skills directory not found: $SOURCE_DIR"
    echo "Run this script from the repository root."
    exit 1
fi

# Create target directories if they don't exist
mkdir -p "$CURSOR_DIR" "$GEMINI_DIR"

copied=0
removed=0

# Copy skills from source to targets
for skill_dir in "$SOURCE_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    
    if [ -f "$skill_dir/SKILL.md" ]; then
        # Copy to .cursor/skills/
        mkdir -p "$CURSOR_DIR/$skill_name"
        cp "$skill_dir/SKILL.md" "$CURSOR_DIR/$skill_name/SKILL.md"
        
        # Copy to .gemini/skills/
        mkdir -p "$GEMINI_DIR/$skill_name"
        cp "$skill_dir/SKILL.md" "$GEMINI_DIR/$skill_name/SKILL.md"
        
        copied=$((copied + 1))
    fi
done

# Clean up skills that no longer exist in source
for target_dir in "$CURSOR_DIR" "$GEMINI_DIR"; do
    for skill_dir in "$target_dir"/frappe-*/; do
        [ -d "$skill_dir" ] || continue
        skill_name=$(basename "$skill_dir")
        if [ ! -d "$SOURCE_DIR/$skill_name" ]; then
            rm -rf "$skill_dir"
            removed=$((removed + 1))
            echo "  Removed stale: $target_dir/$skill_name"
        fi
    done
done

echo ""
echo "Skills sync complete!"
echo "  Source:  $SOURCE_DIR"
echo "  Targets: $CURSOR_DIR, $GEMINI_DIR"
echo "  Synced:  $copied skills to each target"
if [ $removed -gt 0 ]; then
    echo "  Removed: $removed stale skill(s)"
fi
echo ""
echo "Tip: Run 'git add .cursor/skills .gemini/skills' to stage the changes."
