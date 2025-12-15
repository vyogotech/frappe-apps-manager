---
description: Configure Frappe site settings - manage site_config.json and environment variables
---

# Frappe Config Command

Manage Frappe site configuration including site_config.json settings, environment variables, and feature flags.

## Steps to Execute

### 1. Verify Environment
- Check if in valid Frappe bench
- Verify site exists
- Check site_config.json file exists

### 2. Configuration Operation Selection

Ask user what they want to configure:

**A. View Current Config**
- Display site_config.json
- Show environment variables
- List feature flags

**B. Database Settings**
- Configure MariaDB/PostgreSQL
- Set connection parameters
- Configure read replicas

**C. Redis Settings**
- Configure cache Redis
- Configure queue Redis
- Configure socketio Redis

**D. Email Settings**
- SMTP configuration
- Email accounts
- Outgoing email settings

**E. Developer Settings**
- Developer mode
- Debug mode
- Logging levels

**F. Feature Flags**
- Enable/disable features
- Experimental features
- Module toggles

### 3. View Configuration

**Display site_config.json:**
```bash
cat sites/[site-name]/site_config.json | jq .
```

**Get Specific Config:**
```bash
bench --site [site-name] console
>>> frappe.conf.get('db_name')
>>> frappe.conf.get('developer_mode')
```

**List All Configs:**
```python
import json
print(json.dumps(frappe.conf, indent=2))
```

### 4. Set Configuration Values

**Set Single Value:**
```bash
bench --site [site-name] set-config [key] [value]
```

Examples:
```bash
# Enable developer mode
bench --site [site-name] set-config developer_mode 1

# Set session timeout
bench --site [site-name] set-config session_timeout 3600

# Set file size limit
bench --site [site-name] set-config max_file_size 10485760
```

**Set Multiple Values:**
```python
# Via console
config_updates = {
    'developer_mode': 1,
    'allow_tests': 1,
    'log_queries': 1
}

for key, value in config_updates.items():
    frappe.db.set_value('Website Settings', None, key, value)

frappe.db.commit()
```

### 5. Database Configuration

**Database Settings:**
```json
{
  "db_name": "site_db",
  "db_host": "localhost",
  "db_port": 3306,
  "db_type": "mariadb",
  "db_socket": "/var/run/mysqld/mysqld.sock"
}
```

**Read Replica:**
```json
{
  "read_from_replica": 1,
  "replica_host": "replica.example.com",
  "replica_port": 3306
}
```

### 6. Redis Configuration

**Redis Connection Settings:**
```json
{
  "redis_cache": "redis://localhost:13000",
  "redis_queue": "redis://localhost:11000",
  "redis_socketio": "redis://localhost:12000"
}
```

**Redis with Password:**
```json
{
  "redis_cache": "redis://:password@localhost:13000",
  "redis_queue": "redis://:password@localhost:11000"
}
```

### 7. Email Configuration

**SMTP Settings:**
```bash
bench --site [site-name] set-config mail_server "smtp.gmail.com"
bench --site [site-name] set-config mail_port 587
bench --site [site-name] set-config use_tls 1
bench --site [site-name] set-config mail_login "your-email@gmail.com"
bench --site [site-name] set-config mail_password "app-password"
```

**Email Configuration:**
```json
{
  "mail_server": "smtp.gmail.com",
  "mail_port": 587,
  "use_tls": 1,
  "mail_login": "notifications@company.com",
  "mail_password": "app-password",
  "auto_email_id": "notifications@company.com",
  "email_sender_name": "Company Notifications"
}
```

### 8. Developer Settings

**Enable Developer Mode:**
```bash
bench --site [site-name] set-config developer_mode 1
bench --site [site-name] clear-cache
```

**Developer Mode Features:**
- Edit DocTypes via desk
- Show debug toolbar
- Detailed error messages
- JavaScript/CSS hot reload
- Query logging

**Debug Settings:**
```json
{
  "developer_mode": 1,
  "allow_tests": 1,
  "log_queries": 1,
  "logging": 2,
  "auto_reload": 1
}
```

### 9. Performance Settings

**Performance Configuration:**
```json
{
  "limits": {
    "page_length": 20,
    "posts_per_page": 10
  },
  "background_workers": 4,
  "max_file_size": 10485760,
  "enable_prepared_report": 1,
  "global_search_doctypes": ["Customer", "Item", "Sales Invoice"]
}
```

**Caching Settings:**
```json
{
  "cache_ttl": 3600,
  "enable_rate_limit": 1,
  "rate_limit": {
    "limit": 100,
    "window": 3600
  }
}
```

### 10. Security Settings

**Security Configuration:**
```json
{
  "disable_signup": 1,
  "deny_multiple_sessions": 0,
  "session_timeout": 14400,
  "session_expiry_mobile": 604800,
  "password_reset_limit": 3,
  "allow_cors": "*",
  "ignore_csrf": 0
}
```

**SSL/HTTPS Settings:**
```json
{
  "force_https": 1,
  "host_name": "https://mysite.com",
  "redirect_to_https": 1
}
```

## References

### Frappe Core Config Examples (Primary Reference)

