---
name: frappe-doctype-builder
description: Generate complete Frappe DocType with JSON, Python controller, and JavaScript form scripts.
---

# Generate Frappe DocType

Create complete DocType definitions with proper field types, permissions, controllers, and client scripts.

## When to Use

- Creating new DocTypes
- Adding fields to existing DocTypes
- Building master/transaction DocTypes
- Creating child tables

## Core Patterns

### 1. DocType JSON

```json
{
  "doctype": "DocType",
  "name": "Customer",
  "module": "CRM",
  "autoname": "naming_series:",
  "title_field": "customer_name",
  "track_changes": 1,
  "is_submittable": 0,
  "fields": [
    {
      "fieldname": "customer_name",
      "label": "Customer Name",
      "fieldtype": "Data",
      "reqd": 1
    },
    {
      "fieldname": "email_id",
      "label": "Email",
      "fieldtype": "Data",
      "options": "Email"
    }
  ],
  "permissions": [
    {
      "role": "System Manager",
      "read": 1,
      "write": 1,
      "create": 1,
      "delete": 1
    }
  ]
}
```

### 2. Field Types

**Common:** Data, Text, Int, Float, Currency, Date, Datetime, Link, Table, Select, Check
**Special:** HTML, Code, Color, Geolocation, Attach, Attach Image

### 3. DocType Patterns

**Master:** `track_changes: 1`, `is_submittable: 0`
**Transaction:** `is_submittable: 1`, `track_changes: 1`
**Child Table:** `istable: 1`, `editable_grid: 1`
**Settings:** `issingle: 1`

### 4. Python Controller

```python
import frappe
from frappe.model.document import Document

class Customer(Document):
    def validate(self):
        if self.email_id:
            frappe.utils.validate_email_address(self.email_id, throw=True)
        if self.credit_limit and self.credit_limit < 0:
            frappe.throw("Credit Limit cannot be negative")
    
    def before_insert(self):
        if not self.customer_type:
            self.customer_type = "Company"
    
    def after_insert(self):
        self.create_primary_contact()
```

### 5. JavaScript Form Script

```javascript
frappe.ui.form.on('Customer', {
    refresh: function(frm) {
        if (frm.doc.docstatus === 0) {
            frm.add_custom_button(__('Create Quotation'), function() {
                frappe.new_doc('Quotation', {'party_name': frm.doc.name});
            });
        }
    },
    customer_type: function(frm) {
        frm.set_df_property('company_name', 'hidden', 
            frm.doc.customer_type === 'Individual' ? 1 : 0);
    }
});
```

### 6. Naming Series

```json
{
  "fieldname": "naming_series",
  "fieldtype": "Select",
  "options": "CUST-.YYYY.-",
  "default": "CUST-.YYYY.-",
  "reqd": 1
}
```

And in DocType: `"autoname": "naming_series:"`

## Key Patterns

1. Field naming: snake_case
2. Labels: Title Case
3. Required: `"reqd": 1`
4. Validation: `validate()` method
5. Defaults: `before_insert()` or field default
6. Permissions: Role-based in JSON

## Best Practices

- Master data: `track_changes: 1`
- Transactions: `is_submittable: 1`
- Child tables: `istable: 1`, `editable_grid: 1`
- Validate in controller
- Client scripts for UX only
- Least privilege permissions

Remember: This skill is model-invoked. Claude will use it autonomously when detecting DocType development tasks.

## Decision Tree & Reference

### Decision Tree: Which DocType Type?

```
Need to store data?
├─ YES: Need multiple records?
│  ├─ YES: Need submit/cancel workflow?
│  │  ├─ YES → Standard DocType + is_submittable=1
│  │  └─ NO: Need hierarchy/tree?
│  │     ├─ YES → Tree DocType (is_tree=1)
│  │     └─ NO: Embedded in parent?
│  │        ├─ YES → Child DocType (istable=1)
│  │        └─ NO → Standard DocType
│  └─ NO: Single config/settings → Single DocType (issingle=1)
└─ NO: Data from external source → Virtual DocType (is_virtual=1)
```

### Quick Reference — DocType JSON top-level properties

| Property | Type | Purpose |
|----------|------|---------|
| `name` | str | DocType identifier (singular, e.g. "Sales Invoice") |
| `module` | str | App module this DocType belongs to |
| `is_submittable` | bool | Enables Draft → Submitted → Cancelled workflow |
| `is_tree` | bool | Enables NestedSet hierarchy (lft/rgt columns) |
| `is_virtual` | bool | No database table; data from custom backend |
| `issingle` | bool | Single-instance settings document |
| `istable` | bool | Child table DocType (embedded in parent) |
| `is_calendar_and_gantt` | bool | Enables calendar/gantt views |
| `track_changes` | bool | Stores version history on every save |
| `track_seen` | bool | Tracks which users viewed the document |
| `track_views` | bool | Counts total document views |
| `allow_rename` | bool | Permits renaming after creation |
| `allow_copy` | bool | Enables "Duplicate" action |
| `allow_import` | bool | Enables Data Import for this DocType |
| `naming_rule` | str | Naming method selector (see Naming rules below) |
| `autoname` | str | Naming pattern string |
| `title_field` | str | Field used as display title |
| `search_fields` | str | Comma-separated fields for search results |
| `show_title_field_in_link` | bool | Display title instead of name in Link fields |
| `image_field` | str | Field containing image for avatar display |
| `sort_field` | str | Default sort column |
| `sort_order` | str | "ASC" or "DESC" |
| `default_print_format` | str | Print Format name |
| `max_attachments` | int | Attachment limit |

### Quick Reference — Common fieldtypes

