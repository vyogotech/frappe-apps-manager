# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Claude Code plugin marketplace** for Frappe Framework development tools. It contains the `frappe-apps-manager` plugin, which provides commands, agents, and skills for building Frappe applications.

## Architecture

### Marketplace Structure

```
frappe-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace metadata
└── frappe-apps-manager/          # Main plugin package
    ├── .claude-plugin/
    │   └── plugin.json           # Plugin metadata
    ├── commands/                 # Slash commands (7 total)
    ├── agents/                   # Specialized agents (3 total)
    ├── skills/                   # Model-invoked skills (3 total)
    └── hooks/                    # Automated workflows
        └── hooks.json
```

### Plugin Components

**Commands** (`commands/*.md`): User-invoked workflows with guided steps
- `/frappe-new-app` - App creation
- `/frappe-new-doctype` - DocType creation
- `/frappe-install-app` - App installation
- `/frappe-bench-start` - Start bench
- `/frappe-migrate` - Run migrations
- `/frappe-backup` - Backup site
- `/frappe-deploy` - Production deployment

**Agents** (`agents/*.md`): Specialized AI assistants for specific domains
- `frappe-developer.md` - App and DocType development expert
- `frappe-debugger.md` - Troubleshooting and error analysis
- `frappe-architect.md` - System design and architecture planning

**Skills** (`skills/*/SKILL.md`): Autonomous capabilities invoked by Claude
- `frappe-doctype-builder` - Generate complete DocType JSON structures
- `frappe-api-handler` - Create whitelisted API methods
- `frappe-report-generator` - Build custom reports

**Hooks** (`hooks/hooks.json`): Automated workflows triggered by events
- `pre-tool-use`: Detect Frappe bench context before operations
- `post-tool-use`: Suggest migrations after DocType changes
- `user-prompt-submit`: Validate bench setup for Frappe operations

## Key Design Patterns

### Command Structure
Commands are markdown files with YAML frontmatter containing:
- `description`: Brief summary shown in `/help`
- Main content: Step-by-step instructions for Claude to follow

### Agent Structure
Agents are markdown files defining:
- Role and expertise areas
- Responsibilities and capabilities
- Communication style and best practices
- Common tasks and workflows

### Skill Structure
Skills have `SKILL.md` files with:
- `name` and `description` in YAML frontmatter
- "When to Use" section (Claude uses this to decide invocation)
- Capabilities with code examples
- Best practices and patterns
- Output format specifications

### Hook Configuration
Hooks in `hooks.json` define:
- `name`: Hook identifier
- `description`: Purpose
- `tool_names`: Which tools trigger it (Bash, Write, Edit, etc.)
- `keywords`: User prompt keywords that trigger it
- `command`: Shell command to execute

## Development Workflow

### Plugin Management Commands

```bash
# Add this marketplace
/plugin marketplace add ./frappe-marketplace

# Install the plugin
/plugin install frappe-apps-manager@frappe-marketplace

# Manage plugins
/plugin                           # Interactive plugin management UI
/plugin enable plugin-name        # Enable a disabled plugin
/plugin disable plugin-name       # Disable without uninstalling
/plugin uninstall plugin-name     # Completely remove a plugin

# Verify installation
/help                            # Should show all Frappe commands
```

### Testing the Plugin Locally

```bash
# From the parent directory containing frappe-marketplace/
claude

# In Claude Code session:
/plugin marketplace add ./frappe-marketplace
/plugin install frappe-apps-manager@frappe-marketplace

# After making changes to plugin code:
/plugin uninstall frappe-apps-manager@frappe-marketplace
/plugin install frappe-apps-manager@frappe-marketplace
# (Restart Claude Code to reload changes)
```

### Adding a New Command

1. Create `commands/command-name.md` with frontmatter:
   ```markdown
   ---
   description: Brief description (under 100 chars)
   ---

   # Command Name

   Step-by-step instructions for Claude to follow...
   ```

2. Plugin auto-discovers commands in the `commands/` directory

3. Test: Restart Claude Code, then `/command-name` should work

### Adding a New Agent

1. Create `agents/agent-name.md` with:
   ```markdown
   ---
   description: Brief description of agent's role
   ---

   # Agent Name

   You are a specialized [role] expert...

   ## Core Expertise
   - Area 1
   - Area 2

   ## Responsibilities
   [What the agent does]

   ## Communication Style
   [How the agent responds]
   ```

2. Users invoke agents by describing tasks naturally or explicitly requesting the agent

3. Agents appear in `/agents` command after installation

### Adding a New Skill

1. Create `skills/skill-name/SKILL.md`:
   ```markdown
   ---
   name: skill-name
   description: Clear description of when Claude should use this skill
   ---

   # Skill Name

   ## When to Use This Skill

   Claude should invoke this skill when:
   - Trigger condition 1
   - Trigger condition 2

   ## Capabilities

   ### Feature 1
   ```code examples```

   ### Feature 2
   ```code examples```

   ## Best Practices
   [Guidelines for using the skill]
   ```

2. Claude invokes Skills autonomously based on task context and description

3. Skills are model-invoked (not user-invoked like commands)

### Adding Hooks

Edit `hooks/hooks.json` to add hook definitions:

```json
{
  "hooks": {
    "pre-tool-use": [
      {
        "name": "hook-name",
        "description": "What this hook does",
        "tool_names": ["Bash", "Write", "Edit"],
        "command": "shell command to execute"
      }
    ],
    "post-tool-use": [
      {
        "name": "hook-name",
        "description": "What this hook does",
        "tool_names": ["Write", "Edit"],
        "command": "if [[ condition ]]; then echo 'message'; fi"
      }
    ],
    "user-prompt-submit": [
      {
        "name": "hook-name",
        "description": "What this hook does",
        "keywords": ["keyword1", "keyword2"],
        "command": "validation or setup command"
      }
    ]
  }
}
```

