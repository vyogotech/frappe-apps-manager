---
name: Explain Frappe/ERPNext Concept
description: Explain Frappe and ERPNext concepts, patterns, and conventions to help developers understand the framework.
---

# Explain Frappe/ERPNext Concept

Provide concise explanations of Frappe and ERPNext concepts, patterns, and conventions.

## When to Use

- Developer needs to understand a Frappe concept
- Explaining DocType structure
- Understanding Frappe conventions
- Learning ERPNext patterns

## Instructions

### Core Concepts

**DocType**: A Frappe document type (like a database table with metadata). Examples: Customer, Sales Order, Item.

**Document**: An instance of a DocType (like a database row). Has fields, methods, and lifecycle hooks.

**Field Types**: 
- Data: Text, Int, Float, Date, Datetime, Link, Dynamic Link
- Table: Child table (one-to-many relationship)
- Section Break: Visual separator
- Column Break: Horizontal layout

**Naming Convention**:
- DocType: "Sales Order" (Title Case with spaces)
- Field: "customer_name" (snake_case)
- File: "sales_order.py" (snake_case)
- Class: "SalesOrder" (PascalCase)

### Common Patterns

**Link Fields**: Reference another DocType
```python
customer = Link("Customer")  # Links to Customer doctype
```

**Child Tables**: One-to-many relationships
```python
items = Table("Sales Order Item")  # Child table
```

**Status Field**: Common pattern for workflow
```python
status = Select(["Draft", "Submitted", "Cancelled"])
```

**Naming Series**: Auto-generate document names
```python
naming_series = "SO-.YYYY.-"  # Generates SO-2024-00001
```

### Lifecycle Methods

Frappe documents have lifecycle methods:
- `validate()` - Business rule validation
- `before_insert()` - Before saving new document
- `after_insert()` - After saving new document
- `before_update()` - Before updating existing document
- `after_update()` - After updating existing document
- `on_submit()` - When document is submitted
- `on_cancel()` - When document is cancelled
- `on_trash()` - Before deleting document

### Database Access

**Standard Frappe**:
```python
# Get document
doc = frappe.get_doc("Sales Order", "SO-00001")

# Get all
docs = frappe.get_all("Sales Order", filters={...})

# Create
doc = frappe.get_doc({"doctype": "Sales Order", "customer": "..."})
doc.insert()

# Update
doc = frappe.get_doc("Sales Order", "SO-00001")
doc.status = "Submitted"
doc.save()
```

**Microservice (Tenant-Aware)**:
```python
# Always use app.tenant_db
app.set_tenant_id(tenant_id)
doc = app.tenant_db.get_doc("Sales Order", "SO-00001")
docs = app.tenant_db.get_all("Sales Order", filters={...})
```

### Common DocTypes

**Sales Module**:
- Customer - Customer master data
- Sales Order - Customer orders
- Sales Invoice - Invoicing
- Quotation - Sales quotes

**Stock Module**:
- Item - Product master data
- Warehouse - Storage locations
- Stock Entry - Stock movements
- Delivery Note - Goods delivery

**Accounting Module**:
- Company - Company master
- Account - Chart of accounts
- Journal Entry - Accounting entries
- Payment Entry - Payments

### Best Practices

1. **Always validate** - Use `validate()` method for business rules
2. **Set defaults** - Use `before_insert()` for default values
3. **Use Link fields** - Don't store names, use Link to DocType
4. **Child tables** - Use for one-to-many relationships
5. **Naming series** - Use for auto-generated document names
6. **Status workflow** - Use status field for document states

### Multi-Tenancy

In microservices:
- Every document needs `tenant_id` field
- Use `app.tenant_db` for automatic filtering
- Never use `frappe.db` directly in microservices
- Always set `app.set_tenant_id()` before queries

### Error Handling

```python
# Validation error
frappe.throw("Error message")

# Permission error
frappe.throw("Permission denied", frappe.PermissionError)

# Not found
frappe.throw("Document not found", frappe.DoesNotExistError)
```

## Key Takeaways

1. DocType = Database table with metadata
2. Document = Instance/row of a DocType
3. Lifecycle methods = Hooks for document events
4. Link fields = Foreign keys to other DocTypes
5. Child tables = One-to-many relationships
6. Tenant isolation = Automatic filtering by tenant_id
