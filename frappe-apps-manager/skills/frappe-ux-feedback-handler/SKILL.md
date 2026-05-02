---
name: frappe-ux-feedback-handler
description: Implement user feedback mechanisms in Frappe, including alerts, progress bars, and modal dialogues. Use to improve communication between the system and the user.
---

# Frappe UX Feedback Handler

Provide clear, timely, and non-intrusive feedback to users during long-running tasks or state changes.

## Capabilities

### 1. Alert Notifications

```javascript
// Success alert (disappears after 5s)
frappe.show_alert({
    message: __('Action completed successfully'),
    indicator: 'green'
}, 5);

// Error alert (persistent for 10s)
frappe.show_alert({
    message: __('Something went wrong'),
    indicator: 'red'
}, 10);
```

### 2. Progress Tracking

```javascript
// Show a progress bar for background processes
frappe.show_progress(__('Importing Data...'), 45, 100, 'Processing row 45/100');

// Hide progress when done
// frappe.hide_progress();
```

### 3. Confirmation Dialogues

```javascript
frappe.confirm(
    'Are you sure you want to proceed with this bulk action?',
    () => {
        // action to perform if Yes is clicked
    },
    () => {
        // action to perform if No is clicked
    }
);
```

## References
- Dialog API: https://frappeframework.com/docs/user/en/api/dialog
- Notifications: https://frappeframework.com/docs/user/en/api/ui#frappeui-notifications