Hook types:
- `pre-tool-use`: Runs before specified tools execute
- `post-tool-use`: Runs after specified tools complete
- `user-prompt-submit`: Runs when user submits prompts containing keywords

### Creating a New Plugin from Scratch

1. **Create plugin directory structure:**
   ```bash
   mkdir new-plugin
   cd new-plugin
   mkdir .claude-plugin commands agents skills hooks
   ```

2. **Create plugin manifest** (`.claude-plugin/plugin.json`):
   ```json
   {
     "name": "new-plugin",
     "description": "Plugin description",
     "version": "1.0.0",
     "author": {
       "name": "Your Name"
     }
   }
   ```

3. **Add components** (commands, agents, skills, hooks as needed)

4. **Test locally:**
   - Create a test marketplace with `marketplace.json`
   - Add plugin reference to marketplace
   - Install and test via `/plugin` commands

### Iterative Development Cycle

1. **Make changes** to commands, agents, skills, or hooks
2. **Uninstall** the plugin: `/plugin uninstall plugin-name@marketplace`
3. **Reinstall** the plugin: `/plugin install plugin-name@marketplace`
4. **Restart** Claude Code to reload changes
5. **Test** the updated functionality
6. **Repeat** until satisfied

### Debugging Plugin Issues

```bash
# Check plugin structure
ls -la frappe-apps-manager/

# Verify directories are at plugin root, not inside .claude-plugin/
# ✓ frappe-apps-manager/commands/
# ✗ frappe-apps-manager/.claude-plugin/commands/

# Test individual components
/help                    # Should show your commands
/agents                  # Should show your agents
```

Common issues:
- **Commands not appearing**: Check frontmatter format and description field
- **Hooks not triggering**: Verify tool_names and keywords match use cases
- **Skills not invoked**: Ensure description clearly states when to use the skill
- **Changes not reflected**: Always restart Claude Code after reinstalling

## Frappe Framework Context

### DocType Structure
DocTypes are Frappe's core data model, consisting of:
- JSON definition (`*.json`): Fields, permissions, naming rules
- Python controller (`*.py`): Business logic methods
- JavaScript form script (`*.js`): Client-side behavior

### Common Frappe Patterns

**Whitelisted API Methods:**
```python
@frappe.whitelist()
def method_name(param):
    """Accessible at /api/method/app.module.method_name"""
    return {"result": "data"}
```

**DocType Controllers:**
```python
class MyDocType(Document):
    def validate(self):
        # Pre-save validation
        pass

    def on_submit(self):
        # After submission
        pass
```

**Permission Checks:**
```python
if not frappe.has_permission("DocType", "write"):
    frappe.throw(_("Not permitted"))
```

## Important Files

- [marketplace.json](.claude-plugin/marketplace.json) - Marketplace configuration
- [plugin.json](frappe-apps-manager/.claude-plugin/plugin.json) - Plugin metadata
- [hooks.json](frappe-apps-manager/hooks/hooks.json) - Hook definitions
- [README.md](README.md) - User-facing documentation

## Best Practices

### For Plugin Development
- Keep command descriptions concise (under 100 chars)
- Provide complete code examples in skills
- Test hooks thoroughly as they run automatically
- Document trigger conditions clearly for skills

### For Frappe Code Generation
- Follow Frappe's naming conventions (snake_case for fields, Title Case for DocTypes)
- Always validate inputs in whitelisted methods
- Use `frappe.throw()` for user-facing errors
- Log errors with `frappe.log_error()` for debugging
- Check permissions before data operations

### Plugin Installation Flow
1. Add marketplace: `/plugin marketplace add ./frappe-marketplace`
2. Install plugin: `/plugin install frappe-apps-manager@frappe-marketplace`
3. Verify: `/help` shows Frappe commands
4. Use: `/frappe-new-app` or describe tasks naturally

### Team Plugin Distribution

For team-wide plugin adoption, configure plugins at the repository level:

1. **Configure repository settings** (`.claude/settings.json`):
   ```json
   {
     "pluginMarketplaces": [
       {
         "name": "frappe-marketplace",
         "source": "https://github.com/Venkateshvenki404224/frappe-marketplace"
       }
     ],
     "plugins": [
       {
         "name": "frappe-apps-manager",
         "marketplace": "frappe-marketplace",
         "enabled": true
       }
     ]
   }
   ```

2. **Team members trust the repository folder** in Claude Code settings

3. **Plugins install automatically** when they open Claude Code in the repository

### Marketplace Sources

Marketplaces can be added from multiple sources:

```bash
# Local directory (for development)
/plugin marketplace add ./frappe-marketplace

# Git repository (for distribution)
/plugin marketplace add https://github.com/Venkateshvenki404224/frappe-marketplace

# Organization/repo format (GitHub shorthand)
/plugin marketplace add Venkateshvenki404224/frappe-marketplace
```

### Version Management

Update `plugin.json` version field when releasing changes:

```json
{
  "name": "frappe-apps-manager",
  "version": "1.1.0",
  "description": "Updated description"
}
```

Use semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes to commands, agents, or skills
- **MINOR**: New features, additional commands or skills
- **PATCH**: Bug fixes, documentation updates

## Target Users

Plugin is designed for developers working with:
- Frappe Framework (v13+)
- ERPNext (built on Frappe)
- Custom Frappe applications
- Frappe bench environments

Users typically need to create DocTypes, APIs, reports, and deploy applications while following Frappe best practices.
