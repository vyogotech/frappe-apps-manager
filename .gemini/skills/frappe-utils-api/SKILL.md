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

## Decision Tree & Reference

*Condensed from `frappe-core-utils` (Frappe_Claude_Skill_Package).*

### “Which frappe.utils helper?” decision tree

```
Date/time → now_datetime / nowdate (or helpers like today()); parse via getdate / get_datetime; shift with add_days, add_months, add_to_date; compare length with date_diff, time helpers; UX strings via format_date, format_datetime, pretty_date; calendars via get_first_day, get_last_day, quarter helpers.

Numbers → flt/cint/cstr/sbool; bank rounding via rounded; divide via safe_div (v15+); currency via fmt_money / money_in_words.

Strings/HTML → strip_html, escape_html, is_html; lists via comma_and / comma_or; optional mask_string [v16+].

Validation → validate_email_address, validate_url(+schemes), validate_phone_number, validate_json_string (+ IBAN/name helpers on newer builds).

Paths/files → get_files_path({public/private}), get_site_path segments, bench path helpers, file sizing utilities.

Imports → `from frappe.utils import ...` inside controllers/whitelist; Server Scripts expose `frappe.utils.*` WITHOUT import lines.
```

### Python quick-reference (supplements examples above)

| Need | Typical API |
|------|--------------|
| “Now” respecting site TZ | `now_datetime()`, `nowdate()`/`today()` (prefer over raw `datetime.now()` / `date.today()`) |
| Duration math | `add_to_date`, `date_diff`, `month_diff`, `time_diff_in_seconds`, `duration_to_seconds` [v15+] |
| Serialization | `parse_json` / `safe_json_loads` where provided; **`frappe.as_json`** vs ad-hoc `json.dumps` for responses |
| Hash / dedupe | `generate_hash`, `unique` |

### Client (Desk) snippets

Same spirit on JS: **`frappe.utils.escape_html`, `parse_json`, `comma_and`, `unique`, `debounce`/`throttle`, `scroll_to`** for UI-heavy code paths.

### NEVER (stdlib shortcuts) ↔ ALWAYS (`frappe.utils`)

| NEVER | ALWAYS | Why |
|-------|---------|-----|
| `datetime.now()`/`date.today()` for business timestamps | Site-aware helpers (`now_datetime`, `nowdate`, …) | Honor configured timezone semantics |
| `float()`/`int()` on DocField payloads | `flt`, `cint`, `cstr`, `sbool` | **`None`/blank safe** conversions |
| `round()` for ERP math | `rounded` (+ precision args) | Consistent banker-style rounding expectations |
| `val1 / val2` blindly | **`safe_div(a, b)`** after v15 | Avoid `ZeroDivisionError` in KPI math |
| `json.loads`/`dumps` for framework boundaries | **`parse_json` / `frappe.as_json`** | Handles empty inputs + consistent payloads |
| String money formatting ignores currency | **`fmt_money` + ISO currency** | Locale/currency correctness |
| `os.path.join` into tenant paths | **`get_site_path` / `get_files_path`** | **Multi-site path safety** |
| Regex stripping HTML | **`strip_html`** | Handles malformed markup better |
| Bare `strftime` ignoring user prefs | **`format_date`/`format_datetime`** | Respects system/user formatting |

Server Scripts: **`frappe.utils.nowdate()`** style — **imports of `frappe.utils` modules are unavailable** inside the sandbox.
