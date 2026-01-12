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

## Core Patterns

### 1. Always Use tenant_db

```python
# ✅ Good - automatic tenant filtering
tenant_id = get_current_tenant_id()
app.set_tenant_id(tenant_id)
data = app.tenant_db.get_all('DocType', filters={...})

# ❌ Bad - no tenant isolation
data = frappe.db.get_all('DocType', filters={...})
```

### 2. Common Queries

```python
# Get all
docs = app.tenant_db.get_all('Sales Order', filters={'status': 'Draft'}, limit=20)

# Get single
doc = app.tenant_db.get_doc('Sales Order', 'SO-00001')

# Insert
doc = app.tenant_db.insert_doc('Sales Order', {'customer': 'CUST-001'})

# Update
doc = app.tenant_db.get_doc('Sales Order', 'SO-00001')
doc.status = 'Submitted'
doc.save()
app.tenant_db.commit()

# Count
count = app.tenant_db.count('Sales Order', filters={'status': 'Draft'})

# Exists
exists = app.tenant_db.exists('Sales Order', 'SO-00001')
```

### 3. SQL Queries (Parameterized Only)

```python
tenant_id = app.tenant_db.get_tenant_id()

# ✅ Good - parameterized
result = app.tenant_db.sql("""
    SELECT name, customer, grand_total
    FROM `tabSales Order`
    WHERE tenant_id = %s AND status = %s
    LIMIT %s
""", (tenant_id, 'Draft', 10), as_dict=True)

# ❌ NEVER use string formatting
```

### 4. Transactions

```python
try:
    frappe.db.begin()
    doc1 = app.tenant_db.insert_doc('DocType1', data1)
    doc2 = app.tenant_db.insert_doc('DocType2', data2)
    app.tenant_db.commit()
except Exception as e:
    app.tenant_db.rollback()
    raise
```

## Security Rules

1. Always set tenant_id first: `app.set_tenant_id(tenant_id)`
2. Never use `frappe.db` directly
3. Parameterized SQL only (never f-strings)
4. Verify tenant_id exists: `app.tenant_db.get_tenant_id()`
5. Handle `DoesNotExistError` for cross-tenant access

## Key Patterns

- List: `app.tenant_db.get_all('DocType', filters={...})`
- Get: `app.tenant_db.get_doc('DocType', name)`
- Create: `app.tenant_db.insert_doc('DocType', data)`
- Update: Get doc, modify, `doc.save()`, `app.tenant_db.commit()`
- Delete: Get doc, `doc.delete()`, `app.tenant_db.commit()`

Remember: This skill is model-invoked. Claude will use it autonomously when detecting tenant-aware query needs.
