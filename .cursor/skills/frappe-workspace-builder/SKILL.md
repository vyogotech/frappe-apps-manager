---
name: frappe-workspace-builder
description: Generate and configure Frappe Workspace 2.0 definitions, including layout content (shortcuts, cards, charts) and sidebar links.
---

# Frappe Workspace Builder

Workspaces are the primary landing pages for modules in Frappe. In version 14+, they use "Workspace 2.0," which defines layouts using a structured JSON content array.

## When to Use

- Creating a new module landing page.
- Organizing links, shortcuts, and analytical widgets for users.
- Configuring "Quick Lists" and onboarding flows.

## Core Patterns

### 1. Workspace JSON Structure

Standard workspaces are stored in the `workspace` directory of your module.

**File Path:** `[app_name]/[module_name]/workspace/[workspace_name]/[workspace_name].json`

```json
{
  "doctype": "Workspace",
  "name": "My Custom App",
  "title": "My Custom App",
  "module": "My App",
  "public": 1,
  "is_standard": 1,
  "roles": [
    { "role": "System Manager" }
  ],
  "sequence_id": 1,
  "icon": "home",
  "content": "[]",
  "links": []
}
```

### 2. Layout Content (`content` array)

The `content` field is a JSON string containing blocks. Common block types include:

| Type | Data Properties |
| :--- | :--- |
| **header** | `text`, `level` (1-6), `col` (1-12) |
| **shortcut** | `shortcut_name` (Link to DocType/Report/Page), `col` |
| **card** | `card_name` (Label for group), `col` |
| **chart** | `chart_name` (Link to Dashboard Chart), `col` |
| **spacer** | `col` |

**Example `content` string (formatted for readability):**
```json
[
  {
    "type": "header",
    "data": { "text": "Your Shortcuts", "level": 4, "col": 12 }
  },
  {
    "type": "shortcut",
    "data": { "shortcut_name": "Sales Order", "col": 4 }
  },
  {
    "type": "card",
    "data": { "card_name": "Masters", "col": 4 }
  }
]
```

### 3. Sidebar Links (`links` array)

The `links` array defines the vertical navigation sidebar.

```json
"links": [
  {
    "label": "Master Data",
    "type": "Card Break",
    "link_count": 0
  },
  {
    "label": "Customers",
    "link_to": "Customer",
    "link_type": "DocType",
    "type": "Link",
    "link_count": 0
  }
]
```

## Key Requirements

1. **`public: 1`**: Ensures the workspace is available to all users with the specified roles.
2. **`is_standard: 1`**: Essential for saving the workspace as a file in your app directory.
3. **Roles**: Always define access roles to prevent unauthorized access.
4. **Column Grid**: The workspace layout uses a 12-column grid system. Use the `col` property (e.g., `4` for 1/3 width, `12` for full width).

## Best Practices

- **Group logically**: Use `Card Break` and headers to separate functional areas.
- **Onboarding**: Use `onboard: 1` on links to guide users through initial setup.
- **Analytical Value**: Always include at least one `Dashboard Chart` or `Number Card` in the `content` for data visibility.
