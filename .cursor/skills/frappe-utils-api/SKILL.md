---
name: frappe-utils-api
description: Master the Frappe Framework utility functions for date manipulation, formatting, validation, and type conversion.
---

# Frappe Utilities API

Leverage the powerful `frappe.utils` module and core `frappe` namespace methods to simplify common development tasks.

## When to Use

- Performing date and time arithmetic
- Formatting values for UI display (currency, dates)
- Validating inputs (emails, URLs)
- Safely converting data types
- Sending messages or throwing errors to the user

## Core Patterns

### 1. Date and Time Manipulation

```python
from frappe.utils import now, today, getdate, add_to_date, add_days, get_first_day, get_last_day

# Current values
current_ts = now()           # '2023-10-27 10:30:00'
current_date = today()       # '2023-10-27'

# Conversions
date_obj = getdate("2023-10-27") # Python datetime.date object

# Arithmetic
next_week = add_to_date(today(), days=7)
last_month = add_to_date(now(), months=-1)
tomorrow = add_days(today(), 1)

# Period helpers
month_start = get_first_day(today())
month_end = get_last_day(today())
```

### 2. Safe Type Conversion

Always use these instead of standard `float()` or `int()` to handle `None` or invalid strings gracefully.

```python
from frappe.utils import flt, cint, cstr

# To Float (handles None -> 0.0)
amount = flt(doc.amount, precision=2)

# To Integer (handles None -> 0)
count = cint(doc.count)

# To String (handles None -> "")
name = cstr(doc.name)
```

### 3. Formatting for Display

```python
from frappe.utils import format_currency, format_date, comma_and, money_in_words

# Currency
# Returns: "₹ 1,000.00" (based on company/global defaults)
formatted_amount = format_currency(1000, "INR")

# Date
# Returns: "27-10-2023" (based on system settings)
formatted_date = format_date("2023-10-27")

# Human readable lists
# Returns: "Apple, Banana and Cherry"
list_text = comma_and(["Apple", "Banana", "Cherry"])

# Amount to Words
# Returns: "One Hundred Only"
words = money_in_words(100)
```

### 4. Validation Helpers

```python
from frappe.utils import validate_email_address, validate_url

# Email
validate_email_address("test@example.com", throw=True)

# URL
if not validate_url(self.website):
    frappe.throw("Invalid Website URL")
```

### 5. Core Messaging (frappe namespace)

```python
import frappe
from frappe import _

# User Messages
frappe.msgprint(_("The document has been updated successfully."))

# Errors (Stops execution)
if not doc.status:
    frappe.throw(_("Status is required to proceed"))

# Confirmations
frappe.confirm(_("Are you sure you want to proceed?"), 
    success_action=lambda: do_something())
```

## Key Patterns

1. **Translations**: Always wrap user-facing strings in `_("Your String")`.
2. **Safe Conversions**: Use `flt()`, `cint()`, `cstr()` for any value coming from a DocType or User.
3. **Date Objects**: Use `getdate()` when you need to compare dates in Python logic.
4. **Throwing Errors**: Use `frappe.throw()` to stop execution and rollback the transaction.

## Best Practices

- Prefer `frappe.utils` over native Python modules (like `datetime`) when site-specific logic (like timezones) is needed.
- Use `format_currency` with the correct currency symbol for financial reports.
- Always validate external URLs and emails before saving to the database.
- Use `comma_and` for generating clear error messages or UI notifications involving lists.

## Reference

- [Frappe Utils API Docs](https://docs.frappe.io/framework/user/en/api/utils)
- [Frappe Python API](https://docs.frappe.io/framework/user/en/api)

Remember: This skill is model-invoked. Claude will use it autonomously when writing Frappe backend logic.
