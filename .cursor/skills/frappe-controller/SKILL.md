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

## How Controllers Work

Controllers are auto-discovered from `controllers_path` (default: `$SERVICE_PATH/controllers/`). File naming convention maps to DocType:
- `sales_order.py` → class `SalesOrder` → DocType `Sales Order`

The `ControllerRegistry` loads controllers and hooks them into `TenantAwareDB` lifecycle events. When `tenant_db.insert_doc()`, `update_doc()`, or `delete_doc()` is called, the matching controller's lifecycle methods run automatically.

## Core Patterns

### 1. Controller Structure

```python
# controllers/sales_order.py
from frappe_microservice.controller import DocumentController
import frappe

class SalesOrder(DocumentController):
    def validate(self):
        """Called during validation (insert and update)."""
        if not self.customer:
            self.throw("Customer is required")
        self.calculate_total()

    def before_insert(self):
        """Called before insert."""
        if not self.status:
            self.status = 'Draft'
        if not self.transaction_date:
            self.transaction_date = frappe.utils.today()

    def after_insert(self):
        """Called after insert."""
        self.add_comment('Info', f'Order created by {frappe.session.user}')

    def before_update(self):
        """Called before update."""
        if self.has_value_changed('status'):
            old = self.get_value_before_save('status')
            if old == 'Submitted' and self.status == 'Draft':
                self.throw("Cannot revert submitted order to draft")

    def on_update(self):
        """Called on update."""
        pass

    def before_delete(self):
        """Called before delete."""
        if self.status == 'Submitted':
            self.throw("Cannot delete submitted orders")

    def calculate_total(self):
        """Custom helper method."""
        self.grand_total = sum(
            item.amount for item in (self.items or [])
        )
```

### 2. Auto-Discovery (Recommended)

Controllers are auto-discovered when `controllers_path` is set:

```python
app = create_microservice("my-service", controllers_path="./controllers")
# Or auto-resolved from $SERVICE_PATH/controllers/
```

### 3. Manual Registration

```python
from frappe_microservice.controller import register_controller, DocumentController

@register_controller('Sales Order')
class SalesOrder(DocumentController):
    def validate(self):
        pass
```

Or via the registry:
```python
from frappe_microservice.controller import get_controller_registry

registry = get_controller_registry()
registry.register('Sales Order', SalesOrder)
```

### 4. Setup with TenantAwareDB Hooks

```python
from frappe_microservice.controller import setup_controllers

app = create_microservice("my-service")
setup_controllers(app, controllers_directory="./controllers")
```

This auto-discovers controllers AND registers TenantAwareDB hooks so controller methods fire during `insert_doc`/`update_doc`/`delete_doc`.

### 5. Lifecycle Methods

All lifecycle methods receive no arguments -- access document via `self`:

| Method | When it runs |
|--------|-------------|
| `before_validate()` | Before validation |
| `validate()` | During validation |
| `before_insert()` | Before insert |
| `after_insert()` | After insert |
| `before_save()` | Before save (insert or update) |
| `after_save()` | After save |
| `before_update()` | Before update |
| `after_update()` | After update |
| `on_update()` | On update |
| `before_delete()` | Before delete |
| `on_trash()` | Before delete (Frappe convention) |
| `after_delete()` | After delete |
| `on_cancel()` | On cancel |
| `on_submit()` | On submit |

### 6. Helper Methods

```python
class MyController(DocumentController):
    def validate(self):
        # Get/set fields (proxied to self.doc)
        value = self.get('field_name', default='Draft')
        self.set('field_name', 'new_value')

        # Check if field changed (only works during update)
        if self.has_value_changed('status'):
            old = self.get_value_before_save('status')

        # Throw validation error
        self.throw("Error message")

        # Add comment to document
        self.add_comment('Comment', 'Some note')

        # Access the underlying Frappe doc
        self.doc.run_method('custom_method')
```

### 7. Attribute Sync

Setting attributes on the controller syncs them to `self.doc`:
```python
self.status = 'Draft'          # Also sets self.doc.status = 'Draft'
print(self.customer)           # Reads from self.doc.customer
```

## File Naming Convention

| File | Class | DocType |
|------|-------|---------|
| `sales_order.py` | `SalesOrder` | `Sales Order` |
| `purchase_invoice.py` | `PurchaseInvoice` | `Purchase Invoice` |
| `customer.py` | `Customer` | `Customer` |

## Controller Registry API

```python
from frappe_microservice.controller import get_controller_registry

registry = get_controller_registry()
registry.register('Sales Order', SalesOrder)
registry.has_controller('Sales Order')              # True
registry.get_controller('Sales Order')              # SalesOrder class
registry.list_controllers()                         # {'Sales Order': 'SalesOrder'}
registry.create_controller_instance(doc)            # SalesOrder(doc) or None
registry.auto_discover_controllers('./controllers')
registry.add_controller_path('./controllers')
```

## Best Practices

1. **One controller per file** matching the DocType name
2. **Validation** in `validate()` -- business rules that apply to both insert and update
3. **Defaults** in `before_insert()` -- set initial values
4. **Side effects** in `after_insert()` / `after_update()` -- notifications, logging
5. **Guard deletions** in `before_delete()` -- prevent deleting submitted docs
6. Use `self.throw()` for validation errors (calls `frappe.throw`)
7. Controllers work with both `DocumentController` and `frappe.model.document.Document` subclasses

Remember: This skill is model-invoked. Claude will use it autonomously when detecting controller development needs.
