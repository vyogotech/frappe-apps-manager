---
name: frappe-report-builder
description: Create and configure Frappe Reports, including Report Builder (UI-based), Query Reports (SQL), and Script Reports (Python).
---

# Frappe Report Builder

Frappe supports multiple types of reports to present data effectively.

## When to Use

- **Report Builder:** Simple tabular data from a single DocType with filters and sorting.
- **Query Report:** Complex cross-DocType data retrieval using SQL.
- **Script Report:** Data that requires heavy Python processing, complex aggregation, or external API integration.

## Core Patterns

### 1. Report Builder (Standard)

Standard reports are stored in the database but can be exported to your app.

**File Path:** `[app_name]/[module_name]/report/[report_name]/[report_name].json`

### 2. Query Report (SQL)

Requires a `.json` definition and an `.js` file for filters.

**File Path:** `[app_name]/[module_name]/report/[report_name]/[report_name].json`
```json
{
  "doctype": "Report",
  "name": "My Query Report",
  "report_type": "Query Report",
  "module": "My App",
  "is_standard": "Yes",
  "query": "SELECT name, creation FROM `tabUser` WHERE status = 'Active'"
}
```

### 3. Script Report (Python)

Requires `.json`, `.py`, and `.js` files.

**Python Logic (`report_name.py`):**
```python
import frappe

def execute(filters=None):
    columns = get_columns()
    data = get_data(filters)
    return columns, data

def get_columns():
    return [
        {"label": "ID", "fieldname": "name", "fieldtype": "Link", "options": "User", "width": 150},
        {"label": "Full Name", "fieldname": "full_name", "fieldtype": "Data", "width": 200}
    ]

def get_data(filters):
    return frappe.get_all("User", fields=["name", "full_name"], filters=filters)
```

**JavaScript Filters (`report_name.js`):**
```javascript
frappe.query_reports["My Script Report"] = {
    "filters": [
        {
            "fieldname": "from_date",
            "label": __("From Date"),
            "fieldtype": "Date",
            "default": frappe.datetime.add_months(frappe.datetime.get_today(), -1)
        }
    ]
};
```

## Key Requirements

1. **`is_standard: "Yes"`**: (Note the string "Yes" instead of 1 in older versions, though 1 is common now). Ensures the report is saved as a file.
2. **Directory Structure**: All files (`.json`, `.py`, `.js`) must be in a folder named after the report in the `report/` directory of the module.
3. **Column Definitions**: In Script Reports, the fieldtype and options must match Frappe standard types to enable correct formatting and linking.

## Best Practices

- **Performance**: Use `frappe.db.get_all` or `frappe.qb` (Query Builder) for efficient data retrieval.
- **Labels**: Always wrap labels in `_()` or `__()` for translation support.
- **Visibility**: Add your report to a **Workspace** sidebar or shortcut for easy access.