**Frappe Configuration Module:**
- Config Loader: https://github.com/frappe/frappe/blob/develop/frappe/utils/data.py
- Site Config: https://github.com/frappe/frappe/blob/develop/frappe/installer.py
- Default Config: https://github.com/frappe/frappe/blob/develop/frappe/utils/install.py

**Common Site Config from Bench:**
- Bench Config: https://github.com/frappe/bench/blob/develop/bench/config/site_config.py
- Production Config: https://github.com/frappe/bench/blob/develop/bench/config/production_setup.py

**Real Config Patterns:**

1. **Multi-Site Config** (common_site_config.json):
```json
{
  "db_host": "localhost",
  "db_port": 3306,
  "redis_cache": "redis://localhost:13000",
  "redis_queue": "redis://localhost:11000",
  "redis_socketio": "redis://localhost:12000",
  "webserver_port": 8000,
  "socketio_port": 9000,
  "background_workers": 1,
  "gunicorn_workers": 4
}
```

2. **Development Site Config**:
```json
{
  "db_name": "dev_site",
  "db_password": "password",
  "developer_mode": 1,
  "allow_tests": 1,
  "logging": 2,
  "log_queries": 1,
  "auto_reload": 1,
  "disable_website_cache": 1
}
```

3. **Production Site Config**:
```json
{
  "db_name": "prod_site",
  "db_password": "strong_password",
  "developer_mode": 0,
  "logging": 1,
  "host_name": "https://example.com",
  "force_https": 1,
  "deny_multiple_sessions": 1,
  "session_timeout": 14400,
  "enable_rate_limit": 1
}
```

### Official Documentation (Secondary Reference)

- Site Configuration: https://frappeframework.com/docs/user/en/basics/site_config
- Bench Config: https://frappeframework.com/docs/user/en/bench/reference/config
- Common Site Config: https://frappeframework.com/docs/user/en/bench/reference/common-site-config

## Common Configuration Scenarios

### Development Environment
```bash
bench --site dev.local set-config developer_mode 1
bench --site dev.local set-config allow_tests 1
bench --site dev.local set-config log_queries 1
bench --site dev.local set-config auto_reload 1
bench --site dev.local clear-cache
```

### Production Environment
```bash
bench --site prod.example.com set-config developer_mode 0
bench --site prod.example.com set-config logging 1
bench --site prod.example.com set-config deny_multiple_sessions 1
bench --site prod.example.com set-config session_timeout 14400
bench --site prod.example.com set-config enable_rate_limit 1
```

### Email Setup (Gmail)
```bash
bench --site [site-name] set-config mail_server "smtp.gmail.com"
bench --site [site-name] set-config mail_port 587
bench --site [site-name] set-config use_tls 1
bench --site [site-name] set-config mail_login "your-email@gmail.com"
bench --site [site-name] set-config mail_password "app-specific-password"
```

### Custom Domain
```bash
bench --site [site-name] set-config host_name "https://example.com"
bench --site [site-name] set-config force_https 1
```

## Configuration Reference

### Essential Settings

| Setting | Description | Default | Environment |
|---------|-------------|---------|-------------|
| `developer_mode` | Enable development features | 0 | Dev only |
| `db_name` | Database name | site name | All |
| `db_password` | Database password | - | All |
| `redis_cache` | Redis cache URL | localhost:13000 | All |
| `redis_queue` | Redis queue URL | localhost:11000 | All |
| `mail_server` | SMTP server | - | All |
| `session_timeout` | Session expiry (sec) | 3600 | All |
| `deny_multiple_sessions` | Single session per user | 0 | Production |
| `logging` | Log level (1-3) | 1 | All |
| `enable_rate_limit` | API rate limiting | 0 | Production |

### Developer Mode Features

When `developer_mode: 1`:
- Edit DocTypes from desk
- Automatic file reload
- Detailed error pages
- Query logging
- Debug toolbar
- Skip migrations prompt
- Allow test execution

### Security Settings

**Production Security Checklist:**
```json
{
  "developer_mode": 0,
  "disable_signup": 1,
  "deny_multiple_sessions": 1,
  "session_timeout": 14400,
  "password_reset_limit": 3,
  "ignore_csrf": 0,
  "force_https": 1,
  "enable_rate_limit": 1,
  "cors_headers": ["https://allowed-domain.com"]
}
```

## Important Notes

- Changes require bench restart for some settings
- Clear cache after config changes
- Site config overrides common config
- Environment variables can override config
- Sensitive values (passwords) stored in config
- Use environment variables for secrets in production
- Back up config before major changes
- Test config changes in dev first
- Document custom config settings
- Use `.gitignore` for site_config.json (contains secrets)

## Troubleshooting

**Config Not Taking Effect:**
```bash
# Restart bench
bench restart

# Clear cache
bench --site [site-name] clear-cache

# Check if config was set
cat sites/[site-name]/site_config.json | jq .[key]
```

**Invalid JSON:**
```bash
# Validate JSON syntax
cat sites/[site-name]/site_config.json | jq .
```

**Permission Denied:**
```bash
# Check file ownership
ls -la sites/[site-name]/site_config.json

# Fix if needed
sudo chown frappe:frappe sites/[site-name]/site_config.json
```
