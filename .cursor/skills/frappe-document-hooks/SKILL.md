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

## How Hooks Work

`DocumentHooks` is a callback registry used by `TenantAwareDB`. When you call `insert_doc()`, `update_doc()`, or `delete_doc()`, registered hooks fire automatically. Global hooks (`'*'`) run first, then DocType-specific hooks, in registration order.

## Core Patterns

### 1. Generic Decorator

```python
@app.tenant_db.on('Sales Order', 'before_insert')
def set_order_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'
    if not doc.transaction_date:
        doc.transaction_date = frappe.utils.today()
```

### 2. Convenience Decorators

```python
@app.tenant_db.before_validate('Sales Order')
def validate_order(doc):
    if not doc.customer:
        frappe.throw("Customer is required")
    if doc.grand_total and doc.grand_total < 0:
        frappe.throw("Order total cannot be negative")

@app.tenant_db.before_insert('Sales Order')
def set_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'

@app.tenant_db.after_insert('Sales Order')
def notify_on_create(doc):
    app.logger.info(f"Order {doc.name} created for {doc.customer}")

@app.tenant_db.before_update('Sales Order')
def guard_status_change(doc):
    pass

@app.tenant_db.after_update('Sales Order')
def log_update(doc):
    app.logger.info(f"Order {doc.name} updated")

@app.tenant_db.before_delete('Sales Order')
def prevent_submitted_delete(doc):
    if doc.status == 'Submitted':
        frappe.throw("Cannot delete submitted orders")

@app.tenant_db.after_delete('Sales Order')
def cleanup_after_delete(doc):
    app.logger.info(f"Order {doc.name} deleted")
```

### 3. Global Hooks (All DocTypes)

```python
@app.tenant_db.on('*', 'before_insert')
def ensure_tenant_id(doc):
    """Runs for ALL doctypes before insert."""
    from flask import g
    if not getattr(doc, 'tenant_id', None) and hasattr(g, 'tenant_id'):
        doc.tenant_id = g.tenant_id

@app.tenant_db.after_insert('*')
def audit_log(doc):
    """Log every document creation."""
    app.logger.info(f"Created {doc.doctype}: {doc.name}")
```

### 4. Multiple Hooks Same Event

```python
@app.tenant_db.on('Sales Order', 'before_insert')
def set_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'

@app.tenant_db.on('Sales Order', 'before_insert')
def calculate_totals(doc):
    # Runs after set_defaults (registration order)
    if hasattr(doc, 'items'):
        doc.grand_total = sum(item.amount for item in doc.items)
```

### 5. Direct Registration (Non-Decorator)

```python
def my_handler(doc):
    pass

app.tenant_db.hooks.register('Sales Order', 'before_insert', my_handler)
```

## Available Events

| Event | When | Used in |
|-------|------|---------|
| `before_validate` | Before validation | `insert_doc`, `update_doc` |
| `validate` | During validation | via controller hooks |
| `before_insert` | Before DB insert | `insert_doc` |
| `after_insert` | After DB insert | `insert_doc` |
| `before_update` | Before update | `update_doc` |
| `after_update` | After update (after save) | `update_doc` |
| `before_save` | Before save | via controller hooks |
| `after_save` | After save | via controller hooks |
| `before_delete` | Before delete | `delete_doc` |
| `after_delete` | After delete | `delete_doc` |

## Hook Execution Order

**insert_doc:**
1. Global `before_validate` hooks
2. DocType `before_validate` hooks
3. Global `before_insert` hooks
4. DocType `before_insert` hooks
5. `doc.insert()` (Frappe's validate/before_save/after_save run here)
6. Global `after_insert` hooks
7. DocType `after_insert` hooks

**update_doc:**
1. `before_update` hooks
2. `doc.update(data)` (apply fields)
3. `before_validate` hooks
4. `doc.save()` (Frappe's validate/on_update/after_save run here)
5. `after_update` hooks

**delete_doc:**
1. `before_delete` hooks
2. `doc.delete()` (Frappe's on_trash runs here)
3. `after_delete` hooks

## Debugging Hooks

```python
# List all registered hooks
hooks = app.tenant_db.list_hooks()
# Returns: {
#   '*': {'before_insert': ['ensure_tenant_id']},
#   'Sales Order': {'before_insert': ['set_defaults', 'calculate_totals']},
# }
```

## Best Practices

1. **Global hooks first**: Use `'*'` for cross-cutting concerns (tenant_id, audit)
2. **Validation in before_validate**: Business rules that apply to insert and update
3. **Defaults in before_insert**: Set initial values
4. **Side effects in after_insert/after_update**: Notifications, logging, async tasks
5. **Guard in before_delete**: Prevent deleting protected documents
6. Use `frappe.throw()` in hooks to abort the operation with a proper error
7. Hooks that raise exceptions abort the operation (configurable via `raise_on_error`)

Remember: This skill is model-invoked. Claude will use it autonomously when detecting hook development needs.
