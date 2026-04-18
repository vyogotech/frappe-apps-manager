---
name: frappe-tenant-query
description: Generate tenant-isolated database queries using TenantAwareDB to prevent cross-tenant access.
---

# Generate Tenant-Aware Query

Create database queries with automatic tenant isolation using `app.tenant_db`.

## When to Use

- Querying documents in microservice
- Need automatic tenant filtering
- Preventing cross-tenant data access

## How TenantAwareDB Works

`TenantAwareDB` wraps Frappe ORM and auto-injects `tenant_id` into all queries. When used inside `@app.secure_route`, `g.tenant_id` is already set by the auth middleware -- no manual `app.set_tenant_id()` needed.

## Complete API Reference

### Read Operations

```python
# List documents (auto-filtered by tenant_id)
docs = app.tenant_db.get_all('Sales Order',
    filters={'status': 'Draft'},
    fields=['name', 'customer', 'grand_total'],
    limit_page_length=20,
    limit_start=0,
    order_by='modified desc'
)

# Alias for get_all
docs = app.tenant_db.get_list('Sales Order', filters={'status': 'Draft'})

# Get single document (verifies tenant ownership)
doc = app.tenant_db.get_doc('Sales Order', 'SO-00001')

# Get single field value
status = app.tenant_db.get_value('Sales Order', 'SO-00001', 'status')
status = app.tenant_db.get_value('Sales Order', {'customer': 'CUST-001'}, 'status')

# Count documents
count = app.tenant_db.count('Sales Order', filters={'status': 'Draft'})

# Check existence
exists = app.tenant_db.exists('Sales Order', {'name': 'SO-00001'})
```

### Write Operations

```python
# Create new document (doesn't insert yet)
doc = app.tenant_db.new_doc('Sales Order', customer='CUST-001', status='Draft')
doc.items = [...]
doc.insert()

# Create and insert in one call (runs hooks: before_validate → before_insert → INSERT → after_insert)
doc = app.tenant_db.insert_doc('Sales Order', {
    'customer': 'CUST-001',
    'items': [{'item_code': 'ITEM-001', 'qty': 5}]
})

# Insert with Frappe params
doc = app.tenant_db.insert_doc('Sales Order', data,
    ignore_permissions=True,     # Use sparingly: signup, migrations, system tasks
    ignore_mandatory=True,
)

# Update document (runs hooks: before_update → before_validate → save → after_update)
doc = app.tenant_db.update_doc('Sales Order', 'SO-001', {
    'status': 'Confirmed',
    'delivery_date': '2025-01-15'
})

# Update single field (verifies tenant ownership first)
app.tenant_db.set_value('Sales Order', 'SO-001', 'status', 'Confirmed')

# Delete document (runs hooks: before_delete → delete → after_delete)
app.tenant_db.delete_doc('Sales Order', 'SO-001')
```

### Transaction Management

```python
# Commit / Rollback (usually NOT needed -- middleware auto-commits)
app.tenant_db.commit()
app.tenant_db.rollback()
```

### Raw SQL (Parameterized Only)

```python
tenant_id = app.tenant_db.get_tenant_id()

result = app.tenant_db.sql("""
    SELECT name, customer, grand_total
    FROM `tabSales Order`
    WHERE tenant_id = %s AND status = %s
    ORDER BY modified DESC
    LIMIT %s
""", (tenant_id, 'Draft', 10), as_dict=True)
```

`tenant_db.sql()` validates that a tenant_id exists in context before executing. You must still manually include `tenant_id` in the WHERE clause for raw SQL.

## Document Lifecycle Hooks

TenantAwareDB runs registered hooks automatically during CRUD operations:

**insert_doc hook order:**
1. `before_validate` (custom)
2. `before_insert` (custom)
3. DB INSERT (Frappe validate/before_save/after_save run here)
4. `after_insert` (custom)

**update_doc hook order:**
1. `before_update` (custom)
2. Update fields on doc
3. `before_validate` (custom)
4. `doc.save()` (Frappe validate/before_save/on_update/after_save run here)
5. `after_update` (custom)

**delete_doc hook order:**
1. `before_delete` (custom)
2. `doc.delete()` (Frappe on_trash runs here)
3. `after_delete` (custom)

## Hook Registration

```python
# Decorator style
@app.tenant_db.on('Sales Order', 'before_insert')
def set_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'

# Convenience decorators
@app.tenant_db.before_validate('Sales Order')
def validate_order(doc):
    if not doc.customer:
        frappe.throw("Customer is required")

@app.tenant_db.after_insert('*')  # Global hook for all DocTypes
def log_creation(doc):
    app.logger.info(f"Created {doc.doctype}: {doc.name}")

# Available convenience decorators:
# app.tenant_db.before_validate(doctype)
# app.tenant_db.before_insert(doctype)
# app.tenant_db.after_insert(doctype)
# app.tenant_db.before_update(doctype)
# app.tenant_db.after_update(doctype)
# app.tenant_db.before_delete(doctype)
# app.tenant_db.after_delete(doctype)

# Debug: list all registered hooks
hooks = app.tenant_db.list_hooks()
# Returns: {'Sales Order': {'before_insert': ['set_defaults']}, ...}
```

## Security Rules

1. Never use `frappe.db` directly -- always use `app.tenant_db`
2. Never use f-strings in SQL -- always use `%s` placeholders
3. `get_doc` auto-verifies tenant ownership (raises PermissionError on mismatch)
4. `insert_doc` verifies tenant_id after insert (catches ALTER TABLE issues)
5. SYSTEM tenant_id is always rejected
6. Filters support None, dict, list, or str (document name)

## Key Patterns

- **List**: `app.tenant_db.get_all('DocType', filters={...})`
- **Get**: `app.tenant_db.get_doc('DocType', name)`
- **Create**: `app.tenant_db.insert_doc('DocType', data)`
- **Update**: `app.tenant_db.update_doc('DocType', name, data)`
- **Delete**: `app.tenant_db.delete_doc('DocType', name)`
- **Count**: `app.tenant_db.count('DocType', filters={...})`
- **Exists**: `app.tenant_db.exists('DocType', filters)`

Remember: This skill is model-invoked. Claude will use it autonomously when detecting tenant-aware query needs.
