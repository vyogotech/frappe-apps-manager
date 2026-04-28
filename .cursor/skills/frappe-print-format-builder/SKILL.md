---
name: frappe-print-format-builder
description: Design and implement custom Print Formats in Frappe using Jinja2 templates and CSS.
---

# Frappe Print Format Builder

Print Formats allow you to generate PDFs or HTML views of DocType data.

## When to Use

- Creating professional invoices, certificates, or reports.
- Customizing the layout of data for physical printing or emailing as attachments.

## Core Patterns

### 1. Print Format Definition

Standard print formats are stored in the `print_format` directory of your module.

**File Path:** `[app_name]/[module_name]/print_format/[format_name]/[format_name].json`

### 2. Jinja2 Templating

Most custom print formats use HTML + Jinja2.

**Example Template (`format_name.html`):**
```html
<div class="print-format">
    <h1>{{ doc.doctype }}: {{ doc.name }}</h1>
    <hr>
    <div class="row">
        <div class="col-xs-6">
            <strong>Customer:</strong> {{ doc.customer_name }}
        </div>
        <div class="col-xs-6 text-right">
            <strong>Date:</strong> {{ frappe.format_date(doc.posting_date) }}
        </div>
    </div>

    <table class="table table-bordered mt-4">
        <thead>
            <tr>
                <th>Item</th>
                <th class="text-right">Qty</th>
                <th class="text-right">Rate</th>
            </tr>
        </thead>
        <tbody>
            {% for item in doc.items %}
            <tr>
                <td>{{ item.item_name }}</td>
                <td class="text-right">{{ item.qty }}</td>
                <td class="text-right">{{ item.get_formatted("rate") }}</td>
            </tr>
            {% endfor %}
        </tbody>
    </table>
</div>
```

## Key Requirements

1. **`is_standard: 1`**: Ensures the print format is tracked in version control.
2. **`print_format_type: "Jinja"`**: Specifies that the format uses a Jinja template.
3. **Bootstrapping**: Use Bootstrap classes (e.g., `row`, `col-xs-*`, `table`) as Frappe's PDF generator (wkhtmltopdf) handles them best.

## Best Practices

- **Formatting**: Use `frappe.format_date()`, `frappe.format_currency()`, or `doc.get_formatted("field")` for localized data display.
- **Images**: Use absolute URLs or Base64 for images/logos to ensure they render in PDFs.
- **Styles**: Include a `<style>` block in your template for custom CSS specific to the print layout.
