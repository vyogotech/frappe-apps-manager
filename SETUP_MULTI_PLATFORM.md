# Multi-Platform Skills Setup

This document explains how **Claude Code**, **Cursor IDE**, and **Gemini CLI** all use the same skills.

## Overview

All three platforms use the same skill format (Agent Skills open standard), but discover skills from different directories:

- **Claude Code**: `frappe-apps-manager/skills/` (direct)
- **Cursor IDE**: `.cursor/skills/` (copies)
- **Gemini CLI**: `.gemini/skills/` (copies)

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
├── .cursor/                     # Cursor skills (copies)
│   └── skills/
│       ├── frappe-report-generator/
│       │   └── SKILL.md
│       └── ...
├── .gemini/                     # Gemini CLI skills (copies)
│   └── skills/
│       ├── frappe-report-generator/
│       │   └── SKILL.md
│       └── ...
└── sync-skills.sh               # Script to sync copies
```

## How It Works

The **source of truth** for all skills is `frappe-apps-manager/skills/`. The `sync-skills.sh` script copies skills to `.cursor/skills/` and `.gemini/skills/` so each platform can discover them.

### Syncing Skills

After adding, modifying, or removing skills in the source directory:

```bash
./sync-skills.sh
```

This copies all skills to both target directories and cleans up any stale skills.

## Platform-Specific Usage

### Claude Code

```bash
# Install plugin
/plugin marketplace add vyogotech/frappe-apps-manager
/plugin install frappe-apps-manager@vyogotech

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
```

## Verification

After syncing, verify the copies:

```bash
# Check Cursor skills
ls .cursor/skills/*/SKILL.md | wc -l

# Check Gemini CLI skills
ls .gemini/skills/*/SKILL.md | wc -l

# Verify content (should show actual skill content, not paths)
head -5 .gemini/skills/frappe-report-generator/SKILL.md
head -5 .cursor/skills/frappe-report-generator/SKILL.md
```

## Benefits

1. **Single Source of Truth**: Skills defined once in `frappe-apps-manager/skills/`
2. **Works on GitHub**: Copies contain actual content (not symlink paths)
3. **Works on Any Clone**: No machine-specific paths or setup scripts needed
4. **Easy Maintenance**: Edit skills in one place, run `./sync-skills.sh`

## Maintenance

**Important**: Always edit skills in the source location:
```
frappe-apps-manager/skills/<skill-name>/SKILL.md
```

Then run the sync script:
```bash
./sync-skills.sh
```

## Platform Support Summary

| Platform | Discovery Path | Method | Status |
|----------|---------------|--------|--------|
| **Claude Code** | `frappe-apps-manager/skills/` | Direct | Native |
| **Cursor IDE** | `.cursor/skills/` | Copies | Supported |
| **Gemini CLI** | `.gemini/skills/` | Copies | Supported |

All platforms use the [Agent Skills open standard](https://agentskills.io), ensuring compatibility.

## References

- [Gemini CLI Skills Docs](https://geminicli.com/docs/cli/skills/)
- [Cursor Skills Docs](https://cursor.com/docs/context/skills)
- [Agent Skills Standard](https://agentskills.io)
