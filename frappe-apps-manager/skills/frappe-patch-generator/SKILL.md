---
name: frappe-patch-generator
description: Generate and manage database migration patches in Frappe. Use when performing data transformations, schema corrections, or one-time setup tasks during app updates.
---

# Frappe Patch Generator

Create robust data migration and system update scripts that run safely during `bench migrate`.

## When to Use

- Renaming fields or DocTypes where standard migration isn't enough.
- Transforming existing data (e.g., migrating from one field type to another).
- Setting default values for new fields based on complex logic.
- One-time system configuration or data cleanup.

## Core Patterns

### 1. Registering a Patch

In `patches.txt` (located in your app's inner package):
```
my_app.patches.v1_0.migrate_customer_data
```

### 2. Basic Patch Structure

In `my_app/patches/v1_0/migrate_customer_data.py`:
```python
import frappe

def execute():
    """Main entry point for the patch"""
    # Use frappe.db.sql for bulk updates
    frappe.db.sql("""
        UPDATE `tabCustomer` 
        SET full_name = CONCAT(first_name, ' ', last_name)
        WHERE full_name IS NULL
    """)
    
    # Or use the ORM for complex logic
    customers = frappe.get_all("Customer", filters={"status": "Active"})
    for d in customers:
        doc = frappe.get_doc("Customer", d.name)
        doc.process_legacy_data()
        doc.save()
```

### 3. Schema-Aware Patches

```python
def execute():
    # Check if field exists before operating
    if frappe.db.has_column("Customer", "legacy_id"):
        # Perform migration
        pass
    
    # Reload DocType if schema changes are needed during the patch
    frappe.reload_doc("selling", "doctype", "customer")
```

## Best Practices

1. **Idempotency**: Patches should be safe to run multiple times, although Frappe tracks execution in the `tabPatch Log`.
2. **Use `frappe.db.sql` for Performance**: For large datasets, direct SQL is much faster than `frappe.get_doc`.
3. **Avoid Hardcoded Dependencies**: Be careful when calling methods from other apps that might not be installed or updated yet.
4. **Log Progress**: Use `print` or `frappe.logger()` for long-running patches to provide feedback during `bench migrate`.
5. **Atomic Changes**: Keep patches small and focused on a single logical change.

Remember: Patches are the primary way to evolve a production database safely. Always test them on a copy of production data first.
