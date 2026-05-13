---
name: frappe-controller
description: Generate Frappe-style DocType controllers with lifecycle methods for microservices.
---

# Generate DocType Controller

Create document controller classes with lifecycle methods following Frappe patterns.

## When to Use

- Need business logic for DocType
- Want lifecycle hooks (validate, before_insert, etc.)
- Prefer class-based controllers
- Need reusable methods

## Core Patterns

### 1. Controller Structure

```python
from frappe_microservice.controller import DocumentController
import frappe

class SalesOrder(DocumentController):
    def validate(self):
        if not self.customer:
            self.throw("Customer is required")
        self.calculate_total()
    
    def before_insert(self):
        if not self.status:
            self.status = 'Draft'
        if not self.transaction_date:
            self.transaction_date = frappe.utils.today()
    
    def after_insert(self):
        self.send_order_notification()
    
    def calculate_total(self):
        self.grand_total = sum(item.amount for item in self.items) if self.items else 0
```

### 2. Register Controller

```python
from frappe_microservice.controller import setup_controllers

app = create_microservice("my-service")
setup_controllers(app, controllers_directory="./controllers")
```

### 3. Lifecycle Methods

Available: `before_validate`, `validate`, `before_insert`, `after_insert`, `before_update`, `after_update`, `before_save`, `after_save`, `before_delete`, `on_trash`, `on_cancel`, `on_submit`

### 4. Helper Methods

- `self.throw(message)` - Raise validation error
- `self.get(field, default=None)` - Get field value
- `self.set(field, value)` - Set field value
- `self.has_value_changed(fieldname)` - Check if changed
- `self.get_value_before_save(fieldname)` - Get old value

## Key Patterns

1. **Validation**: Use `validate()` for business rules
2. **Defaults**: Set in `before_insert()`
3. **Notifications**: Send in `after_insert()` or `after_update()`
4. **Calculations**: Create reusable methods
5. **Error Handling**: Use `self.throw()` for validation errors

## File Naming

- File: `sales_order.py` → Class: `SalesOrder` → DocType: `Sales Order`

Remember: This skill is model-invoked. Claude will use it autonomously when detecting controller development needs.

## Decision Tree & Reference

The following material is from **Frappe / ERPNext** controller skills (`frappe-syntax-controllers`, `frappe-impl-controllers`). Use it when mapping lifecycle behavior or aligning with upstream Frappe patterns. Hook **names** in this microservice controller may differ slightly from core Frappe (e.g. `on_update` vs `after_update`); treat the semantics the same unless your SDK docs say otherwise.

### Hook selection (what do you need?)

```
What do you need to do?
|
+-- Validate data or calculate fields?
|   +-- validate (changes to self ARE saved)
|
+-- Action AFTER save (emails, sync, linked docs)?
|   +-- on_update (changes to self are NOT saved — use db_set / set_value)
|
+-- Only for NEW documents?
|   +-- after_insert (runs once on first save only)
|
+-- Custom document name?
|   +-- autoname (set self.name)
|
+-- Before/after SUBMIT?
|   +-- Validate before submit? -> before_submit
|   +-- Create entries after submit? -> on_submit
|
+-- Before/after CANCEL?
|   +-- Check linked docs? -> before_cancel
|   +-- Reverse entries? -> on_cancel
|
+-- Cleanup before delete?
|   +-- on_trash
|
+-- React to ANY value change (including db_set)?
|   +-- on_change (MUST be idempotent)
```

### Quick reference — class, file, and key methods (Frappe)

| Item | Convention |
|------|------------|
| DocType name | Title Case (e.g. `Sales Order`) |
| Class name | PascalCase (e.g. `SalesOrder`) |
| File path (typical app) | `module/doctype/sales_order/sales_order.py` |
| Base class | `from frappe.model.document import Document` |

| Method | Role |
|--------|------|
| `autoname()` | Custom naming — set `self.name` |
| `validate()` | Main validation — runs on every save; field changes on `self` persist |
| `on_update()` | After DB write — assignments to `self` do **not** persist without `db_set` |
| `on_submit()` / `on_cancel()` | Submittable workflow — implement as a matched pair |
| `@frappe.whitelist()` | Expose method to Desk client (`frm.call(...)`) |

### validate vs on_update

| Aspect | `validate` | `on_update` |
|--------|------------|-------------|
| When | Before DB write | After DB write |
| `self.x = y` persisted? | Yes | **No** — use `db_set` or `frappe.db.set_value` |
| Abort save with throw? | Yes | Too late — document already saved |

- **NEVER** put blocking validation-only logic in `on_update` — use `validate()` (or `before_submit` / similar as appropriate).

### Lifecycle execution order (Frappe)

**INSERT (new document)**

```
before_insert -> before_naming -> autoname -> before_validate -> validate
-> before_save -> [db_insert] -> after_insert -> on_update -> on_change
```

**SAVE (existing document)**

```
before_validate -> validate -> before_save -> [db_update]
-> on_update -> on_change
```

**SUBMIT (docstatus 0 -> 1)**

```
before_validate -> validate -> before_submit -> [db_update]
-> on_submit -> on_update -> on_change
```

**CANCEL (docstatus 1 -> 2)**

```
before_cancel -> [db_update] -> on_cancel -> on_change
```

**UPDATE AFTER SUBMIT**

```
before_update_after_submit -> [db_update]
-> on_update_after_submit -> on_change
```

**DELETE**

```
on_trash -> [db_delete] -> after_delete
```

**DISCARD [v15+]**

```
before_discard -> [db_set docstatus=2] -> on_discard
```

### Critical rules — ALWAYS / NEVER

1. **After `on_update`**: direct `self.field = value` is **not** persisted — use `self.db_set(...)` or `frappe.db.set_value(...)`.
2. **NEVER** call `frappe.db.commit()` inside controllers — Frappe commits at end of request; manual commit risks partial updates.
3. **ALWAYS** call `super().validate()` (and equivalents) when overriding hooks so base/ERPNext logic still runs unless you intentionally replace it.
4. **ALWAYS** use `self.flags` (or equivalent) for data passed between hooks in one transaction — avoid global/external mutable state for this.
5. **NEVER** duplicate “must-block-save” validation in `on_update` — validate in `validate()` / `before_submit` as applicable.
6. Submittable documents: **ALWAYS** implement `on_submit` and `on_cancel` together — **ALWAYS** reverse `on_submit` side effects in `on_cancel`.

### Controller vs Server Script (Frappe apps)

```
NEED full Python (imports, classes, libs)?           -> Controller
NEED ERPNext/custom app extension / background jobs? -> Controller
Quick validation without a custom app?               -> Server Script (where enabled)
```

### Anti-pattern quick check

| Do NOT | Do instead |
|--------|------------|
| Expect `self.x = y` in `on_update` to save | `db_set` / `frappe.db.set_value` |
| `self.save()` recursively from `on_update` | Risks loops; use `db_set` or enqueue work |
| `frappe.db.commit()` in controllers | Let the framework manage the transaction |
| Heavy work blocking in `validate` | Consider `frappe.enqueue()` from `on_update` |
| Skip `super()` in overrides | Call parent hooks first unless fully replacing behavior |
| `frappe.get_doc()` in hot loops | Prefer `frappe.get_cached_doc()` when applicable |
