# Frappe Apps Manager Plugin

A comprehensive Claude Code plugin for Frappe Framework development, providing tools, commands, agents, and Skills to streamline your Frappe application development workflow.

## Overview

The Frappe Apps Manager plugin extends Claude Code with specialized capabilities for building, deploying, and maintaining Frappe applications. Whether you're creating new apps, designing DocTypes, debugging issues, or deploying to production, this plugin provides expert assistance at every step.

## Features

### Custom Commands

Access powerful Frappe-specific commands directly in Claude Code:

- **`/frappe-new-app`** - Create a new Frappe application with proper structure
- **`/frappe-install-app`** - Install a Frappe app to a site
- **`/frappe-bench-start`** - Start Frappe bench with proper configuration
- **`/frappe-migrate`** - Run database migrations for Frappe apps
- **`/frappe-backup`** - Backup Frappe site data and files
- **`/frappe-new-doctype`** - Create a new DocType in a Frappe app
- **`/frappe-deploy`** - Deploy Frappe apps to production environment

### Specialized Agents

Invoke expert agents for specific tasks:

- **Frappe Developer** - Specialized in creating apps, DocTypes, and custom scripts
- **Frappe Debugger** - Expert at troubleshooting errors, logs, and performance issues
- **Frappe Architect** - Designs app architecture, data models, and system integration

### Agent Skills

Model-invoked capabilities that Claude uses autonomously:

- **frappe-doctype-builder** - Build DocTypes with fields, permissions, and naming
- **frappe-api-handler** - Create custom API endpoints and whitelisted methods
- **frappe-report-generator** - Generate custom reports and data analysis

### Hooks

Automated workflows for Frappe development:

- **frappe-context-detector** - Automatically detects if you're in a Frappe bench
- **frappe-auto-migrate** - Reminds you to run migrations after DocType changes
- **frappe-bench-validator** - Validates bench setup before operations

## Installation

### Prerequisites

- Claude Code installed on your machine
- Frappe Framework knowledge (basic to intermediate)
- A Frappe bench for testing (recommended)

### Quick Install

1. **Add the Frappe marketplace:**
   ```shell
   /plugin marketplace add ./frappe-marketplace
   ```

2. **Install the plugin:**
   ```shell
   /plugin install frappe-apps-manager@frappe-marketplace
   ```

3. **Verify installation:**
   ```shell
   /help
   ```
   You should see all Frappe commands listed.

4. **Try a command:**
   ```shell
   /frappe-new-app
   ```

## Usage Guide

### Creating a New Frappe App

```shell
/frappe-new-app
```

Claude will guide you through:
1. App naming and configuration
2. Module setup
3. Installation to a site
4. Next steps for development

### Building DocTypes

```shell
/frappe-new-doctype
```

Or simply ask Claude:
> "Create a Customer DocType with name, email, and phone fields"

Claude will automatically use the `frappe-doctype-builder` Skill to generate complete DocType JSON and controller files.

### Creating API Endpoints

Ask Claude to create APIs:
> "Create an API endpoint to get customer details by email"

Claude will use the `frappe-api-handler` Skill to generate secure, whitelisted methods with proper validation and error handling.

### Generating Reports

Request custom reports:
> "Create a sales analysis report grouped by customer"

Claude will use the `frappe-report-generator` Skill to create query or script reports with filters, charts, and summaries.

### Debugging Issues

When you encounter errors:
> "I'm getting a permission error when submitting Sales Orders"

Claude can invoke the **Frappe Debugger** agent to analyze logs, check permissions, and provide solutions.

### Deploying to Production

```shell
/frappe-deploy
```

Claude will guide you through:
1. Pre-deployment checklist
2. Backup creation
3. Migration execution
4. Service restart
5. Post-deployment verification

## Plugin Structure

```
frappe-marketplace/
├── .claude-plugin/
│   └── marketplace.json
└── frappe-apps-manager/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── commands/               # 7 custom commands
    │   ├── frappe-new-app.md
    │   ├── frappe-install-app.md
    │   ├── frappe-bench-start.md
    │   ├── frappe-migrate.md
    │   ├── frappe-backup.md
    │   ├── frappe-new-doctype.md
    │   └── frappe-deploy.md
    ├── agents/                 # 3 specialized agents
    │   ├── frappe-developer.md
    │   ├── frappe-debugger.md
    │   └── frappe-architect.md
    ├── skills/                 # 3 agent Skills
    │   ├── frappe-doctype-builder/
    │   │   └── SKILL.md
    │   ├── frappe-api-handler/
    │   │   └── SKILL.md
    │   └── frappe-report-generator/
    │       └── SKILL.md
    └── hooks/                  # Automated workflows
        └── hooks.json
```

## Development Workflow

### Typical Development Session

1. **Navigate to your bench:**
   ```bash
   cd /path/to/frappe-bench
   claude
   ```

2. **Create a new app:**
   ```shell
   /frappe-new-app
   ```

3. **Build your DocTypes:**
   > "Create a Project DocType with fields for project name, start date, end date, and status"

