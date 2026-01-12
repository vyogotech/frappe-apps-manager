---
name: frappe-document-hooks
description: Generate document lifecycle hooks for DocTypes without modifying Frappe core.
---

# Generate Document Hooks

Create document lifecycle hooks using frappe-microservice-lib hook system.

## When to Use

- Need code on document lifecycle events
- Want to avoid modifying Frappe core
- Prefer function-based hooks over controllers
- Need global hooks for all doctypes

## Core Patterns

### 1. Hook Registration

```python
# Global hook - runs for ALL doctypes
@app.tenant_db.on('*', 'before_insert')
def ensure_tenant_id(doc):
    from flask import g
    if not doc.tenant_id and hasattr(g, 'tenant_id'):
        doc.tenant_id = g.tenant_id

# DocType-specific hook
@app.tenant_db.on('Sales Order', 'before_insert')
def set_order_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'
    if not doc.transaction_date:
        doc.transaction_date = frappe.utils.today()

@app.tenant_db.on('Sales Order', 'validate')
def validate_order(doc):
    if not doc.customer:
        frappe.throw("Customer is required")
    if doc.grand_total and doc.grand_total < 0:
        frappe.throw("Order total cannot be negative")
```

### 2. Available Events

- `before_validate`, `validate`, `before_insert`, `after_insert`
- `before_update`, `after_update`, `before_save`, `after_save`
- `before_delete`, `after_delete`

### 3. Multiple Hooks

```python
# All hooks run in registration order
@app.tenant_db.on('Sales Order', 'before_insert')
def set_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'

@app.tenant_db.on('Sales Order', 'before_insert')
def calculate_totals(doc):
    # Runs after set_defaults
    doc.calculate_totals()
```

### 4. Error Handling

```python
@app.tenant_db.on('Sales Order', 'validate')
def validate_order(doc):
    try:
        if not doc.customer:
            frappe.throw("Customer is required")
    except frappe.ValidationError:
        raise
    except Exception as e:
        frappe.log_error(f"Validation error: {e}")
```

## Key Patterns

1. **Global hooks first**: Use `'*'` for hooks applying to all doctypes
2. **DocType-specific after**: Register specific hooks after global ones
3. **Validation in validate**: Use `validate` hook for business rules
4. **Defaults in before_insert**: Set defaults before document is saved
5. **Notifications in after_insert**: Send notifications after successful creation
6. **Error handling**: Use `frappe.throw()` for validation errors

Remember: This skill is model-invoked. Claude will use it autonomously when detecting hook development needs.
