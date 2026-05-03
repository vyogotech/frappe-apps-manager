---
name: frappe-dashboard-builder
description: Create and configure Frappe Dashboards, Dashboard Charts, Number Cards, and custom analytical pages for data visualization.
---

# Frappe Dashboard Builder

Frappe provides a built-in engine for creating real-time analytical widgets. These are typically composed of **Number Cards** (single metrics) and **Dashboard Charts** (graphs/plots), which are then aggregated into a **Dashboard**. For more complex requirements, the **Page API** can be used to build fully custom dashboards.

## Core Patterns

### 1. Standard Dashboard (`Dashboard` DocType)

A Dashboard is a collection of charts and cards.

**File Path:** `[app_name]/[module_name]/dashboard/[dashboard_name]/[dashboard_name].json`

```json
{
  "doctype": "Dashboard",
  "name": "Management Dashboard",
  "dashboard_name": "Management Dashboard",
  "module": "My App",
  "is_standard": 1,
  "charts": [
    { "chart": "Monthly Signups" }
  ],
  "cards": [
    { "card": "Active Subscriptions" }
  ]
}
```

### 2. Number Cards (`Number Card` DocType)

Used for displaying a single value with optional percentage change.

**File Path:** `[app_name]/[module_name]/number_card/[card_name]/[card_name].json`

```json
{
  "doctype": "Number Card",
  "name": "Active Subscriptions",
  "label": "Active Subscriptions",
  "document_type": "Subscription",
  "function": "Count",
  "is_standard": 1,
  "module": "My App",
  "filters_json": "[[\"Subscription\",\"status\",\"=\",\"Active\"]]"
}
```

### 3. Dashboard Charts (`Dashboard Chart` DocType)

Used for time-series, bar, pie, or percentage charts.

**File Path:** `[app_name]/[module_name]/dashboard_chart/[chart_name]/[chart_name].json`

```json
{
  "doctype": "Dashboard Chart",
  "name": "Monthly Signups",
  "chart_name": "Monthly Signups",
  "chart_type": "Trend",
  "document_type": "User",
  "based_on": "creation",
  "timespan": "Last Year",
  "time_interval": "Monthly",
  "type": "Line",
  "module": "My App",
  "is_standard": 1,
  "filters_json": "[]"
}
```

### 4. Custom Page Analytics (Page API)

For highly dynamic dashboards that require custom logic.

```javascript
frappe.pages['my-dashboard'].on_page_load = function(wrapper) {
    let page = frappe.ui.make_app_page({
        parent: wrapper,
        title: 'Management Dashboard',
        single_column: true
    });

    // Add Chart container
    let chart_container = $('<div id="my-chart"></div>').appendTo(page.main);

    // Render Chart using Frappe Charts
    let chart = new frappe.Chart('#my-chart', {
        title: 'Sales Trend',
        data: {
            labels: ['Week 1', 'Week 2', 'Week 3'],
            datasets: [{ values: [100, 250, 180] }]
        },
        type: 'line',
        height: 250
    });
};
```

## Best Practices

- **Standardization**: Set `is_standard: 1` to ensure analytical widgets are saved as files in your repository.
- **Filters**: Use the stringified JSON array format `"[[\"Field\", \"=\", \"Value\"]]"` for filters.
- **Native-First**: Always prefer the standard Dashboard engine before resorting to custom Pages.
- **Link to Workspace**: Include your created charts/cards in the corresponding `Workspace` for unified access.

## References
- Page API: https://frappeframework.com/docs/user/en/desk/pages
- Frappe Charts: https://frappe.io/charts
- Dashboards: https://frappeframework.com/docs/user/en/desk/dashboards
