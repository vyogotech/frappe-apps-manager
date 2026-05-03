---
name: frappe-app-installation-validator
description: Validate Frappe app installability and migration using SNE images in a containerized environment.
---

# Frappe App Installation Validator (SNE)

This skill focuses on ensuring that a Frappe app can be cleanly installed and migrated in a production-like environment using SNE (Site Network Emulator) images. This is a critical DevOps gate for CI/CD.

## When to Use

- Before merging a Pull Request (CI gate).
- Before a release or deployment.
- After adding new DocTypes, Modules, or complex migrations.
- When verifying compatibility with a new Frappe/ERPNext version.

## Core Workflow (SNE/Container)

The validation happens inside an SNE container (e.g., `docker.io/vyogo/erpnext:sne-version-16`) where a full bench is already provisioned.

### 1. Provision & Install
```bash
# 1. Fetch the app
bench get-app https://github.com/org/your-app --branch develop

# 2. Install to the target site
bench --site [site-name] install-app your_app

# 3. Run migration
bench --site [site-name] migrate
```

### 2. Verification Gates

| Check | Command | Success Criteria |
|---|---|---|
| **App Installed** | `bench --site [site] list-apps` | `your_app` exists in the list. |
| **Schema Ready** | `bench --site [site] console --command "frappe.db.exists('DocType', 'YourNewDocType')"` | Returns `True`. |
| **Hooks Loaded** | `bench --site [site] console --command "frappe.get_hooks('app_name')"` | Returns dictionary of hooks. |
| **Migration Clean** | Check stdout/stderr | No `Traceback` or `OperationalError`. |

## Automated Installation Script (Pattern)

```bash
#!/bin/bash
set -e

APP_NAME="your_app"
SITE="test.local"

echo "Starting Installation Validation for $APP_NAME..."

# Step 1: Install
if bench --site $SITE install-app $APP_NAME; then
    echo "✅ App Installed Successfully"
else
    echo "❌ App Installation Failed"
    exit 1
fi

# Step 2: Migrate
if bench --site $SITE migrate; then
    echo "✅ Migration Completed Successfully"
else
    echo "❌ Migration Failed"
    exit 1
fi

# Step 3: Verification
INSTALLED=$(bench --site $SITE list-apps | grep $APP_NAME)
if [ ! -z "$INSTALLED" ]; then
    echo "✅ Verification Passed: App is active in site metadata"
else
    echo "❌ Verification Failed: App not found in site list"
    exit 1
fi
```

## Anti-Patterns to Avoid

- **Testing on Dirty Sites**: Always run installation tests on a fresh site or a site with a known clean state.
- **Skipping Migration**: Installing an app without running `bench migrate` skips DocType schema creation.
- **Ignoring Warnings**: "Deprecation Warnings" during installation often become "Hard Failures" in the next version.
- **Manual Verification**: Relying on the Desk UI to see if an app is installed. Use CLI/API for CI/CD reproducibility.

## DevOps Orchestration

Integrate this into GitHub Actions or GitLab CI:
```yaml
steps:
  - name: Install and Validate App
    run: |
      bench get-app --resolve-deps ${{ github.workspace }}
      bench --site test.local install-app ${{ env.APP_NAME }}
      bench --site test.local migrate
```
