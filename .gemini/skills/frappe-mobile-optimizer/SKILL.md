---
name: frappe-mobile-optimizer
description: Optimize Frappe applications for mobile devices and touch interfaces. Use when ensuring responsiveness and mobile-first usability.
---

# Frappe Mobile Optimizer

Ensure Frappe applications are responsive, touch-friendly, and performant on mobile devices.

## Capabilities

### 1. Responsive Grid Handling

```javascript
// Stack grid columns on mobile screens
frappe.ui.form.on('Sales Invoice', {
    refresh: function(frm) {
        if ($(window).width() < 768) {
            frm.fields_dict.items.grid.wrapper
                .find('.grid-body')
                .addClass('mobile-grid');
        }
    }
});
```

### 2. Touch-Friendly Targets

- **Button Sizing**: Use larger padding and font sizes for primary action buttons on mobile.
- **Viewport Management**: Utilize `dvh` units and safe-area insets for custom pages.
- **Gesture Support**: Implement swipe-to-delete or pull-to-refresh patterns where appropriate using native browser capabilities or standard JS libraries.

## References
- Responsive Design: https://frappeframework.com/docs/user/en/desk/forms/layouts#mobile-view
- Mobile App: https://frappeframework.com/docs/user/en/mobile
