# Quick Start Guide

Get started with frappe-apps-manager on all platforms in 3 steps.

## Step 1: Setup Symlinks

Run the setup script to create symlinks for Cursor and Gemini CLI:

```bash
cd frappe-apps-manager
chmod +x setup-all-symlinks.sh
./setup-all-symlinks.sh
```

This creates:
- ✅ 28 symlinks for Cursor (`.cursor/skills/`)
- ✅ 28 symlinks for Gemini CLI (`.gemini/skills/`)
- ✅ Configuration file for Gemini CLI (`.gemini/config.json`)

## Step 2: Platform-Specific Setup

### Claude Code

```bash
# In Claude Code session
/plugin marketplace add ./frappe-apps-manager
/plugin install frappe-apps-manager@frappe-marketplace
```

### Cursor IDE

No additional setup needed! Skills auto-discover from `.cursor/skills/`.

Type `/` in Agent chat to see available skills.

### Gemini CLI

1. **Verify setup:**
   ```bash
   ./verify-gemini-setup.sh
   ```

2. **Start interactive session:**
   ```bash
   gemini
   ```

3. **List skills:**
   ```
   /skills list
   ```

4. **Enable a skill:**
   ```
   /skills enable frappe-report-generator
   ```

## Step 3: Verify Everything Works

### Claude Code
```bash
/help  # Should show Frappe commands
```

### Cursor IDE
```
/  # Type / in Agent chat, should see skills
```

### Gemini CLI
```bash
gemini
/skills list  # Should show 28 skills
```

## Troubleshooting

### Gemini CLI: "Unknown arguments: skills"

**Solution**: Skills are managed via interactive commands, not terminal commands.

1. Start interactive session: `gemini`
2. Use: `/skills list` (not `gemini skills list`)

### Skills Not Appearing

1. **Verify symlinks:**
   ```bash
   ./verify-gemini-setup.sh
   ```

2. **Recreate symlinks:**
   ```bash
   ./setup-all-symlinks.sh
   ```

3. **Check config:**
   ```bash
   cat .gemini/config.json
   # Should show: "skills": true
   ```

## What You Get

- ✅ **28 Optimized Skills** - Token-efficient, pattern-based
- ✅ **15 Commands** - Frappe development workflows
- ✅ **10 Agents** - Specialized AI assistants
- ✅ **Multi-Platform** - Works on Claude, Cursor, and Gemini
- ✅ **Single Source** - Edit once, works everywhere

## Next Steps

- Read [SETUP_MULTI_PLATFORM.md](SETUP_MULTI_PLATFORM.md) for detailed setup
- Read [GEMINI_CLI_SETUP.md](GEMINI_CLI_SETUP.md) for Gemini-specific help
- Check [README.md](README.md) for full documentation
