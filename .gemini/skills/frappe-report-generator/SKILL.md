---
name: frappe-report-generator
description: Generate Frappe reports (query/script) with filters, charts, HTML templates, and JS customization.
---

# Frappe Report Generator

Create custom reports for data analysis, dashboards, and business intelligence in Frappe.

## When to Use

- Creating custom reports (query/script)
- Data analysis or aggregation
- Building dashboards
- Report formatting and filters

## Report Types

**Query Report**: SQL-based, fast for large datasets
**Script Report**: Python-based, full flexibility
**Report Builder**: No-code, user-configurable

## Core Patterns

### 1. Basic Query Report

**JSON:**
```json
{
  "name": "Sales Analysis",
  "report_type": "Query Report",
  "ref_doctype": "Sales Order",
  "module": "Selling"
}
```

**Python:**
```python
import frappe
from frappe import _

def execute(filters=None):
    return get_columns(), get_data(filters)

def get_columns():
    return [
        {"fieldname": "customer", "label": _("Customer"), "fieldtype": "Link", "options": "Customer", "width": 150},
        {"fieldname": "grand_total", "label": _("Total"), "fieldtype": "Currency", "width": 120}
    ]

def get_data(filters):
    return frappe.db.sql("""
        SELECT customer, grand_total
        FROM `tabSales Order`
        WHERE docstatus = 1
        AND posting_date BETWEEN %(from_date)s AND %(to_date)s
    """, filters, as_dict=1)
```

### 2. Script Report with Chart & Summary

```python
def execute(filters=None):
    columns = get_columns()
    data = get_data(filters)
    chart = get_chart_data(data)
    summary = get_report_summary(data)
    return columns, data, None, chart, summary

def get_chart_data(data):
    return {
        "data": {"labels": [...], "datasets": [{"name": "Sales", "values": [...]}]},
        "type": "bar"
    }

def get_report_summary(data):
    return [
        {"label": "Total", "value": sum(...), "indicator": "Green"},
        {"label": "Count", "value": len(data), "indicator": "Blue"}
    ]
```

### 3. Filters

```json
{
  "filters": [
    {"fieldname": "from_date", "fieldtype": "Date", "label": "From Date", "reqd": 1},
    {"fieldname": "to_date", "fieldtype": "Date", "label": "To Date", "reqd": 1},
    {"fieldname": "customer", "fieldtype": "Link", "options": "Customer"}
  ]
}
```

### 4. HTML Template

**Pattern**: Use Jinja2-like syntax for custom layouts
**Reference**: See `projectnext/report/project_cost_and_time_report/project_cost_and_time_report.html`

```python
def execute(filters=None):
    # ... get data
    html = None  # HTML file auto-loaded if exists
    return columns, data, None, chart, summary, html
```

**Key HTML patterns:**
- `{{ data[0].field }}` - Access data
- `{{ filters.field }}` - Access filters
- `{% for row in data %}` - Iterate
- `{% var blocks = {} %}` - Grouping

### 5. JavaScript Customization

**Pattern**: Client-side formatting and interactions
**Reference**: See `projectnext/report/project_cost_and_time_report/project_cost_and_time_report.js`

```javascript
frappe.query_reports["Report Name"] = {
    "formatter": function(value, row, column, data, default_formatter) {
        if (column.fieldname === "delay" && value > 5) {
            return `<span style="color: red;">${value}</span>`;
        }
        return default_formatter(value, row, column, data);
    }
};
```

### 6. Axis-Mixed Chart

**Pattern**: Combine bars and lines for multi-metric visualization
**Reference**: See `projectnext/report/project_cost_and_time_report/project_cost_and_time_report.py:120-196`

```python
chart = {
    "data": {
        "labels": labels,
        "datasets": [
            {"name": "Cost", "values": costs, "chartType": "bar"},
            {"name": "Progress", "values": progress, "chartType": "line"}
        ]
    },
    "type": "axis-mixed",
    "colors": ["#7cd6fd", "#5cb85c"]
}
```

### 7. Report Summary with Indicators

**Pattern**: Color-coded indicators based on values
**Reference**: See `projectnext/report/project_cost_and_time_report/project_cost_and_time_report.py:67-118`

```python
summary = [
    {
        "label": "Completion",
        "value": f"{percentage:.1f}%",
        "indicator": "Red" if percentage < 30 else "Orange" if percentage < 70 else "Green"
    }
]
```

### 8. Custom Query Functions

**Pattern**: Organize complex queries in controller modules

```python
from projectnext.controllers.queries.reports.costandtimereport import get_project_report

def get_report_data(filters):
    return get_project_report("Project", "project", "", 0, 200, filters)
```

### 9. Filter Validation

```python
def validate_filters(filters):
    if not filters.get("project"):
        frappe.throw(_("Project is required"))
    if filters.get("start") > filters.get("end"):
        frappe.throw(_("Start Date cannot be after End Date"))
```

### 10. Data Grouping

```python
# Group by category
blocks = {}
for row in data:
    block = row.get("block_name") or "Unassigned"
    if block not in blocks:
        blocks[block] = []
    blocks[block].append(row)
```

## File Structure

```
apps/<app>/<module>/report/<report_name>/
├── __init__.py
├── <report_name>.json
├── <report_name>.py
├── <report_name>.js (optional)
└── <report_name>.html (optional)
```

## Advanced Patterns

