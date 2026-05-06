---
name: frappe-app-scaffold
description: Canonical folder structure produced by `bench new-app` for modern Frappe (v14/v15+). Use this as the ground truth for any Frappe app file tree — includes pyproject.toml and module management.
tags:
 - frappe
 - python
 - scaffold
 - architecture
 - v15
---

# Frappe App Scaffold — Modern Canonical Folder Structure

This is the **exact** folder structure for modern Frappe apps (v14, v15, and v16+). Any Frappe app MUST follow this layout. Modern apps have transitioned from `setup.py` to `pyproject.toml`.

## CRITICAL: Module Management & `modules.txt`

Every Frappe app is organized into **Modules**. A module is a logical grouping of DocTypes.
1. **Directory Naming**: Each module MUST have its own directory under the inner package directory.
2. **`modules.txt`**: This file MUST list every module name in the app, one per line. If a module is not in `modules.txt`, its DocTypes may not be recognized or appear in the Desk.
3. **Module Folder**: Inside each module folder, you MUST have an `__init__.py` and a `doctype/` directory.

## REQUIRED Files (Modern Viable Frappe App)

```
invoicing/                         # App root
├── pyproject.toml                 # Modern Python packaging (Replaces setup.py)
├── invoicing/                     # Inner package (same name as app)
│   ├── __init__.py
│   ├── hooks.py                   # App hooks (scheduler, doc_events, fixtures, etc.)
│   ├── modules.txt                # CRITICAL: List of all module names
│   ├── patches.txt                # Migration patches
│   ├── config/
│   │   ├── __init__.py
│   │   └── desktop.py             # Module icon for desk sidebar
│   ├── <module_name>/             # Folder for each module in modules.txt
│   │   ├── __init__.py
│   │   └── doctype/
│   │       ├── __init__.py
│   │       └── <doctype_name>/    # One folder per DocType
│   │           ├── __init__.py
│   │           ├── <doctype_name>.json    # DocType definition
│   │           ├── <doctype_name>.py      # Python controller
│   │           ├── <doctype_name>.js      # Client-side form script
│   │           └── test_<doctype_name>.py # Unit tests
├── requirements.txt               # Python dependencies
├── MANIFEST.in
├── license.txt
└── README.md
```

## `pyproject.toml` Example (v15+)

```toml
[project]
name = "invoicing"
authors = [
    { name = "Your Company", email = "dev@yourcompany.com" }
]
description = "A Frappe app for invoicing"
requires-python = ">=3.10"
dynamic = ["version"]
dependencies = [
    "frappe>=15.0.0"
]

[build-system]
requires = ["flit_core >=3.4,<4"]
build-backend = "flit_core.buildapi"

[tool.bench]
app-name = "invoicing"
app-title = "Invoicing"
app-publisher = "Your Company"
app-description = "A Frappe app for invoicing"
app-email = "dev@yourcompany.com"
app-license = "MIT"
```

## Key Rules for AI

1. **Always Update `modules.txt`**: When creating a new module folder, immediately add its name to `modules.txt`.
2. **Proper Module Naming**: Module names should be in **Title Case** in `modules.txt` (e.g., `Sales Management`) but the folder name should be **snake_case** (e.g., `sales_management`).
3. **No MVC folders**: Do NOT use `models/`, `controllers/`, or `views/`.
4. **UI is automatic**: Frappe Desk renders everything from DocType JSON.
5. **hooks.py**: This is the brain of your app. Register all your events, filters, and scheduled jobs here.

## Example: Invoicing App with "Billing" Module

**`invoicing/modules.txt`**:
```
Billing
```

**Folder Structure**:
```
invoicing/
├── invoicing/
│   ├── modules.txt
│   ├── billing/                 # Folder for "Billing" module
│   │   ├── __init__.py
│   │   └── doctype/
│   │       ├── __init__.py
│   │       └── sales_invoice/
│   │           ├── ...
```

## What Does NOT Exist in Modern Frappe
- `setup.py` (Deprecated in favor of `pyproject.toml`)
- `setup.cfg` (Deprecated)
- `models/` directory
- `views/` directory

Remember: This skill is the "blueprint" for any new Frappe app. Follow it strictly to ensure compatibility with `bench` and the Frappe Framework.
