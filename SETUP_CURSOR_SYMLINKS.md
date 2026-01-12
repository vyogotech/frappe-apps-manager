# Setup Cursor Skills Symlinks

This document explains how to set up symbolic links so Cursor can use the same skills as Claude Code, avoiding duplication.

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
└── .cursor/                     # Cursor skills (symlinks)
    └── skills/
        ├── frappe-report-generator/
        │   └── SKILL.md -> ../../frappe-apps-manager/skills/frappe-report-generator/SKILL.md
        └── ...
```

## Setup Instructions

### Option 1: Use the Setup Script

```bash
cd frappe-apps-manager
chmod +x setup-cursor-symlinks.sh
./setup-cursor-symlinks.sh
```

### Option 2: Manual Setup

```bash
cd frappe-apps-manager
mkdir -p .cursor/skills

# Create symlinks for each skill
for skill_dir in frappe-apps-manager/skills/*/; do
    skill_name=$(basename "$skill_dir")
    if [ -f "$skill_dir/SKILL.md" ]; then
        mkdir -p ".cursor/skills/$skill_name"
        ln -sf "../../frappe-apps-manager/skills/$skill_name/SKILL.md" \
           ".cursor/skills/$skill_name/SKILL.md"
        echo "✓ Linked: $skill_name"
    fi
done
```

### Option 3: Python Script

```python
import os
from pathlib import Path

base = Path("frappe-apps-manager")
cursor_skills = base / ".cursor" / "skills"
source_skills = base / "frappe-apps-manager" / "skills"

cursor_skills.mkdir(parents=True, exist_ok=True)

for skill_dir in source_skills.iterdir():
    if skill_dir.is_dir() and (skill_dir / "SKILL.md").exists():
        skill_name = skill_dir.name
        target_dir = cursor_skills / skill_name
        target_dir.mkdir(exist_ok=True)
        
        symlink = target_dir / "SKILL.md"
        source = Path("../../frappe-apps-manager/skills") / skill_name / "SKILL.md"
        
        if symlink.exists() or symlink.is_symlink():
            symlink.unlink()
        
        symlink.symlink_to(source)
        print(f"✓ Linked: {skill_name}")

print(f"\nTotal symlinks: {len(list(cursor_skills.glob('*/SKILL.md')))}")
```

## Verification

After setup, verify symlinks:

```bash
# Check if symlinks exist
ls -la .cursor/skills/*/SKILL.md

# Count symlinks
find .cursor/skills -type l | wc -l

# Test one symlink
readlink .cursor/skills/frappe-report-generator/SKILL.md
# Should show: ../../frappe-apps-manager/skills/frappe-report-generator/SKILL.md
```

## Benefits

1. **Single Source of Truth**: Skills are defined once in `frappe-apps-manager/skills/`
2. **No Duplication**: Changes automatically reflect in both Claude and Cursor
3. **Easy Maintenance**: Edit skills in one place
4. **Version Control**: Only one set of files to track

## Maintenance

**Important**: Always edit skills in the source location:
```
frappe-apps-manager/skills/<skill-name>/SKILL.md
```

The symlinks will automatically reflect changes.

## Recreating Symlinks

If symlinks are broken (e.g., after moving directories), just run the setup script again.

## Git Considerations

Symlinks are tracked by Git, but you may need to configure Git to handle them properly:

```bash
# Check if symlinks are tracked
git ls-files -s .cursor/skills/

# If needed, ensure Git follows symlinks
git config core.symlinks true
```

## Platform Support

- ✅ **Claude Code**: Uses `frappe-apps-manager/skills/` directly
- ✅ **Cursor IDE**: Uses `.cursor/skills/` (symlinks to source)
- ✅ **Both**: Share the same skill definitions via symlinks
