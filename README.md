# Frappe Apps Manager Plugin

A comprehensive Claude Code plugin for Frappe Framework development with **100% SDLC coverage** - 15 commands, 10 agents, and 55 skills for complete Frappe/ERPNext development lifecycle including microservices and containerization.

## Quick Start

Install in 2 commands:

```bash
/plugin marketplace add vyogotech/frappe-apps-manager
/plugin install frappe-apps-manager@vyogotech
```

Then restart Claude Code and run `/help` to see all 15 Frappe commands!

## Overview

The Frappe Apps Manager plugin extends Claude Code with specialized capabilities for building, deploying, and maintaining Frappe applications. Whether you're creating new apps, designing DocTypes, debugging issues, or deploying to production, this plugin provides expert assistance at every step.

**What's New in v2.2.0:**
- 🆕 5 new advanced skills (Background Jobs, Real-time, Portal, Monkey Patching, Patches)
- 🆕 Upgraded `frappe-app-scaffold` with modern standards (v14/v15/v16+)
- 🆕 Full `pyproject.toml` support for app creation
- 🆕 Enhanced module management and `modules.txt` automation
- 🆕 55 total skills for true 100% SDLC coverage

**What's New in v2.1.0:**
- 🆕 11 new microservice skills (scaffolding, tenant isolation, container testing, and more)
- 🆕 2 new containerization skills (Containerfile and compose.yml generation)
- 🆕 Enhanced existing skills with microservice patterns
- 🆕 Unified skill set for both standard Frappe and microservices
- 🆕 Complete frappe-microservice-lib integration
- 🆕 Automatic Containerfile and compose.yml generation during app creation

**What's New in v2.0.0:**
- 🆕 8 new commands (site management, testing, debugging, operations)
- 🆕 7 new agents (testing, security, devops, performance, integration, data, UI/UX)
- 🆕 12 new skills (client scripts, tests, workflows, webhooks, migrations, and more)
- 🆕 Frappe conventional commit output style
- 🆕 Enhanced hooks with smart automation
- ⭐ All components reference real ERPNext/Frappe core code
- ⭐ 120+ core app references, 175+ working code examples

## Features

### 15 Commands - Complete Workflow Coverage

**Site & Environment:**
- **`/frappe-new-site`** 🆕 - Create new Frappe site with database setup
- **`/frappe-config`** 🆕 - Manage site configuration and settings
- **`/frappe-db-reset`** 🆕 - Reset database for development

**Development & Testing:**
- **`/frappe-new-app`** - Create new Frappe application
- **`/frappe-new-doctype`** - Create new DocType
- **`/frappe-test`** 🆕 - Run tests with coverage reports
- **`/frappe-console`** 🆕 - Interactive Python console

**Operations & Debugging:**
- **`/frappe-logs`** 🆕 - View and analyze bench logs
- **`/frappe-cache`** 🆕 - Manage Redis cache
- **`/frappe-role-manager`** 🆕 - Manage roles and permissions
- **`/frappe-backup`** - Backup site data
- **`/frappe-migrate`** - Run database migrations

**Deployment:**
- **`/frappe-install-app`** - Install app to site
- **`/frappe-bench-start`** - Start development server
- **`/frappe-deploy`** - Deploy to production

### 10 Specialized Agents

**Strategic & Development:**
- **frappe-architect** - System design and architecture
- **frappe-developer** - Implementation and coding
- **frappe-ui-ux** 🆕 - Frontend and user experience

**Quality & Security:**
- **frappe-tester** 🆕 - Testing strategies and QA
- **frappe-security** 🆕 - Security review and compliance
- **frappe-performance** 🆕 - Performance optimization

**Operations & Integration:**
- **frappe-devops** 🆕 - CI/CD and deployment
- **frappe-debugger** - Troubleshooting and diagnostics
- **frappe-integration** 🆕 - API and webhook integration
- **frappe-data-engineer** 🆕 - Data migration and management

### 55 Autonomous Skills

**Advanced Backend & Performance (New in v2.2.0):**
- **frappe-background-jobs** 🆕 - `frappe.enqueue` and scheduled tasks
- **frappe-realtime-handler** 🆕 - Socket.io live updates and notifications
- **frappe-monkey-patching** 🆕 - Expert core overrides and runtime patching
- **frappe-patch-generator** 🆕 - Robust database migration patches

**Portal & Web (New in v2.2.0):**
- **frappe-portal-generator** 🆕 - Custom portal pages and dynamic web routes

**Core Development:**
- **frappe-app-scaffold** ⭐ - Upgraded for modern v15 standards (pyproject.toml)
- **frappe-doctype-builder** - Generate DocType JSON structures
- **frappe-api-handler** - Create REST API endpoints
- **frappe-client-script-generator** 🆕 - JavaScript form scripts (10 patterns)
- **frappe-report-generator** - Custom reports and analytics

