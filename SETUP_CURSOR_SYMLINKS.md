# Setup Cursor Skills

This document explains how Cursor uses the same skills as Claude Code.

## Structure

```
frappe-apps-manager/
├── .claude-plugin/              # Claude Code plugin
│   └── marketplace.json
├── frappe-apps-manager/
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/                  # Source of truth (Claude format)
│       ├── frappe-report-generator/
│       │   └── SKILL.md
│       └── ...
└── .cursor/                     # Cursor skills (copies)
    └── skills/
        ├── frappe-report-generator/
        │   └── SKILL.md
        └── ...
```

## How It Works

Skills are maintained in `frappe-apps-manager/skills/` (the source of truth) and copied to `.cursor/skills/` using the sync script.

## Syncing Skills

After adding or modifying skills in the source directory:

```bash
./sync-skills.sh
```

This copies all skills to both `.cursor/skills/` and `.gemini/skills/`.

## Verification

After syncing, verify the copies:

```bash
# Check if skill files exist with actual content
head -5 .cursor/skills/frappe-report-generator/SKILL.md

# Count skills
ls .cursor/skills/*/SKILL.md | wc -l
```

## Benefits

1. **Single Source of Truth**: Skills are defined once in `frappe-apps-manager/skills/`
2. **Works on GitHub**: Files contain actual content (not path references)
3. **Easy Maintenance**: Edit skills in one place, sync with one command

## Maintenance

**Important**: Always edit skills in the source location:
```
frappe-apps-manager/skills/<skill-name>/SKILL.md
```

Then run the sync script to propagate changes.

## Platform Support

- **Claude Code**: Uses `frappe-apps-manager/skills/` directly
- **Cursor IDE**: Uses `.cursor/skills/` (copies)
- **Gemini CLI**: Uses `.gemini/skills/` (copies)
- **All**: Share the same skill definitions via sync script
