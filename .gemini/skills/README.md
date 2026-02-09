# Gemini CLI Skills

This directory contains Gemini CLI-compatible skills for Frappe development.

## Structure

Skills in this directory are **copies** of the main skills located in:
```
frappe-apps-manager/skills/
```

This ensures Claude Code, Cursor, and Gemini CLI all use the same skill definitions, and that the content displays correctly on GitHub.

## Enabling Skills Feature

**Important**: Skills are an experimental feature and must be enabled first!

### Option 1: Via Interactive Settings (Recommended)

1. Start an interactive Gemini CLI session:
   ```bash
   gemini
   ```

2. Open settings:
   ```
   /settings
   ```

3. Search for "Skills" and enable the experimental skills feature

### Option 2: Via Configuration File

Enable in your Gemini CLI configuration:
```json
{
  "experimental": {
    "skills": true
  }
}
```

Configuration location:
- User config: `~/.gemini/config.json`
- Project config: `.gemini/config.json`

## Usage

Once enabled, Gemini CLI automatically discovers skills from `.gemini/skills/` directory.

### Managing Skills

**In an interactive session:**
```
/skills list          # View all available skills
/skills enable <name> # Enable a skill
/skills disable <name> # Disable a skill
/skills reload        # Reload skills
```

**Note**: The `gemini skills` terminal command may not be available in all versions. Use the interactive `/skills` commands instead.

### Skill Discovery Tiers

Gemini CLI discovers skills from:
1. **Project Skills** (`.gemini/skills/`) - This directory
2. **User Skills** (`~/.gemini/skills/`) - Personal skills
3. **Extension Skills** - From installed extensions

Precedence: Project > User > Extension

## Available Skills

All 28 skills from `frappe-apps-manager/skills/` are available here:

- `frappe-report-generator` - Generate reports
- `frappe-doctype-builder` - Generate DocTypes
- `frappe-api-handler` - Generate API handlers
- `frappe-microservice-scaffold` - Scaffold microservices
- ... and 24 more

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

## Syncing After Changes

If skills have been added, modified, or removed in the source directory:
```bash
./sync-skills.sh
```

This copies all skills to both `.cursor/skills/` and `.gemini/skills/`.

## Skill Format

Skills follow the [Agent Skills open standard](https://geminicli.com/docs/cli/skills/):

- Directory with `SKILL.md` file
- YAML frontmatter with `name` and `description`
- Markdown instructions in the body
- Optional: `scripts/`, `references/`, `assets/` subdirectories

## Compatibility

- **Claude Code**: Uses `frappe-apps-manager/skills/` directly
- **Cursor IDE**: Uses `.cursor/skills/` (copies)
- **Gemini CLI**: Uses `.gemini/skills/` (copies)
- **All platforms**: Share the same skill definitions

## References

- [Gemini CLI Skills Documentation](https://geminicli.com/docs/cli/skills/)
- [Agent Skills Open Standard](https://agentskills.io)
