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

## Decision Tree & Reference

Canonical **Frappe** document lifecycle reference (`hooks.py` `doc_events` and DocType controllers). Use for parity when naming or ordering logic; framework event names (`on_trash`, `on_update`, etc.) may differ slightly from decorator names in code above.

### Event execution order (when they fire)

**Insert (new doc):** `before_insert` → `before_naming` → `autoname` → `before_validate` → `validate` → `before_save` → *(db_insert)* → `after_insert` → `on_update` → `on_change`

**Save (existing):** `before_validate` → `validate` → `before_save` → *(db_update)* → `on_update` → `on_change`

**Submit:** `before_validate` → `validate` → `before_save` → `before_submit` → *(db_update)* → `on_submit` → `on_update` → `on_change`

**Cancel:** `before_cancel` → *(db_update)* → `on_cancel` → `on_change`

**Delete:** `on_trash` → `after_delete`

**Other:** Rename — `before_rename` → `after_rename`. Amend — insert chain runs on new amended doc. Update after submit — `before_update_after_submit` → *(db_update)* → `on_update_after_submit` → `on_change`

### Choosing an event (use case → event)

| Need | Event |
|------|--------|
| Block invalid saves | `validate` (use `frappe.throw()`) |
| Defaults before validation | `before_validate` |
| Logic **only** on first create | `after_insert` (not on later saves) |
| Logic on **every** save (insert + update) | `on_update` |
| Side effects after submit (e.g. linked docs) | `on_submit` |
| Reverse/clean up on cancel | `on_cancel` |
| Name / naming rules | `autoname` or `before_naming` (controller) |
| Block deletion | `on_trash` (raise to abort) |
| Submitted-doc field updates | `before_update_after_submit` / `on_update_after_submit` |
| Only when field values **changed** vs DB | `on_change` |

**Where to register:** Own DocType → controller methods (preferred). Other app’s DocType → `doc_events` in `hooks.py`. All DocTypes → `doc_events` with `"*"` key.

**App-level “which hook file” (non-doc):** Periodic jobs → `scheduler_events`. Client boot data → `extend_bootinfo`. List/desk assets → `app_include_js` / `doctype_js`. Permissions → `permission_query_conditions` / `has_permission`. Replace whole controller (v14–15) → `override_doctype_class`; stack extensions (v16+) → `extend_doctype_class`.

### Handler order and transactions

- **Same event, multiple handlers:** Controller method runs first; then `doc_events` handlers in **app installation order**; `"*"` wildcard handlers run **after** DocType-specific handlers.
- **Multi-app `doc_events`:** Order follows installed apps (adjustable via **Setup → Installed Applications → Update Hooks Resolution Order**). `override_doctype_class`: only one winner (last installed app). `extend_doctype_class` (v16+): extensions stack (MRO / hook priority).
- **Transactions:** From `before_validate` through `on_change`, work is in **one** DB transaction; any exception rolls back. Do **not** assume other requests see writes until the request finishes. `after_delete` still runs in the request transaction context.

### ALWAYS / NEVER (document & hooks.py)

- ALWAYS accept `method=None` as second argument in `doc_events` handlers: `def handler(doc, method=None):`. For rename: `def handler(doc, method, old, new, merge):`.
- ALWAYS run `bench --site <site> migrate` after changing `hooks.py`.
- ALWAYS use **dotted paths** in `hooks.py` — never lambdas; **never** `import frappe` at module top level in `hooks.py` (runs before init).
- NEVER call `frappe.db.commit()` inside `doc_events` / document hook handlers — Frappe owns the transaction.
- NEVER use `doc.save()` inside `validate` or `before_save` — risks infinite recursion.
- NEVER create dependent records that must exist at commit inside `validate` — prefer `on_submit` / post-commit patterns where appropriate.
- NEVER modify `doc.name` outside `autoname` / `before_naming`.
- NEVER rely on `on_change` for critical invariants — it only runs when values differ from DB.
- For field updates in `on_update` on existing docs, **direct `doc` attribute changes can be lost** — use `frappe.db.set_value()` when the framework pattern requires it.
- When subclassing controllers: ALWAYS call `super().<event>()` so core logic is preserved.
- Use `doc.flags` to pass state between events in the same request; use `doc.flags.ignore_permissions = True` only when intentionally bypassing permissions.

### Session hook order (app-level, related)

`on_login` → session created → `on_session_creation` → `extend_bootinfo`.