**Testing & Quality:**
- **frappe-unit-test-generator** 🆕 - Unit test generation
- **frappe-integration-test-generator** 🆕 - Integration test scenarios

**Workflows & States:**
- **frappe-workflow-generator** 🆕 - Approval workflows
- **frappe-state-machine-helper** 🆕 - State transition logic

**Integration & Data:**
- **frappe-webhook-manager** 🆕 - Webhook handlers
- **frappe-external-api-connector** 🆕 - External API clients
- **frappe-data-migration-generator** 🆕 - Data migration scripts
- **frappe-fixture-creator** 🆕 - Test and master data fixtures

**Optimization & UX:**
- **frappe-performance-optimizer** 🆕 - Query and cache optimization
- **frappe-web-form-builder** 🆕 - Public web forms
- **frappe-documentation-generator** 🆕 - API documentation

**Microservices (New in v2.1.0):**
- **frappe-microservice-scaffold** 🆕 - Generate complete microservice boilerplate
- **frappe-secure-endpoint** 🆕 - Generate tenant-aware API endpoints
- **frappe-tenant-query** 🆕 - Generate tenant-isolated database queries
- **frappe-controller** 🆕 - Generate DocType controllers for microservices
- **frappe-document-hooks** 🆕 - Generate document lifecycle hooks
- **frappe-tdd-tests** 🆕 - Generate TDD unit tests (Frappe-style)
- **frappe-e2e-tests** 🆕 - Generate container-based E2E tests
- **frappe-add-service-compose** 🆕 - Add service to dev-podman-compose.yml
- **frappe-concept-explainer** 🆕 - Explain Frappe/ERPNext concepts
- **frappe-microservice-pattern** 🆕 - Explain microservice architecture patterns
- **frappe-microservice-validator** 🆕 - Validate microservice code patterns

**Containerization (New in v2.1.0):**
- **frappe-containerfile-generator** 🆕 - Generate Containerfile for Frappe apps (version 15)
- **frappe-compose-dev-generator** 🆕 - Generate compose.yml for local development with vyogo's sne images

### Output Style

- **frappe-commit** 🆕 - Frappe conventional commit standard with semantic versioning

### 7 Enhanced Hooks

Smart automation for common tasks:

- **frappe-context-detector** - Detects Frappe bench directory
- **frappe-auto-migrate** - Reminds to run migrations after DocType changes
- **frappe-bench-validator** - Validates bench setup
- **frappe-test-file-validator** 🆕 - Validates test file locations
- **frappe-test-reminder** 🆕 - Reminds to run tests after code changes
- **frappe-cache-clear-reminder** 🆕 - Suggests cache clear after JS changes
- **frappe-site-check** 🆕 - Verifies site exists for operations

## Installation

### Quick Install from GitHub

```bash
# 1. Add the marketplace
/plugin marketplace add vyogotech/frappe-apps-manager

# 2. Install the plugin
/plugin install frappe-apps-manager@vyogotech

# 3. Restart Claude Code

# 4. Verify installation
/help  # Should show all 15 Frappe commands

# 5. Try it out!
/frappe-new-site
```

### Alternative Installation Methods

**Full GitHub URL:**
```bash
/plugin marketplace add https://github.com/vyogotech/frappe-apps-manager
/plugin install frappe-apps-manager@vyogotech
```

**Local Development:**
```bash
git clone https://github.com/vyogotech/frappe-apps-manager.git
/plugin marketplace add ./frappe-apps-manager
/plugin install frappe-apps-manager@frappe-apps-manager
```

**Team Auto-Install:**

Add to your project's `.claude/settings.json`:
```json
{
  "pluginMarketplaces": [{
    "name": "frappe-marketplace",
    "source": "vyogotech/frappe-apps-manager"
  }],
  "plugins": [{
    "name": "frappe-apps-manager",
    "marketplace": "frappe-marketplace",
    "enabled": true
  }]
}
```

Team members who trust the repository will get the plugin automatically!

### Prerequisites

- Claude Code installed
- Frappe Framework knowledge (basic to intermediate)
- A Frappe bench for testing (recommended)

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

## Testing Skills

See [TESTING_SKILLS.md](TESTING_SKILLS.md) for comprehensive testing guide.

### Quick Test

**Claude Code:**
```bash
/help  # Verify commands appear
"Create a Customer DocType with name and email"  # Test skill auto-invocation
```

**Cursor IDE:**
```
/  # List all skills
/frappe-doctype-builder  # Invoke skill manually
```

**Gemini CLI:**
```bash
gemini
/skills list  # List all skills
/skills enable frappe-doctype-builder  # Enable skill
"Create a Customer DocType"  # Use skill
```

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

### Skills Not Working

- **Claude Code**: Verify plugin is installed and skills directory exists
- **Cursor IDE**: Check skill files exist in `.cursor/skills/` (re-sync with `./sync-skills.sh`)
- **Gemini CLI**: Enable experimental skills in `/settings`, verify files in `.gemini/skills/`

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
