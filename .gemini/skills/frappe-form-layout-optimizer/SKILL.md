---
name: frappe-form-layout-optimizer
description: Optimize Frappe DocType form layouts using sections, columns, and logical field grouping. Use when designing or refactoring DocType forms for better usability.
---

# Frappe Form Layout Optimizer

Design clean, intuitive, and efficient form layouts in Frappe by organizing fields logically.

## Capabilities

### 1. Optimal Form Structure

**Pattern: Sales Invoice Layout**
```json
{
  "fields": [
    {"fieldname": "title_section", "fieldtype": "Section Break", "label": "Basic Info"},
    {"fieldname": "column_break_1", "fieldtype": "Column Break"},

    {"fieldname": "customer", "fieldtype": "Link", "label": "Customer"},
    {"fieldname": "customer_name", "fieldtype": "Data", "read_only": 1},
    {"fieldname": "posting_date", "fieldtype": "Date", "label": "Date"},

    {"fieldname": "column_break_2", "fieldtype": "Column Break"},

    {"fieldname": "company", "fieldtype": "Link", "label": "Company"},
    {"fieldname": "posting_time", "fieldtype": "Time"},

    {"fieldname": "items_section", "fieldtype": "Section Break", "label": "Items"},
    {"fieldname": "items", "fieldtype": "Table", "options": "Sales Invoice Item"},

    {"fieldname": "totals_section", "fieldtype": "Section Break", "label": "Totals"},
    {"fieldname": "column_break_3", "fieldtype": "Column Break"},

    {"fieldname": "total", "fieldtype": "Currency", "read_only": 1},
    {"fieldname": "grand_total", "fieldtype": "Currency", "read_only": 1}
  ]
}
```

### 2. Layout Principles

- **Section Breaks**: Group related fields into logical blocks. Use clear, concise labels.
- **Column Breaks**: Create 2-column layouts for high-density forms. Limit to 2 columns for readability.
- **Primary Info First**: Place mandatory and most-used fields in the first section.
- **Calculated Fields**: Group read-only or system-calculated fields in a separate "Totals" or "System Info" section.
- **Child Tables**: Always place child tables in their own full-width Section Break for better grid display.

## References
- Form Layout: https://frappeframework.com/docs/user/en/desk/forms/layouts
- Field Types: https://frappeframework.com/docs/user/en/basics/doctypes#field-types
