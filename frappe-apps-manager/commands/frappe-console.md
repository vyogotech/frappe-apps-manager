---
description: Launch interactive Frappe Python console for debugging and data queries
---

# Frappe Console Command

Launch an interactive Python console with Frappe context loaded for debugging, data exploration, and executing Python commands.

## Steps to Execute

### 1. Verify Bench Environment
- Check if current directory is a valid Frappe bench
- Verify bench command is available
- List available sites

### 2. Select Site
Ask user which site to use:
- List all sites in `sites/` directory
- Show default site (if set with `bench use`)
- Get user selection or use default

### 3. Console Type Selection
Offer console options:

**A. Standard Console (IPython)**
- Full Python REPL with Frappe context
- Auto-completion and syntax highlighting
- Command history

**B. One-liner Execution**
- Execute single Python command
- Get result and exit
- Useful for scripts and automation

**C. Script Execution**
- Execute Python script file
- Run with Frappe context
- Show output

### 4. Launch Console

**Standard Console:**
```bash
bench --site [site-name] console
```

**One-liner:**
```bash
bench --site [site-name] console --execute "print(frappe.db.get_all('Customer', limit=5))"
```

**Script File:**
```bash
bench --site [site-name] console < script.py
```

### 5. Provide Console Snippets

Show common console commands for user reference:

**Get Document:**
```python
# Fetch a document
doc = frappe.get_doc('Customer', 'CUST-001')
print(doc.as_dict())
```

**Query Database:**
```python
# Get all records with filters
customers = frappe.get_all('Customer',
    filters={'customer_group': 'Commercial'},
    fields=['name', 'customer_name'],
    limit=10
)
print(customers)
```

**Execute Queries:**
```python
# Raw SQL
result = frappe.db.sql("""
    SELECT name, customer_name
    FROM `tabCustomer`
    WHERE creation > '2025-01-01'
    LIMIT 10
""", as_dict=True)
```

**Create Documents:**
```python
# Create new document
customer = frappe.get_doc({
    'doctype': 'Customer',
    'customer_name': 'Test Customer',
    'customer_group': 'Commercial'
})
customer.insert()
frappe.db.commit()
```

**Update Documents:**
```python
# Update existing document
doc = frappe.get_doc('Customer', 'CUST-001')
doc.customer_name = 'Updated Name'
doc.save()
frappe.db.commit()
```

**Delete Documents:**
```python
# Delete document
frappe.delete_doc('Customer', 'CUST-001')
frappe.db.commit()
```

**Test Permissions:**
```python
# Check permissions
frappe.has_permission('Customer', 'write', 'CUST-001')

# Set user context
frappe.set_user('user@example.com')
```

**Clear Cache:**
```python
# Clear specific doctype cache
frappe.clear_cache(doctype='Customer')

# Clear all cache
frappe.clear_cache()
```

**Reload DocType:**
```python
# Reload DocType after JSON changes
frappe.reload_doctype('Customer')
```

### 6. Console Session Management

Provide guidance for session:

**Important Commands:**
- `exit()` or `Ctrl+D` - Exit console
- `Ctrl+C` - Interrupt current command
- `help(frappe)` - Get help on frappe module
- `dir(doc)` - List object attributes

**Transaction Management:**
```python
# Always commit changes
frappe.db.commit()

# Rollback if needed
frappe.db.rollback()
```

### 7. Debugging Support

**Inspect Objects:**
```python
# Get all fields
doc = frappe.get_doc('Customer', 'CUST-001')
print(doc.as_dict())

# Get specific field
print(doc.customer_name)

# Check meta
print(doc.meta.fields)
```

**Trace Errors:**
```python
# Get last error
frappe.get_traceback()

# Log error
frappe.log_error('Custom error message')
```

**Profile Code:**
```python
import time
start = time.time()
# ... your code ...
print(f"Execution time: {time.time() - start}s")
```

### 8. Data Exploration

**Count Records:**
```python
# Count all
frappe.db.count('Customer')

# Count with filters
frappe.db.count('Customer', {'customer_group': 'Commercial'})
```

**Get Distinct Values:**
```python
# Get all customer groups
frappe.db.sql_list("SELECT DISTINCT customer_group FROM `tabCustomer`")
```

**Check Schema:**
```python
# Get DocType meta
meta = frappe.get_meta('Customer')
for field in meta.fields:
    print(f"{field.fieldname}: {field.fieldtype}")
```

### 9. Bulk Operations

**Bulk Update:**
```python
# Update multiple records
customers = frappe.get_all('Customer',
    filters={'customer_group': 'Old Group'},
    pluck='name'
)

for name in customers:
    doc = frappe.get_doc('Customer', name)
    doc.customer_group = 'New Group'
    doc.save()

frappe.db.commit()
```

