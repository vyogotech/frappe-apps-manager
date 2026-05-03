---
name: frappe-client-script-logic
description: Implement dynamic form behavior, field dependencies, and client-side validations in Frappe using JavaScript. Use for interactive UI logic within DocTypes.
---

# Frappe Client Script Logic

Handle dynamic UI interactions, field visibility, and complex client-side validations.

## Capabilities

### 1. Conditional Visibility & Requirements

**Pattern: Dynamic Field Toggles**
```javascript
// Pattern: payment_entry.js
frappe.ui.form.on('Payment Entry', {
    payment_type: function(frm) {
        let is_receive = frm.doc.payment_type === 'Receive';
        let is_pay = frm.doc.payment_type === 'Pay';
        let is_transfer = frm.doc.payment_type === 'Internal Transfer';

        // Toggle visibility based on state
        frm.toggle_display('paid_from', is_pay || is_transfer);
        frm.toggle_display('paid_to', is_receive || is_transfer);

        // Toggle required status dynamically
        frm.toggle_reqd('paid_from', is_pay);
        frm.toggle_reqd('paid_to', is_receive);
    }
});
```

### 2. Smart Defaults & Auto-Fill

**Pattern: Data Fetching on Change**
```javascript
frappe.ui.form.on('Sales Invoice', {
    customer: function(frm) {
        if (frm.doc.customer) {
            frappe.call({
                method: 'erpnext.accounts.party.get_party_details',
                args: {
                    party: frm.doc.customer,
                    party_type: 'Customer'
                },
                callback: function(r) {
                    if (r.message) {
                        frm.set_value('customer_name', r.message.customer_name);
                        frm.set_value('territory', r.message.territory);
                    }
                }
            });
        }
    }
});
```

### 3. Client-Side Validation

```javascript
frappe.ui.form.on('My DocType', {
    validate: function(frm) {
        if (frm.doc.start_date > frm.doc.end_date) {
            frappe.msgprint(__('Start Date cannot be after End Date'));
            frappe.validated = false;
        }
    }
});
```

## References
- Client Scripts: https://frappeframework.com/docs/user/en/desk/scripting/client-script
- Form Events: https://frappeframework.com/docs/user/en/api/form
