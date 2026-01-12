# Cursor Skills

This directory contains Cursor-compatible skills for Frappe development.

## Structure

Skills in this directory are **symbolic links** to the main skills located in:
```
frappe-apps-manager/skills/
```

This avoids duplication and ensures both Claude Code and Cursor use the same skill definitions.

## Usage

Cursor automatically discovers skills from `.cursor/skills/` directory. No configuration needed!

### Manual Invocation

Type `/` in Agent chat and search for the skill name:
- `/frappe-report-generator` - Generate reports
- `/frappe-doctype-builder` - Generate DocTypes
- `/frappe-api-handler` - Generate API handlers
- etc.

### Available Skills

All 28 skills from `frappe-apps-manager/skills/` are available here via symlinks.

## Maintenance

**Do NOT edit files in this directory directly!**

All edits should be made in:
```
frappe-apps-manager/skills/<skill-name>/SKILL.md
```

The symlinks will automatically reflect the changes.

## Recreating Symlinks

If symlinks are broken, recreate them with:
```bash
cd frappe-apps-manager
for skill in frappe-apps-manager/skills/*/; do
  skill_name=$(basename "$skill")
  if [ -f "$skill/SKILL.md" ]; then
    mkdir -p ".cursor/skills/$skill_name"
    ln -sf "../../frappe-apps-manager/skills/$skill_name/SKILL.md" ".cursor/skills/$skill_name/SKILL.md"
  fi
done
```

## Compatibility

- ✅ Cursor IDE (auto-discovers from `.cursor/skills/`)
- ✅ Claude Code (uses `frappe-apps-manager/skills/`)
- ✅ Single source of truth (no duplication)