| Fieldtype | Stores | DB Column |
|-----------|--------|-----------|
| Data | Text up to 140 chars | VARCHAR(140) |
| Link | Reference to another DocType | VARCHAR(140) |
| Dynamic Link | Reference to any DocType | VARCHAR(140) |
| Select | Single choice from options | VARCHAR(140) |
| Table | Child table rows | Separate table |
| Table MultiSelect | Multi-select link rows | Separate table |
| Check | Boolean 0/1 | TINYINT |
| Int | Whole number | INT |
| Float | Decimal (9 places) | DECIMAL |
| Currency | Money value (6 decimals) | DECIMAL |
| Date | Calendar date | DATE |
| Datetime | Date + time | DATETIME |
| Text Editor | Rich text (HTML) | LONGTEXT |
| Attach | File reference | VARCHAR(140) |
| Small Text | Short multi-line text | TEXT |
| Long Text | Unlimited text | LONGTEXT |

Frappe defines 35+ fieldtypes; consult official Frappe fieldtype documentation for the full list.

### Quick Reference — Essential field properties

| Property | Type | Purpose |
|----------|------|---------|
| `reqd` | bool | Field is mandatory |
| `unique` | bool | Database UNIQUE constraint |
| `search_index` | bool | Database INDEX for faster queries |
| `in_list_view` | bool | Show in list view columns |
| `in_standard_filter` | bool | Show as filter in list view |
| `in_preview` | bool | Show in document preview |
| `allow_on_submit` | bool | Editable after submission |
| `read_only` | bool | Not editable by user |
| `hidden` | bool | Not visible on form |
| `depends_on` | str | Visibility condition (e.g. `eval:doc.status=="Active"`) |
| `mandatory_depends_on` | str | Conditional mandatory |
| `read_only_depends_on` | str | Conditional read-only |
| `fetch_from` | str | Auto-populate from linked doc (e.g. `customer.customer_name`) |
| `fetch_if_empty` | bool | Only fetch when field is empty |
| `options` | str | Fieldtype-specific (DocType name, select options, etc.) |
| `default` | str | Default value (supports `__user`, `Today`, etc.) |
| `description` | str | Help text below field |
| `collapsible` | bool | Section starts collapsed (Section Break only) |

### Naming rules

ALWAYS set `naming_rule` on the DocType. The `autoname` field holds the pattern.

| naming_rule value | autoname pattern | Example output |
|-------------------|------------------|----------------|
| Set by User | _(empty)_ | User types name manually |
| Autoincrement | _(empty)_ | `1`, `2`, `3` |
| By Fieldname | `field:{fieldname}` | Value of that field |
| By Naming Series | `naming_series:` | e.g. `INV-2024-00001` (from series field) |
| Expression | `PRE-.#####` | `PRE-00001`, `PRE-00002` |
| Expression (Old Style) | `{prefix}-{YYYY}-{#####}` | e.g. `INV-2024-00001` |
| Random | `hash` | Random 10-char string |
| UUID | _(empty)_ | UUID string |
| By Script | _(custom)_ | Controller `autoname()` decides |

NEVER rely on Autoincrement in production — gaps appear when records are deleted. Prefer Expression or Naming Series.

### ALWAYS / NEVER — Child table, single, tree, virtual

**Child tables:** On the parent, use `fieldtype` `Table` or `Table MultiSelect` with `options` set to the child DocType name. Child rows automatically get `parent`, `parenttype`, `parentfield`, and `idx` (1-based order). NEVER create a child DocType without `istable=1`. NEVER put a non–child-table DocType in a Table field’s `options`.

| Aspect | Table | Table MultiSelect |
|--------|-------|-------------------|
| UI | Full editable grid with "Add Row" | Tag-style picker, no "Add Row" |
| Child DocType | Full child with many fields | Often one Link field only |
| Use case | Line items, detail rows | Multi-select references |

**Single (`issingle=1`):** Data lives in `tabSingles` as key-value pairs, not a dedicated table per DocType. NEVER expect a list view. ALWAYS use for app-wide configuration (defaults, feature toggles, API keys).

**Tree (`is_tree=1`):** Frappe adds `lft`, `rgt`, `parent_*`, `old_parent`. ALWAYS define `parent_field` in the DocType JSON. NEVER manually edit `lft`/`rgt`; use `frappe.utils.nestedset.rebuild_tree()` if the tree is corrupted.

**Virtual (`is_virtual=1`):** No DB table. Implement persistence and list behavior in the controller (`db_insert`, `load_from_db`, `db_update`, `delete`, plus `get_list` / `get_count` / `get_stats` as needed). NEVER treat virtual data as normal `frappe.db.*` rows.

### Data masking (v16+)

Fields with `mask=1` hide sensitive values from users without mask permission at the field’s `permlevel`. Administrators still see unmasked values.

### Python type stub region

NEVER modify code between `# begin: auto-generated types` and `# end: auto-generated types` (Frappe `TypeExporter` output).

### Critical Rules

1. ALWAYS name DocTypes in **singular** form ("Sales Invoice", not "Sales Invoices").
2. ALWAYS remember the **tab** prefix — the database table is `tab` + DocType name.
3. NEVER exceed 140 characters for Data/Link/Select field values.
4. ALWAYS set `search_index=1` on fields used in frequent filters or `get_list` calls.
5. ALWAYS set `in_standard_filter=1` on fields users frequently filter by.
6. NEVER use `allow_on_submit=1` on child table fields that affect totals without recalculating those totals.
7. ALWAYS set `fetch_if_empty=1` alongside `fetch_from` unless you intend to overwrite user edits.
8. NEVER define `depends_on` with raw Python — use `eval:doc.fieldname == "value"` syntax.
