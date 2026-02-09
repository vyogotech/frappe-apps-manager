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
