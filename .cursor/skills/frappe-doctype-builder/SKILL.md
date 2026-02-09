---
name: frappe-doctype-builder
description: Generate complete Frappe DocType with JSON, Python controller, and JavaScript form scripts.
---

# Generate Frappe DocType

Create complete DocType definitions with proper field types, permissions, controllers, and client scripts.

## When to Use

- Creating new DocTypes
- Adding fields to existing DocTypes
- Building master/transaction DocTypes
- Creating child tables

## Core Patterns

### 1. DocType JSON

```json
{
  "doctype": "DocType",
  "name": "Customer",
  "module": "CRM",
  "autoname": "naming_series:",
  "title_field": "customer_name",
  "track_changes": 1,
  "is_submittable": 0,
  "fields": [
    {
      "fieldname": "customer_name",
      "label": "Customer Name",
      "fieldtype": "Data",
      "reqd": 1
    },
    {
      "fieldname": "email_id",
      "label": "Email",
      "fieldtype": "Data",
      "options": "Email"
    }
  ],
  "permissions": [
    {
      "role": "System Manager",
      "read": 1,
      "write": 1,
      "create": 1,
      "delete": 1
    }
  ]
}
```

### 2. Field Types

**Common:** Data, Text, Int, Float, Currency, Date, Datetime, Link, Table, Select, Check
**Special:** HTML, Code, Color, Geolocation, Attach, Attach Image

### 3. DocType Patterns

**Master:** `track_changes: 1`, `is_submittable: 0`
**Transaction:** `is_submittable: 1`, `track_changes: 1`
**Child Table:** `istable: 1`, `editable_grid: 1`
**Settings:** `issingle: 1`

### 4. Python Controller

```python
import frappe
from frappe.model.document import Document

class Customer(Document):
    def validate(self):
        if self.email_id:
            frappe.utils.validate_email_address(self.email_id, throw=True)
        if self.credit_limit and self.credit_limit < 0:
            frappe.throw("Credit Limit cannot be negative")
    
    def before_insert(self):
        if not self.customer_type:
            self.customer_type = "Company"
    
    def after_insert(self):
        self.create_primary_contact()
```

### 5. JavaScript Form Script

```javascript
frappe.ui.form.on('Customer', {
    refresh: function(frm) {
        if (frm.doc.docstatus === 0) {
            frm.add_custom_button(__('Create Quotation'), function() {
                frappe.new_doc('Quotation', {'party_name': frm.doc.name});
            });
        }
    },
    customer_type: function(frm) {
        frm.set_df_property('company_name', 'hidden', 
            frm.doc.customer_type === 'Individual' ? 1 : 0);
    }
});
```

### 6. Naming Series

```json
{
  "fieldname": "naming_series",
  "fieldtype": "Select",
  "options": "CUST-.YYYY.-",
  "default": "CUST-.YYYY.-",
  "reqd": 1
}
```

And in DocType: `"autoname": "naming_series:"`

## Key Patterns

1. Field naming: snake_case
2. Labels: Title Case
3. Required: `"reqd": 1`
4. Validation: `validate()` method
5. Defaults: `before_insert()` or field default
6. Permissions: Role-based in JSON

## Best Practices

- Master data: `track_changes: 1`
- Transactions: `is_submittable: 1`
- Child tables: `istable: 1`, `editable_grid: 1`
- Validate in controller
- Client scripts for UX only
- Least privilege permissions

Remember: This skill is model-invoked. Claude will use it autonomously when detecting DocType development tasks.
