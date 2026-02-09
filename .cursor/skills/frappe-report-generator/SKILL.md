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
