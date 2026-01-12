# Gemini CLI Skills Setup Guide

This guide helps you enable and use skills with Gemini CLI.

## Prerequisites

- Gemini CLI installed
- Skills feature enabled (experimental)

## Enabling Skills Feature

Skills are an **experimental feature** in Gemini CLI and must be enabled first.

### Method 1: Interactive Settings (Easiest)

1. Start an interactive Gemini CLI session:
   ```bash
   gemini
   ```

2. Open the settings menu:
   ```
   /settings
   ```

3. Search for "Skills" in the settings UI

4. Toggle the experimental skills feature to **enabled**

5. Exit settings and restart your session if needed

### Method 2: Configuration File

Create or edit your Gemini CLI configuration:

**User-level config** (`~/.gemini/config.json`):
```json
{
  "experimental": {
    "skills": true
  }
}
```

**Project-level config** (`.gemini/config.json` in your project):
```json
{
  "experimental": {
    "skills": true
  }
}
```

## Verifying Skills Are Enabled

After enabling, start an interactive session:
```bash
gemini
```

Then try:
```
/skills list
```

If you see a list of skills (or an empty list), skills are enabled! ✅

If you get an "Unknown command" error, the feature is not enabled yet.

## Using Skills

### In Interactive Session

Once skills are enabled, you can manage them:

```
/skills list              # List all discovered skills
/skills enable <name>     # Enable a specific skill
/skills disable <name>    # Disable a skill
/skills reload            # Reload skills from discovery paths
```

### Skill Discovery

Gemini CLI discovers skills from three locations (in order of precedence):

1. **Project Skills** (`.gemini/skills/`) - This directory ✓
2. **User Skills** (`~/.gemini/skills/`) - Personal skills
3. **Extension Skills** - From installed extensions

**Precedence**: Project > User > Extension

If multiple skills share the same name, the higher-precedence location wins.

## Troubleshooting

### "Unknown arguments: skills, list"

**Problem**: The `gemini skills` terminal command is not recognized.

**Solution**: 
- Skills are managed via interactive commands, not terminal commands
- Use `/skills list` in an interactive session instead
- Make sure you've enabled the experimental skills feature first

### Skills Not Appearing

1. **Check if feature is enabled**: Try `/skills list` in interactive session
2. **Verify symlinks exist**: `ls -la .gemini/skills/`
3. **Check skill format**: Each skill needs a `SKILL.md` file with YAML frontmatter
4. **Reload skills**: `/skills reload` in interactive session

### Symlinks Not Working

If symlinks aren't being discovered:

1. Verify symlinks are valid:
   ```bash
   readlink .gemini/skills/frappe-report-generator/SKILL.md
   ```

2. Check if target exists:
   ```bash
   test -f frappe-apps-manager/skills/frappe-report-generator/SKILL.md && echo "OK" || echo "Missing"
   ```

3. Recreate symlinks:
   ```bash
   ./setup-all-symlinks.sh
   ```

## Example Workflow

1. **Enable skills feature** (one-time setup):
   ```bash
   gemini
   /settings
   # Enable "Skills" experimental feature
   ```

2. **Start a session**:
   ```bash
   gemini
   ```

3. **List available skills**:
   ```
   /skills list
   ```

4. **Enable a skill**:
   ```
   /skills enable frappe-report-generator
   ```

5. **Use the skill**:
   ```
   Create a sales report for Q1 2024
   # Gemini will automatically use frappe-report-generator skill
   ```

## References

- [Gemini CLI Skills Documentation](https://geminicli.com/docs/cli/skills/)
- [Agent Skills Open Standard](https://agentskills.io)
