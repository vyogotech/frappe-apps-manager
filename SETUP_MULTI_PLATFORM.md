# Multi-Platform Skills Setup

This document explains how to set up symbolic links so **Claude Code**, **Cursor IDE**, and **Gemini CLI** can all use the same skills without duplication.

## Overview

All three platforms use the same skill format (Agent Skills open standard), but discover skills from different directories:

- **Claude Code**: `frappe-apps-manager/skills/` (direct)
- **Cursor IDE**: `.cursor/skills/` (symlinks)
- **Gemini CLI**: `.gemini/skills/` (symlinks)

## Structure

```
frappe-apps-manager/
├── .claude-plugin/              # Claude Code plugin
│   └── marketplace.json
├── frappe-apps-manager/
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/                  # Source of truth (28 skills)
│       ├── frappe-report-generator/
│       │   └── SKILL.md
│       └── ...
├── .cursor/                     # Cursor skills (symlinks)
│   └── skills/
│       ├── frappe-report-generator/
│       │   └── SKILL.md -> ../../frappe-apps-manager/skills/frappe-report-generator/SKILL.md
│       └── ...
└── .gemini/                     # Gemini CLI skills (symlinks)
    └── skills/
        ├── frappe-report-generator/
        │   └── SKILL.md -> ../../frappe-apps-manager/skills/frappe-report-generator/SKILL.md
        └── ...
```

## Quick Setup

### Option 1: Automated Script (Recommended)

```bash
cd frappe-apps-manager
chmod +x setup-all-symlinks.sh
./setup-all-symlinks.sh
```

This creates symlinks for both Cursor and Gemini CLI.

### Option 2: Manual Setup

```bash
cd frappe-apps-manager
mkdir -p .cursor/skills .gemini/skills

# Create symlinks for Cursor
for skill_dir in frappe-apps-manager/skills/*/; do
    skill_name=$(basename "$skill_dir")
    if [ -f "$skill_dir/SKILL.md" ]; then
        mkdir -p ".cursor/skills/$skill_name"
        ln -sf "../../frappe-apps-manager/skills/$skill_name/SKILL.md" \
           ".cursor/skills/$skill_name/SKILL.md"
    fi
done

# Create symlinks for Gemini CLI
for skill_dir in frappe-apps-manager/skills/*/; do
    skill_name=$(basename "$skill_dir")
    if [ -f "$skill_dir/SKILL.md" ]; then
        mkdir -p ".gemini/skills/$skill_name"
        ln -sf "../../frappe-apps-manager/skills/$skill_name/SKILL.md" \
           ".gemini/skills/$skill_name/SKILL.md"
    fi
done
```

## Platform-Specific Usage

### Claude Code

```bash
# Install plugin
/plugin marketplace add ./frappe-apps-manager
/plugin install frappe-apps-manager@frappe-marketplace

# Skills are automatically available
# Use commands: /frappe-new-app, /frappe-new-doctype, etc.
```

### Cursor IDE

```bash
# Skills auto-discover from .cursor/skills/
# Type / in Agent chat to see available skills
/scaffold-microservice
/generate-tdd-tests
```

### Gemini CLI

**First, enable experimental skills feature:**

1. Start interactive session: `gemini`
2. Open settings: `/settings`
3. Search for "Skills" and enable it

**Then use skills:**

```bash
# Skills auto-discover from .gemini/skills/
# Manage skills in interactive session
/skills list
/skills enable frappe-report-generator

# Note: Terminal command may not be available in all versions
# Use interactive /skills commands instead
```

## Verification

After setup, verify symlinks:

```bash
# Check Cursor symlinks
ls -la .cursor/skills/*/SKILL.md | head -5

# Check Gemini CLI symlinks
ls -la .gemini/skills/*/SKILL.md | head -5

# Count symlinks
echo "Cursor: $(find .cursor/skills -type l | wc -l)"
echo "Gemini: $(find .gemini/skills -type l | wc -l)"

# Test one symlink
readlink .gemini/skills/frappe-report-generator/SKILL.md
# Should show: ../../frappe-apps-manager/skills/frappe-report-generator/SKILL.md
```

## Benefits

1. **Single Source of Truth**: Skills defined once in `frappe-apps-manager/skills/`
2. **No Duplication**: 28 skills, not 84 files (28 × 3 platforms)
3. **Automatic Sync**: Changes reflect in all platforms instantly
4. **Easy Maintenance**: Edit skills in one place
5. **Version Control**: Only one set of files to track

## Maintenance

**Important**: Always edit skills in the source location:
```
frappe-apps-manager/skills/<skill-name>/SKILL.md
```

The symlinks will automatically reflect changes in all platforms.

## Recreating Symlinks

If symlinks are broken (e.g., after moving directories), just run:
```bash
./setup-all-symlinks.sh
```

## Git Considerations

Symlinks are tracked by Git. Ensure Git handles them properly:

```bash
# Check if symlinks are tracked
git ls-files -s .cursor/skills/ .gemini/skills/

# If needed, ensure Git follows symlinks
git config core.symlinks true
```

## Platform Support Summary

| Platform | Discovery Path | Format | Status |
|----------|---------------|--------|--------|
| **Claude Code** | `frappe-apps-manager/skills/` | Direct | ✅ Native |
| **Cursor IDE** | `.cursor/skills/` | Symlinks | ✅ Supported |
| **Gemini CLI** | `.gemini/skills/` | Symlinks | ✅ Supported |

All platforms use the [Agent Skills open standard](https://agentskills.io), ensuring compatibility.

## References

- [Gemini CLI Skills Docs](https://geminicli.com/docs/cli/skills/)
- [Cursor Skills Docs](https://cursor.com/docs/context/skills)
- [Agent Skills Standard](https://agentskills.io)
