---
name: frappe-monkey-patching
description: Expert-level skill for overriding core Frappe/ERPNext methods, functions, and classes without touching source files. Use for bug fixes, feature enhancements, and deep framework customization.
---

# Frappe Monkey Patching & Overrides

Modify framework behavior safely and maintainably using hooks and runtime reassignments.

## When to Use

- Fixing bugs in core Frappe or third-party apps without waiting for updates.
- Adding custom logic to existing core methods (e.g., `User.validate`).
- Modifying whitelisted methods for custom API behavior.
- Injecting global logic into the request-response cycle.

## Core Patterns

### 1. DocType Class Override (Recommended)

In `hooks.py`:
```python
override_doctype_class = {
    "User": "custom_app.overrides.CustomUser"
}
```

In `custom_app/overrides.py`:
```python
from frappe.core.doctype.user.user import User

class CustomUser(User):
    def validate(self):
        super().validate()  # Call original logic
        # Your custom validation
        if not self.email.endswith('@company.com'):
            frappe.throw("Only company emails are allowed")
```

### 2. Whitelisted Method Override

In `hooks.py`:
```python
override_whitelisted_methods = {
    "frappe.desk.doctype.event.event.get_events": "custom_app.overrides.get_events"
}
```

### 3. Runtime Function Patching

Used for functions that aren't covered by standard hooks.

In `hooks.py`:
```python
after_app_install = "custom_app.overrides.apply_patches"
```

In `custom_app/overrides.py`:
```python
import frappe.utils

def apply_patches():
    # Backup original
    if not hasattr(frappe.utils, '_original_get_url'):
        frappe.utils._original_get_url = frappe.utils.get_url
    
    # Replace
    frappe.utils.get_url = enhanced_get_url

def enhanced_get_url(*args, **kwargs):
    url = frappe.utils._original_get_url(*args, **kwargs)
    # Custom logic
    return url
```

## Best Practices

1. **Always Call `super()`**: When overriding classes, ensure you call the original method unless you intend to replace it entirely.
2. **Backup Originals**: When patching at runtime, store the original function in a private attribute (e.g., `_original_method`) for reference or restoration.
3. **Use Hooks First**: Always prefer standard Frappe hooks (`doc_events`, `override_doctype_class`) over manual monkey patching.
4. **Log Changes**: Use `frappe.logger()` to log when overrides are applied, especially in production.
5. **Handle Imports Carefully**: Be mindful of circular imports when overriding core classes.

Remember: This is an expert skill. Use it judiciously to maintain system stability and upgradeability.
