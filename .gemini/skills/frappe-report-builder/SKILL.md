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

## Decision Tree & Reference

_Source: consolidated from `frappe-syntax-reports` and `frappe-impl-reports` (Frappe Claude Skill Package). Focus: Report Builder (UI) vs coded reports._

### Choosing Report Builder vs Query vs Script

```
Need a report?
├─ Simple list/group of ONE DocType, no custom code → Report Builder
├─ Direct SQL only, no Python → Query Report
├─ Complex logic, charts, summary cards, formatters → Script Report
│   └─ Very large dataset / timeout risk → Prepared Report
└─ Workspace KPIs → Number Card or Dashboard Chart (separate DocTypes)
```

### Report Builder (UI) — quick reference

| Aspect | Report Builder | Query / Script Report |
|--------|----------------|------------------------|
| Code | None | SQL and/or Python + JS |
| Best for | Ad-hoc tabular views, filters, sort, **Group By** (Count / Sum / Avg) on one DocType | Joins, custom SQL, Python aggregation, charts, `report_summary`, custom formatters |
| Typical access | Users who can open the DocType / module | Often stricter (e.g. System Manager / Dev Mode for standard Script Reports) |
| Deployment | Saved in DB; can export standard report JSON to app | Standard reports live under `report/<name>/` in the app |

### UI Report Builder–specific tips

- Use **Report Builder** when the answer is “show me these fields from this DocType with filters and maybe a group total” — stay in the UI; do not add an app report unless you need version control or sharing as product defaults.
- **Group By** in the UI supports aggregates (e.g. Count, Sum, Avg) on a single DocType; multi-DocType logic or custom chart datasets still require a **Script** (or **Query**) report.
- **Query Report** is SQL-centric and uses the legacy `"Label:Fieldtype/Options:Width"` column format in `SELECT` aliases, not the dict column list from Script Reports.
- **Script Report** is where you implement `execute()`, optional `chart`, `report_summary`, `prepared_report` in JS, and client `formatter` functions — none of that is available inside pure Report Builder configuration.

### Prepared reports (when the UI report is not enough)

If users outgrow Report Builder (timeouts, huge row counts), move to a Script (or Query) report and enable **Prepared Report** so generation runs in the background and results are cached for refresh on demand.
