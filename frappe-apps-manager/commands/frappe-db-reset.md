---
description: Reset Frappe database - reinstall with fresh data and fixtures for development
---

# Frappe DB Reset Command

Reset and reinitialize Frappe database for development purposes with automatic backup and fresh data setup.

## Steps to Execute

### 1. Verify Environment
- Check if in valid Frappe bench
- Verify site exists
- **WARNING:** Confirm this is NOT a production site
- Check for existing backups

### 2. Safety Checks

**CRITICAL WARNINGS:**
- ⚠️ This operation DESTROYS ALL DATA
- ⚠️ ONLY use on development/test sites
- ⚠️ NEVER run on production sites
- ⚠️ Always create backup first

Ask user to confirm:
1. Is this a development/test site?
2. Do they want to backup first?
3. Do they understand all data will be lost?

Require explicit confirmation: "Type 'RESET' to confirm"

### 3. Pre-Reset Backup

**Create Safety Backup:**
```bash
bench --site [site-name] backup --with-files
```

Store backup location for user:
```
Backup created at:
- Database: sites/[site-name]/private/backups/[timestamp]-database.sql.gz
- Files: sites/[site-name]/private/backups/[timestamp]-files.tar
```

### 4. Reset Options

Offer reset approaches:

**A. Full Reinstall (Recommended)**
- Drops and recreates database
- Reinstalls all apps
- Clean slate

**B. Data Reset Only**
- Keeps app installations
- Removes user data
- Faster than full reinstall

**C. Selective Reset**
- Reset specific DocTypes
- Keep master data
- Remove transactions only

### 5. Execute Full Reinstall

**Full Site Reinstall:**
```bash
# Reinstall site (drops DB and recreates)
bench --site [site-name] reinstall

# Or with options
bench --site [site-name] reinstall \
    --admin-password [password] \
    --mariadb-root-password [root-password] \
    --install-app erpnext \
    --verbose
```

This will:
1. Drop existing database
2. Create new database
3. Install frappe app
4. Install additional apps (if specified)
5. Create Administrator user
6. Set up default roles and permissions

### 6. Execute Data-Only Reset

**Remove User Data:**
```python
# Via console
bench --site [site-name] console

# Get all DocTypes
exclude_core = ['User', 'Role', 'DocType', 'Module Def']

for doctype in frappe.get_all('DocType', pluck='name'):
    if doctype not in exclude_core:
        frappe.db.delete(doctype)

frappe.db.commit()
```

### 7. Install Fixtures

After reset, offer to install fixtures:

**A. Core Fixtures:**
```bash
bench --site [site-name] install-app [app-name]
```

**B. Custom Fixtures:**
```bash
# Import fixtures from app
bench --site [site-name] console
>>> from frappe.core.page.data_import_tool import data_import_tool
>>> data_import_tool.import_doc('path/to/fixtures.json')
```

**C. Demo Data:**
```bash
# Install with demo data
bench --site [site-name] reinstall --install-app erpnext --with-demo-data
```

### 8. Post-Reset Setup

**A. Create Test Users:**
```python
# Via console
users = [
    {'email': 'sales@test.com', 'first_name': 'Sales', 'roles': ['Sales User']},
    {'email': 'stock@test.com', 'first_name': 'Stock', 'roles': ['Stock User']}
]

for user_data in users:
    if not frappe.db.exists('User', user_data['email']):
        user = frappe.get_doc({
            'doctype': 'User',
            'email': user_data['email'],
            'first_name': user_data['first_name'],
            'send_welcome_email': 0
        })
        user.insert(ignore_permissions=True)
        user.add_roles(*user_data['roles'])

frappe.db.commit()
```

**B. Configure Site Settings:**
```bash
bench --site [site-name] set-config developer_mode 1
bench --site [site-name] set-config allow_tests 1
```

**C. Run Migrations:**
```bash
bench --site [site-name] migrate
```

**D. Clear Cache:**
```bash
bench --site [site-name] clear-cache
```

### 9. Verify Reset

Check that reset was successful:

**Database Check:**
```python
# Count records
frappe.db.count('Customer')  # Should be 0 or fixture count
frappe.db.count('User')      # Should have Administrator + test users
```

**App Installation:**
```bash
bench --site [site-name] list-apps
```

**Site Access:**
```bash
bench --site [site-name] browse
# Or manually visit: http://localhost:8000
```

**Login Test:**
- Username: Administrator
- Password: [admin-password from reinstall]

### 10. Restore from Backup (If Needed)

If reset went wrong, restore from backup:

**Restore Database:**
```bash
bench --site [site-name] --force restore \
    sites/[site-name]/private/backups/[backup-file].sql.gz
```

**Restore Files:**
```bash
cd sites/[site-name]
tar -xzf private/backups/[backup-file]-files.tar
```

