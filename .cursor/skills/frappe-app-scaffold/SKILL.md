---
name: frappe-app-scaffold
description: Canonical folder structure produced by `bench new-app`. Use this as the ground truth for any Frappe app file tree — do NOT invent your own structure.
tags:
 - frappe
 - python
 - scaffold
 - architecture
---

# Frappe App Scaffold — Canonical Folder Structure

This is the **exact** folder structure that `bench new-app ` produces. Any Frappe app MUST follow this layout. Do NOT add folders like `models/`, `controllers/`, `views/`, `migrations/`, `manifest.json`, `bench_config.yml`, or `desktop_entry.json` — these do not exist in Frappe.

## CRITICAL: Frappe Desk Auto-Generates the UI

**A Frappe app does NOT need custom UI code.** Frappe's Desk automatically generates:
- List views, form views, report views from DocType JSON definitions
- Navigation sidebar from `modules.txt`
- Print formats from DocType fields

You only need to create **DocTypes (JSON + Python controller + JS form script)** and **hooks.py**. The rest is handled by Frappe automatically. Do NOT create custom page renderers, view templates, or UI generators unless the user explicitly asks for a web portal or public website.

## ⚠️ CRITICAL: Three-Level Nesting Rule

Frappe apps have THREE levels of same-name folders. This is NOT a typo:

```
leave_tracker/                          ← Level 1: App root
└── leave_tracker/                      ← Level 2: Inner Python package
    └── leave_tracker/                  ← Level 3: Module folder (from modules.txt)
        └── doctype/                    ← doctype/ is INSIDE the module folder
            └── leave_request/
                ├── leave_request.json
                └── leave_request.py
```

**The `doctype/` folder NEVER goes directly under the inner package (Level 2).**
It ALWAYS goes inside a module folder (Level 3).

WRONG: `leave_tracker/leave_tracker/doctype/` — missing the module folder!
RIGHT: `leave_tracker/leave_tracker/leave_tracker/doctype/`

The Python import path reflects this: `leave_tracker.leave_tracker.doctype.leave_request.leave_request`

## REQUIRED Files (minimum viable Frappe app)

```
invoicing/                         # Level 1: App root (bench new-app creates this)
├── invoicing/                     # Level 2: Inner package (same name as app)
│   ├── __init__.py
│   ├── hooks.py                   # App hooks (scheduler, doc_events, fixtures, etc.)
│   ├── modules.txt                # One module name per line
│   ├── patches.txt                # Migration patches (one dotted path per line)
│   ├── config/
│   │   ├── __init__.py
│   │   └── desktop.py             # Module icon for desk sidebar
│   ├── <module_name>/             # Level 3: Module folder (one per modules.txt entry)
│   │   ├── __init__.py            # ← doctype/ goes INSIDE here, NOT at Level 2
│   │   └── doctype/
│   │       ├── __init__.py
│   │       └── <doctype_name>/    # One folder per DocType
│   │           ├── __init__.py
│   │           ├── <doctype_name>.json    # DocType definition (fields, perms, etc.)
│   │           ├── <doctype_name>.py      # Python controller
│   │           ├── <doctype_name>.js      # Client-side form script
│   │           └── test_<doctype_name>.py # Unit tests
├── setup.py                       # Python package setup
├── setup.cfg
├── requirements.txt               # Python dependencies (if any beyond Frappe)
├── MANIFEST.in
├── license.txt
└── README.md
```

## OPTIONAL directories (only create if user asks)

These are scaffolded by `bench new-app` but are EMPTY and should NOT be populated unless the user explicitly asks for web portals, public pages, or custom CSS/JS:

- `templates/` — only needed for Jinja web portal pages
- `templates/pages/` — only needed for public website pages
- `templates/includes/` — only needed for reusable Jinja fragments
- `templates/generators/` — only needed for custom print format generators
- `public/css/` — only needed for custom app-level CSS overrides
- `public/js/` — only needed for custom app-level JS overrides
- `www/` — only needed for public web pages (portal)

**Do NOT create these directories or their __init__.py files by default.** Focus on DocTypes, hooks.py, and config/ only.

## Key Rules

1. **No MVC folders**: Frappe does NOT use `models/`, `controllers/`, `views/`, or `migrations/` directories.
2. **DocType = JSON + Python + JS**: Each DocType is defined by a `.json` file (schema), a `.py` file (server controller), and a `.js` file (client form script).
3. **Schema is in JSON, not Python**: Field definitions, permissions, and naming rules live in `.json`, NOT in Python classes.
4. **No separate migration system**: Schema changes are tracked via the DocType JSON file. Running `bench migrate` applies JSON changes to the database.
5. **modules.txt**: Lists module names (one per line). Each module gets a folder under the inner package.
6. **hooks.py**: Central configuration file for scheduler events, doc_events, fixtures, jinja methods, website generators, etc.
7. **patches.txt**: Data migration scripts listed as dotted paths (e.g., `invoicing.patches.v1_0.fix_tax_rates`).
8. **UI is automatic**: Frappe Desk renders forms, lists, and reports from DocType JSON. Do NOT write custom HTML/Jinja templates for standard CRUD operations.
9. **`import os` and `import json` are normal**: These are standard Python imports used in Frappe apps. They are NOT dangerous.
10. **Three-level nesting is mandatory**: `app/app/module/doctype/` — never put `doctype/` directly under the inner package. See the "Three-Level Nesting Rule" section above.