4. **Add business logic:**
   > "Add validation to ensure end date is after start date"

5. **Create APIs:**
   > "Create an API to get all active projects"

6. **Generate reports:**
   > "Create a report showing projects by status"

7. **Test and debug:**
   > "Why am I getting a validation error when saving projects?"

8. **Deploy:**
   ```shell
   /frappe-deploy
   ```

## Best Practices

### When to Use Commands vs Agents

**Use Commands when:**
- You want guided, step-by-step workflows
- You're performing standard operations (backup, migrate, deploy)
- You want consistent, repeatable processes

**Use Agents when:**
- You need expert consultation on architecture
- You're debugging complex issues
- You want detailed code review or optimization suggestions

### Leveraging Skills

Skills are invoked automatically by Claude when appropriate. You don't need to explicitly call them. Just describe what you want:

**DocType Building:**
> "I need a Customer DocType with contact details and credit limit"

**API Creation:**
> "Create an endpoint to update customer email addresses"

**Report Generation:**
> "Show me monthly sales trends by product category"

## Troubleshooting

### Plugin Not Loading

1. Verify installation:
   ```shell
   /plugin
   ```
   Check that `frappe-apps-manager` appears in the installed plugins list.

2. Check marketplace:
   ```shell
   /plugin marketplace list
   ```
   Ensure `frappe-marketplace` is added.

3. Restart Claude Code

### Commands Not Appearing

After installing the plugin, you may need to restart Claude Code for commands to appear in `/help`.

### Hooks Not Triggering

Hooks run based on specific conditions. Check:
- Are you in a Frappe bench directory?
- Are you using the relevant tools (Bash, Write, Edit)?
- Check hook configuration in `hooks/hooks.json`

## Advanced Usage

### Combining Multiple Features

Example: Building a complete module

1. **Plan the architecture:**
   > "I want to build a project management module. Help me design the DocTypes and their relationships."

   (Claude invokes **Frappe Architect** agent)

2. **Create the app:**
   ```shell
   /frappe-new-app
   ```

3. **Build DocTypes:**
   > "Create the DocTypes we discussed"

   (Claude uses **frappe-doctype-builder** Skill)

4. **Add APIs:**
   > "Create APIs for project CRUD operations"

   (Claude uses **frappe-api-handler** Skill)

5. **Build reports:**
   > "Create a project timeline report"

   (Claude uses **frappe-report-generator** Skill)

6. **Test:**
   ```shell
   /frappe-bench-start
   ```

7. **Deploy:**
   ```shell
   /frappe-deploy
   ```

### Customizing the Plugin

You can extend this plugin by:

1. **Adding more commands** - Create `.md` files in `commands/`
2. **Creating new agents** - Add agent definitions in `agents/`
3. **Building Skills** - Create new Skills in `skills/`
4. **Configuring hooks** - Modify `hooks/hooks.json`

See [Claude Code Plugin Documentation](https://code.claude.com/docs/en/plugins) for details.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch
3. Add your enhancements
4. Test thoroughly with a Frappe bench
5. Submit a pull request

### Development Setup

```bash
# Clone the marketplace
git clone <repository-url>
cd frappe-marketplace

# Make changes to the plugin
cd frappe-apps-manager

# Test locally
cd ../..
claude
/plugin marketplace add ./frappe-marketplace
/plugin install frappe-apps-manager@frappe-marketplace
```

## Version History

### v1.0.0 (Current)
- Initial release
- 7 custom commands
- 3 specialized agents
- 3 agent Skills
- Automated hooks for common workflows

## Support

### Getting Help

- **Documentation:** [Frappe Framework Docs](https://frappeframework.com/docs)
- **Plugin Issues:** Create an issue in the repository
- **Claude Code Help:** `/help` command or [Claude Code Docs](https://code.claude.com/docs)

### Common Questions

**Q: Do I need a running Frappe bench to use this plugin?**
A: While many features work without a bench, having a test bench provides the best experience for testing commands and validating generated code.

**Q: Can I use this with ERPNext?**
A: Yes! ERPNext is built on Frappe Framework, so all these tools work seamlessly with ERPNext development.

**Q: Will this work with Frappe Cloud?**
A: Most development features work locally. For deployment, adjust the `/frappe-deploy` workflow for Frappe Cloud's deployment process.

**Q: Can I use this for Frappe version X?**
A: This plugin is designed to work with modern Frappe versions (v13+). Some features may need adjustments for older versions.

## License

MIT License - See LICENSE file for details

## Acknowledgments

- Frappe Framework team for the amazing framework
- Anthropic for Claude and Claude Code
- Frappe community for development best practices

## Related Resources

- [Frappe Framework Documentation](https://frappeframework.com/docs)
- [Frappe GitHub](https://github.com/frappe/frappe)
- [ERPNext](https://erpnext.com)
- [Frappe School](https://frappe.school)
- [Claude Code Documentation](https://code.claude.com/docs)

---

**Happy Frappe Development!** 🚀

Built with ❤️ for the Frappe community
