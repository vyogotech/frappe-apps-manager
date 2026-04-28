---
name: frappe-dashboard-builder
description: Create and configure Frappe Dashboards, Dashboard Charts, and Number Cards for data visualization and analytics.
---

# Frappe Dashboard Builder

Frappe provides a built-in engine for creating real-time analytical widgets. These are typically composed of **Number Cards** (single metrics) and **Dashboard Charts** (graphs/plots), which are then aggregated into a **Dashboard**.

## When to Use

- Adding analytical visibility to a custom app.
- Monitoring key performance indicators (KPIs).
- Visualizing trends (sales, signups, logs) in Workspaces.

## Core Patterns

### 1. Dashboard (`Dashboard` DocType)

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

### 4. Filters JSON Format

Frappe uses a specific strict array format for filters in analytical widgets.

**Formats:**
- `[field, value]` (Implies `=`)
- `[field, operator, value]`
- `[doctype, field, operator, value]`

**Example:**
`"[[\"Customer\", \"disabled\", \"=\", 0], [\"Customer\", \"customer_group\", \"=\", \"Individual\"]]"`

## Key Requirements

1. **`is_standard: 1`**: Essential for saving these objects as files in your app directory.
2. **`filters_json`**: Must be a stringified JSON array. Double-check escape characters if writing manually.
3. **Module**: Ensure the `module` field matches your custom app's module name.

## Best Practices

- **Meaningful Labels**: Use clear, concise labels for cards and charts.
- **Time Intervals**: Choose appropriate intervals (Daily/Weekly/Monthly) based on the expected volume of data.
- **Colors**: Use the `color` field in Dashboard Charts to differentiate data series.
- **Link to Workspace**: Always include your created charts/cards in the corresponding `Workspace` content for maximum visibility.