## Example: Invoicing App with Two DocTypes

This is the MINIMUM you need — just DocTypes, hooks, config, and packaging files:

```
invoicing/
├── invoicing/
│   ├── __init__.py
│   ├── hooks.py
│   ├── modules.txt                # Contains: "Invoicing"
│   ├── patches.txt                # Empty initially
│   ├── config/
│   │   ├── __init__.py
│   │   └── desktop.py
│   ├── invoicing/                 # Module folder (matches modules.txt entry)
│   │   ├── __init__.py
│   │   └── doctype/
│   │       ├── __init__.py
│   │       ├── sales_invoice/
│   │       │   ├── __init__.py
│   │       │   ├── sales_invoice.json
│   │       │   ├── sales_invoice.py
│   │       │   ├── sales_invoice.js
│   │       │   └── test_sales_invoice.py
│   │       └── invoice_item/       # Child table DocType
│   │           ├── __init__.py
│   │           ├── invoice_item.json
│   │           ├── invoice_item.py
│   │           └── test_invoice_item.py
├── setup.py
├── setup.cfg
├── requirements.txt
├── MANIFEST.in
├── license.txt
└── README.md
```

Note: No `templates/`, `public/`, or `www/` directories — those are optional and NOT needed for a standard Frappe app. Frappe Desk auto-generates all UI from DocType JSON.

## hooks.py Example

```python
app_name = "invoicing"
app_title = "Invoicing"
app_publisher = "Your Company"
app_description = "A Frappe app for invoicing"
app_email = "dev@yourcompany.com"
app_license = "MIT"

fixtures = []

doc_events = {
    "Sales Invoice": {
        "validate": "invoicing.invoicing.doctype.sales_invoice.sales_invoice.validate",
        "on_submit": "invoicing.invoicing.doctype.sales_invoice.sales_invoice.on_submit",
    }
}

scheduler_events = {
    "daily": [
        "invoicing.invoicing.doctype.sales_invoice.sales_invoice.send_overdue_reminders"
    ]
}
```

## DocType JSON Example (sales_invoice.json)

```json
{
    "doctype": "DocType",
    "name": "Sales Invoice",
    "module": "Invoicing",
    "autoname": "naming_series:",
    "is_submittable": 1,
    "title_field": "customer_name",
    "search_fields": "customer_name, status",
    "fields": [
        {
            "fieldname": "naming_series",
            "label": "Series",
            "fieldtype": "Select",
            "options": "INV-.YYYY.-",
            "reqd": 1
        },
        {
            "fieldname": "customer",
            "label": "Customer",
            "fieldtype": "Link",
            "options": "Customer",
            "reqd": 1
        },
        {
            "fieldname": "customer_name",
            "label": "Customer Name",
            "fieldtype": "Data",
            "fetch_from": "customer.customer_name",
            "read_only": 1
        },
        {
            "fieldname": "posting_date",
            "label": "Date",
            "fieldtype": "Date",
            "reqd": 1,
            "default": "Today"
        },
        {
            "fieldname": "due_date",
            "label": "Due Date",
            "fieldtype": "Date",
            "reqd": 1
        },
        {
            "fieldname": "items_section",
            "fieldtype": "Section Break",
            "label": "Items"
        },
        {
            "fieldname": "items",
            "label": "Items",
            "fieldtype": "Table",
            "options": "Invoice Item",
            "reqd": 1
        },
        {
            "fieldname": "totals_section",
            "fieldtype": "Section Break",
            "label": "Totals"
        },
        {
            "fieldname": "total",
            "label": "Total",
            "fieldtype": "Currency",
            "read_only": 1
        },
        {
            "fieldname": "status",
            "label": "Status",
            "fieldtype": "Select",
            "options": "\nDraft\nUnpaid\nPaid\nOverdue\nCancelled",
            "default": "Draft"
        }
    ],
    "permissions": [
        {
            "role": "System Manager",
            "read": 1, "write": 1, "create": 1, "delete": 1, "submit": 1, "cancel": 1
        },
        {
            "role": "Accounts User",
            "read": 1, "write": 1, "create": 1, "submit": 1, "cancel": 1
        }
    ]
}
```

## Controller Example (sales_invoice.py)

```python
import frappe
from frappe.model.document import Document

class SalesInvoice(Document):
    def validate(self):
        self.calculate_total()
        self.validate_due_date()

    def calculate_total(self):
        self.total = sum(item.amount for item in self.items)

    def validate_due_date(self):
        if self.due_date and self.posting_date:
            if self.due_date < self.posting_date:
                frappe.throw("Due Date cannot be before Posting Date")

    def on_submit(self):
        self.status = "Unpaid"

    def on_cancel(self):
        self.status = "Cancelled"
```

## What Does NOT Exist in Frappe Apps

These are common mistakes — do NOT include any of these:

- `models/` directory — fields are defined in DocType JSON, not Python model files
- `controllers/` directory — controller logic is in `.py` inside the doctype folder
- `views/` directory — Frappe auto-generates desk views from DocType JSON
- `migrations/` directory — schema is managed by DocType JSON + `bench migrate`
- `manifest.json` — does not exist in Frappe
- `desktop_entry.json` — does not exist; use `config/desktop.py`
- `bench_config.yml` — does not exist
- `app.py` — Frappe apps don't have an app.py entry point
- Flask/Django route files — Frappe uses `@frappe.whitelist()` decorators
- `format.py` — does not exist as a standard Frappe file
