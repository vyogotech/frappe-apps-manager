---
description: Create a new Frappe site with database setup and configuration
---

# Frappe New Site Command

Create a new Frappe site with proper database configuration, admin user setup, and initial app installation.

## Steps to Execute

### 1. Verify Bench Environment
- Check if current directory is a valid Frappe bench
- Look for `sites/common_site_config.json` file
- Verify bench command is available
- If not in bench directory, ask user for bench path

### 2. Gather Site Details
Ask the user for the following information:
- **Site name** (e.g., `mysite.local`, `dev.example.com`)
  - Must be a valid domain format
  - Will be used to access the site
- **Database name** (optional, defaults to site name with special chars removed)
- **MariaDB/PostgreSQL root password** (for database creation)
- **Admin password** (for Administrator user)
  - Suggest strong password or offer to generate one
- **Install demo data?** (yes/no)

### 3. Pre-creation Checks
Before creating the site:
- Check if site name already exists in `sites/` directory
- Verify database connectivity (test root password)
- Check disk space (warn if < 1GB free)
- Verify required services are running:
  - MySQL/MariaDB or PostgreSQL
  - Redis (both cache and queue)

### 4. Create the Site
Execute the site creation command with appropriate flags:

```bash
bench new-site [site-name] \
  --admin-password [password] \
  --mariadb-root-password [root-password] \
  [--db-name [custom-db-name]] \
  [--install-app erpnext] \
  [--verbose]
```

Options to consider:
- `--db-name`: Custom database name if specified
- `--db-type postgres`: If using PostgreSQL instead of MariaDB
- `--install-app`: Install specific apps during creation
- `--verbose`: Show detailed output
- `--source_sql`: Import from SQL file (for cloning)

### 5. Verify Site Creation
After creation, verify:
- Site directory exists at `sites/[site-name]/`
- Check for essential files:
  - `sites/[site-name]/site_config.json`
  - `sites/[site-name]/private/backups/`
  - `sites/[site-name]/public/files/`
- Database was created successfully
- Administrator user exists and can login

Test site accessibility:
```bash
bench --site [site-name] console
```

### 6. Install Additional Apps (Optional)
Ask if user wants to install additional apps:
- List available apps in bench with `bench --site [site-name] list-apps`
- Offer to install common apps:
  - ERPNext (if not already installed)
  - Custom apps in `apps/` directory

For each app to install:
```bash
bench --site [site-name] install-app [app-name]
```

### 7. Configure Site Settings
Offer to configure common settings:

**Email Settings:**
- Mail server (SMTP)
- Email account
- Port and encryption

**Site Settings:**
- Enable/disable signup
- Session timeout
- File size limits
- Background job settings

**Developer Mode:**
- Ask if this is a development site
- If yes, enable developer mode:
```bash
bench --site [site-name] set-config developer_mode 1
bench --site [site-name] clear-cache
```

### 8. Set Default Site (Optional)
Ask if this should be the default site:
```bash
bench use [site-name]
```

This allows running bench commands without `--site` flag.

### 9. Post-creation Steps
Provide guidance on next steps:

**Access the Site:**
```bash
bench start
```
Then visit: `http://[site-name]:8000` (or configured port)

Login credentials:
- Username: `Administrator`
- Password: `[admin-password]`

**Common Operations:**
- View site info: `bench --site [site-name] info`
- Backup site: `bench --site [site-name] backup`
- Reset site: `bench --site [site-name] reinstall`
- Delete site: `bench drop-site [site-name]`

**Troubleshooting:**
- If site doesn't load, check Redis: `redis-cli ping`
- Check database connection: `bench --site [site-name] mariadb`
- View site config: `cat sites/[site-name]/site_config.json`
- Check logs: `tail -f logs/web.error.log`

### 10. Site Management Tips
Provide helpful information:

**Multi-tenancy:**
- Multiple sites can run on same bench
- Each site has separate database
- Shared apps and Python environment

**DNS/Hosts Configuration:**
For local development, add to `/etc/hosts`:
```
127.0.0.1   mysite.local
```

**Production Considerations:**
- Use proper domain names
- Set up SSL certificates
- Configure DNS properly
- Use production config (not developer mode)
- Set up regular backups

**Useful Commands:**
- List all sites: `bench --site all list-apps`
- Site console: `bench --site [site-name] console`
- Migrate site: `bench --site [site-name] migrate`
- Clear cache: `bench --site [site-name] clear-cache`
- Set config: `bench --site [site-name] set-config [key] [value]`

## Error Handling

### Common Errors:

**"Could not connect to database"**
- Verify MariaDB/PostgreSQL is running
- Check root password is correct
- Ensure database user has permissions

**"Site already exists"**
- Choose different site name
- Or delete existing site: `bench drop-site [site-name]`

**"Redis connection failed"**
- Start Redis: `sudo systemctl start redis-server`
- Check Redis config in `common_site_config.json`

**"Permission denied"**
- Check directory permissions
- May need to run as frappe user
- Check disk space

## Security Best Practices

- Use strong admin passwords (16+ characters)
- Don't use default passwords in production
- Limit database user permissions
- Enable SSL/HTTPS in production
- Regular backups
- Keep Frappe and apps updated

## Important Notes

- Site creation requires database root password (one-time)
- Admin password is for the Administrator user
- Site name should be a valid domain (use .local for dev)
- Developer mode should only be enabled in development
- Each site is isolated with its own database
- Apps must be installed per-site after creation

## Documentation References

**Official Frappe Documentation:**
- Site Management: https://frappeframework.com/docs/user/en/bench/reference/sites
- Bench CLI: https://frappeframework.com/docs/user/en/bench/reference/bench-cli
- Site Configuration: https://frappeframework.com/docs/user/en/basics/site_config
- Multi-tenancy: https://frappeframework.com/docs/user/en/bench/guides/setup-multitenancy

**Core Frappe Commands:**
- `bench new-site`: Create new site - https://frappeframework.com/docs/user/en/bench/reference/bench-cli#new-site
- `bench use`: Set default site - https://frappeframework.com/docs/user/en/bench/reference/bench-cli#use
- `bench drop-site`: Delete site - https://frappeframework.com/docs/user/en/bench/reference/bench-cli#drop-site

## Frappe Core Apps Reference

When creating a new site, you may want to install these core apps:

**1. frappe (Required)**
- Automatically installed with every site
- Provides core framework functionality
- Repository: https://github.com/frappe/frappe
- Includes: DocTypes, Users, Roles, Permissions, Workflows

**2. erpnext (Optional)**
- Full-featured ERP system
- Install during site creation: `--install-app erpnext`
- Or install later: `bench --site [site-name] install-app erpnext`
- Repository: https://github.com/frappe/erpnext
- Modules: Accounting, Inventory, HR, CRM, Projects, Manufacturing, etc.

**3. hrms (Optional)**
- Human Resource Management System
- Requires ERPNext
- Repository: https://github.com/frappe/hrms
- Install: `bench --site [site-name] install-app hrms`

**4. payments (Optional)**
- Payment gateway integrations
- Repository: https://github.com/frappe/payments
- Install: `bench --site [site-name] install-app payments`

**5. healthcare (Optional)**
- Healthcare management module
- Repository: https://github.com/frappe/healthcare
- Install: `bench --site [site-name] install-app healthcare`

**Checking Available Apps:**
```bash
# List all apps in bench
ls apps/

# List apps installed on specific site
bench --site [site-name] list-apps

# Check app version
bench version
```