**Bulk Delete:**
```python
# Delete with filters
frappe.db.delete('Customer', {
    'creation': ['<', '2020-01-01']
})
frappe.db.commit()
```

### 10. Advanced Operations

**Test API Methods:**
```python
# Call whitelisted method
result = frappe.call('my_app.api.get_customer_details',
    customer='CUST-001'
)
print(result)
```

**Run Scheduled Jobs:**
```python
# Execute scheduler method
frappe.enqueue('my_app.tasks.daily_cleanup')
```

**Inspect Queue:**
```python
# Check background jobs
from rq import Queue
from frappe.utils.background_jobs import get_redis_conn

q = Queue('default', connection=get_redis_conn())
print(f"Jobs in queue: {len(q)}")
```

## References

### Frappe Core Console Examples (Primary Reference)

**Frappe Console Utilities:**
- Frappe DB API: https://github.com/frappe/frappe/blob/develop/frappe/database.py
- Document API: https://github.com/frappe/frappe/blob/develop/frappe/model/document.py
- Utils Module: https://github.com/frappe/frappe/blob/develop/frappe/utils/__init__.py

**Real Console Patterns from Core:**

1. **Data Migration** (common console use):
```python
# Migrate data between fields
for doc in frappe.get_all('Item', pluck='name'):
    item = frappe.get_doc('Item', doc)
    item.new_field = item.old_field
    item.save()
frappe.db.commit()
```

2. **Fix Data Issues** (from support scenarios):
```python
# Fix incorrect values
frappe.db.set_value('Customer', 'CUST-001',
    'customer_group', 'Correct Group')
frappe.db.commit()
```

3. **Generate Reports** (quick analysis):
```python
# Get summary data
result = frappe.db.sql("""
    SELECT customer_group, COUNT(*) as count
    FROM `tabCustomer`
    GROUP BY customer_group
""", as_dict=True)
print(result)
```

### Official Documentation (Secondary Reference)

- Bench Console: https://frappeframework.com/docs/user/en/bench/reference/bench-cli#console
- Frappe API: https://frappeframework.com/docs/user/en/api
- Database API: https://frappeframework.com/docs/user/en/api/database

## Safety Guidelines

### Important Warnings

**Production Safety:**
- ⚠️ ALWAYS use test/development sites for experiments
- ⚠️ NEVER run untested commands on production
- ⚠️ ALWAYS backup before bulk operations
- ⚠️ ALWAYS commit or rollback explicitly

**Transaction Safety:**
```python
try:
    # Your operations
    doc.save()
    frappe.db.commit()  # Commit on success
except Exception as e:
    frappe.db.rollback()  # Rollback on error
    print(f"Error: {e}")
```

**Permission Context:**
```python
# Bypass permissions for admin tasks
doc.insert(ignore_permissions=True)
doc.save(ignore_permissions=True)

# Be careful with this - only use when necessary
```

## Common Console Use Cases

### 1. Data Migration
```python
# Migrate from old to new structure
for name in frappe.get_all('Old DocType', pluck='name'):
    old = frappe.get_doc('Old DocType', name)
    new = frappe.get_doc({
        'doctype': 'New DocType',
        'field1': old.old_field1,
        'field2': old.old_field2
    })
    new.insert()
frappe.db.commit()
```

### 2. Fix Data Issues
```python
# Fix duplicate entries
duplicates = frappe.db.sql("""
    SELECT email, COUNT(*)
    FROM `tabCustomer`
    GROUP BY email
    HAVING COUNT(*) > 1
""", as_dict=True)

for dup in duplicates:
    print(f"Duplicate email: {dup.email}")
```

### 3. Generate Reports
```python
# Sales summary
result = frappe.db.sql("""
    SELECT
        MONTH(posting_date) as month,
        SUM(grand_total) as total
    FROM `tabSales Invoice`
    WHERE YEAR(posting_date) = 2025
    GROUP BY MONTH(posting_date)
""", as_dict=True)
print(result)
```

### 4. User Management
```python
# Create user
user = frappe.get_doc({
    'doctype': 'User',
    'email': 'newuser@example.com',
    'first_name': 'New',
    'last_name': 'User',
    'send_welcome_email': 0
})
user.insert()
user.add_roles('Sales User', 'Purchase User')
frappe.db.commit()
```

### 5. Configuration Changes
```python
# Update system settings
settings = frappe.get_single('System Settings')
settings.disable_signup = 1
settings.save()
frappe.db.commit()
```

## Important Notes

- Console runs with Administrator privileges by default
- All database changes require explicit `frappe.db.commit()`
- Use `frappe.db.rollback()` if something goes wrong
- Console maintains state until exit
- Great for one-off data fixes and exploration
- Not suitable for production automation (use scheduled jobs)
- Always test commands before running on production data