**Complex Joins**: Use INNER JOIN with GROUP BY for aggregations
**Dynamic Columns**: Build columns list programmatically
**Caching**: Use `frappe.cache().get_value()` for expensive queries
**Permissions**: Check with `frappe.has_permission()` before data access
**Performance**: Add indexes, use LIMIT, filter early in WHERE clause

## Complete Examples

**Simple Report**: See ERPNext `erpnext/selling/report/sales_analysis/`
**Complex Report**: See `projectnext/report/project_cost_and_time_report/`
- Python: Lines 1-196 (structure, validation, charts, summary)
- HTML: Custom template with grouping
- JS: Client-side formatting
- JSON: Filter configuration

## Best Practices

1. Optimize queries (indexes, LIMIT)
2. Filter early (WHERE clause, not Python)
3. Use parameterized queries
4. Validate filters
5. Check permissions
6. Cache expensive calculations
7. Use HTML templates for complex layouts
8. Use JS for client-side formatting
9. Group data for better presentation
10. Use indicators for quick status

## Key Takeaways

- **Query Reports**: Fast SQL-based reports
- **Script Reports**: Flexible Python-based reports
- **HTML Templates**: Custom layouts and grouping
- **JavaScript**: Client-side formatting
- **Charts**: Bar, line, axis-mixed types
- **Summary**: Indicators for status
- **Validation**: Always validate filters
- **Performance**: Index, cache, limit

Remember: This skill is model-invoked. Claude will use it autonomously when detecting report development tasks.

## Decision Tree & Reference

_Source: consolidated from `frappe-syntax-reports` and `frappe-impl-reports` (Frappe Claude Skill Package)._

### Which report type?

```
Need a report?
├─ Simple list / group by on one DocType → Report Builder (UI-only; Group By: Count/Sum/Avg)
├─ Direct SQL, no Python logic → Query Report (legacy column aliases in SQL)
├─ Complex logic, charts, summaries, trees → Script Report (standard: .py + .js; needs Developer Mode)
└─ Quick Python without deploying an app → Script Report — Custom (Python in Report UI; System Manager)
```

Additional signals (Desk / product):

```
End user builds their own report? → Report Builder
Realtime KPI tile on workspace? → Number Card or Dashboard Chart (not a report substitute)
Huge dataset (>~100k rows) or timeouts? → enable Prepared Report (background job)
```

### Script Report `execute()` return shape

```
What to return?
├─ Data only → columns, data
├─ + HTML message above grid → columns, data, message
├─ + chart → columns, data, None, chart
├─ + summary cards → columns, data, None, None, report_summary
└─ Full → columns, data, message, chart, report_summary, skip_total_row
```

Positional order must stay: `columns`, `data`, `message`, `chart`, `report_summary`, `skip_total_row` / `skip_total_rows` (Frappe expects this sequence).

### Report types (quick glance)

| Type | Code | Typical use | Access notes |
|------|------|-------------|---------------|
| Report Builder | None | Single DocType listing, filters, group by | Broader user access |
| Query Report | SQL | Legacy SQL reports | Often System Manager–level |
| Script Report (standard) | Python + JS | Charts, summaries, complex logic | Administrator + Developer Mode |
| Script Report (custom) | Python in UI | One-offs without shipping code | System Manager |
| Prepared Report | flag on report | Slow / huge result sets | Background generation, cached |

### Supported filter fieldtypes (`.js` `filters`)

| Fieldtype | Options | Behavior |
|-----------|---------|----------|
| `Link` | DocType | Autocomplete |
| `Select` | newline-separated values | Fixed dropdown |
| `Date` | — | Date picker |
| `DateRange` | — | `[from_date, to_date]` |
| `Check` | — | Boolean |
| `Dynamic Link` | fieldname of driving filter | Depends on another filter |
| `Data` | — | Free text |
| `Int` | — | Integer |
| `MultiSelectList` | DocType | Multi-select |

### Chart types & summary rows

- **Chart `type`** (standard): `bar`, `line`, `pie`, `donut`, `percentage` — plus mixed/axis setups when using per-dataset `chartType`.
- **`chart.data`**: `labels` length must match each dataset’s `values` length (otherwise rendering breaks).
- **Chart dict** may include `fieldtype`, `options`, `currency`, `colors`, `height`, `barOptions` (e.g. stacked), etc., as needed for formatting.
- **`report_summary` entries**: `value`, `label`, `datatype` (e.g. `Currency`, `Int`), optional `currency`, `indicator` (`Green`, `Blue`, `Orange`, `Red`, `Grey`).

### ALWAYS / NEVER (report code & data)

- **ALWAYS** return `columns` and `data` as lists — use `[]`, not `None`, when empty.
- **ALWAYS** define **Script Report** columns as dicts with `fieldname`, `label`, `fieldtype` (and `width`). **Query Reports only**: use legacy `"Label:Fieldtype/Options:Width"` in SQL `SELECT` aliases — not the dict format.
- **ALWAYS** use `_(...)` / translatable helpers for user-visible labels in columns and summaries.
- **ALWAYS** bind SQL parameters safely — pass filter values as parameters to `frappe.db.sql` / query builder; **never** interpolate untrusted filter input into the SQL string.
- **ALWAYS** set **Reference DocType** on the Report document so permissions line up with the underlying data.
- **NEVER** use `SELECT *` or load full documents inside tight loops for report rows — select columns in SQL or light APIs.
- **NEVER** skip `width` on column dicts if you care about readable layout in the grid.
- For heavy reports, **ALWAYS** consider indexes on filtered/grouped columns and **Prepared Report** when runtime or row count is high.