**Full Restore:**
```bash
bench --site [site-name] restore \
    --with-public-files sites/[site-name]/private/backups/[timestamp]-database.sql.gz \
    --with-private-files sites/[site-name]/private/backups/[timestamp]-files.tar
```

## References

### Frappe Core Reset/Install Patterns (Primary Reference)

**Frappe Install Module:**
- Install Functions: https://github.com/frappe/frappe/blob/develop/frappe/installer.py
- Site Installer: https://github.com/frappe/frappe/blob/develop/frappe/install_lib.py
- Database Setup: https://github.com/frappe/frappe/blob/develop/frappe/database.py

**Bench Install Commands:**
- Bench Reinstall: https://github.com/frappe/bench/blob/develop/bench/commands/site.py
- New Site Logic: https://github.com/frappe/bench/blob/develop/bench/commands/make.py

**Real Reset Patterns:**

1. **Fixture Installation** (from ERPNext setup):
```python
# See: erpnext/setup/install.py
def install_fixtures():
    from frappe.core.doctype.data_import.data_import import import_doc

    for fixture in ['country', 'currency', 'mode_of_payment']:
        import_doc(f'erpnext/setup/fixtures/{fixture}.json')

    frappe.db.commit()
```

2. **Post-Install Configuration** (from Frappe installer):
```python
# See: frappe/installer.py
def after_install():
    add_standard_roles()
    install_basic_docs()
    setup_wizard_complete()
    frappe.db.commit()
```

### Official Documentation (Secondary Reference)

- Reinstall Command: https://frappeframework.com/docs/user/en/bench/reference/bench-cli#reinstall
- Backup/Restore: https://frappeframework.com/docs/user/en/bench/reference/bench-cli#backup
- Site Commands: https://frappeframework.com/docs/user/en/bench/reference/sites

## Advanced Reset Scenarios

### Selective DocType Reset

**Reset Specific DocTypes:**
```python
# Via console
doctypes_to_reset = ['Sales Invoice', 'Purchase Order', 'Stock Entry']

for doctype in doctypes_to_reset:
    # Delete all records
    frappe.db.delete(doctype)

    # Reset naming series
    frappe.db.sql(f"""
        UPDATE `tabSeries`
        SET current = 0
        WHERE name LIKE '{doctype[:4]}%'
    """)

frappe.db.commit()
print("Reset complete")
```

### Keep Master Data

**Reset Transactions, Keep Masters:**
```python
# Define master DocTypes to keep
master_doctypes = ['Customer', 'Item', 'Supplier', 'Company']

# Get all DocTypes
all_doctypes = frappe.get_all('DocType',
    filters={'istable': 0, 'issingle': 0},
    pluck='name'
)

# Reset transaction DocTypes
for doctype in all_doctypes:
    if doctype not in master_doctypes:
        count = frappe.db.count(doctype)
        if count > 0:
            frappe.db.delete(doctype)
            print(f"Deleted {count} {doctype} records")

frappe.db.commit()
```

### Database Cleanup

**Clean Orphaned Records:**
```python
# Find and remove orphaned child table records
# Run after selective reset

frappe.db.sql("""
    DELETE FROM `tabSales Invoice Item`
    WHERE parent NOT IN (SELECT name FROM `tabSales Invoice`)
""")

frappe.db.commit()
```

## Important Notes

- ⚠️ NEVER run on production without understanding consequences
- ⚠️ ALWAYS backup before reset
- Reinstall preserves site_config.json
- Reinstall preserves file uploads (can be cleared separately)
- Administrator password reset to new password
- All users except Administrator removed (can be preserved if needed)
- Custom apps need reinstallation
- Migrations run automatically on reinstall
- Reset clears all reports, dashboards, customizations
- Testing: Use dedicated test sites for resets

## Safety Checklist

Before executing reset, verify:
- [ ] This is a development/test site (NOT production)
- [ ] Backup created and verified
- [ ] Admin password documented
- [ ] Apps list documented (for reinstall)
- [ ] Important data exported (if any)
- [ ] Team notified (if shared site)
- [ ] Bench and Redis running
- [ ] Sufficient disk space for reinstall

## Post-Reset Checklist

After reset, verify:
- [ ] Can login as Administrator
- [ ] All apps installed correctly
- [ ] Site config intact
- [ ] Redis working
- [ ] Email configured (if needed)
- [ ] Test users created
- [ ] Permissions configured
- [ ] Fixtures installed
- [ ] Customizations reapplied

## Alternative: Clone Instead of Reset

**For testing, consider cloning:**
```bash
# Create copy of site for testing
bench --site original.local backup
bench restore new-test.local \
    --source sites/original.local/private/backups/[backup].sql.gz

# Now reset the clone, not original
bench --site new-test.local reinstall
```

This preserves original site while providing clean environment.
