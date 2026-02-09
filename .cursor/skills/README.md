# Cursor Skills

This directory contains Cursor-compatible skills for Frappe development.

## Structure

Skills in this directory are **copies** of the main skills located in:
```
frappe-apps-manager/skills/
```

This ensures both Claude Code and Cursor use the same skill definitions, and that the content displays correctly on GitHub.

## Usage

Cursor automatically discovers skills from `.cursor/skills/` directory. No configuration needed!

### Manual Invocation

Type `/` in Agent chat and search for the skill name:
- `/frappe-report-generator` - Generate reports
- `/frappe-doctype-builder` - Generate DocTypes
- `/frappe-api-handler` - Generate API handlers
- etc.

### Available Skills

All 28 skills from `frappe-apps-manager/skills/` are available here.

## Maintenance

The **source of truth** for all skills is:
```
frappe-apps-manager/skills/<skill-name>/SKILL.md
```

After editing skills in the source directory, run the sync script to update copies:
```bash
./sync-skills.sh
```

**Do NOT edit files in this directory directly** - your changes will be overwritten on the next sync.

## Compatibility

- Cursor IDE (auto-discovers from `.cursor/skills/`)
- Claude Code (uses `frappe-apps-manager/skills/`)
- Gemini CLI (uses `.gemini/skills/`)
- Single source of truth with sync script
