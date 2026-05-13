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

## Decision Tree & Reference

Source skill: **`frappe-impl-clientscripts`** (Frappe Claude Skill Package workspace). Condensed workflows: client vs server, event choice, hardened rules, and pitfalls called out there.

### Client vs server (must logic always run—API/import/console?)

```
MUST the logic ALWAYS run (imports, API, bulk import, bench console)?
├── YES → implement on the server (controller / server script)
└── NO → goal-based split
         ├── UX / instant feedback → client script
         ├── Show-hide / dynamic DF → client script
         ├── Link filtering → client script
         ├── Data validation → BOTH (client UX + server integrity)
          └── Derived numbers → mirror on client when helpful, reconcile on server if business-critical
```

### Choose the right form event

```
Need → handler
├── Link filters                     → setup (runs once earliest)
├── Custom buttons                   → refresh (rebuilt each render)
├── Show/hide / mandatory toggles    → refresh **and** {fieldname} (initial + interactive)
├── Block bad saves                  → validate (frappe.throw)
├── Follow-up once saved             → after_save
├── Recalculate on edits             → {fieldname}
├── Grid row lifecycle               → {table}_add / {table}_remove / child field handlers
├── One-shot init before data render → setup **or** onload (see syntax skill for nuance)
└── Needs fully rendered DOM         → onload_post_render
```

### Server-call decision tree

```
├── Single field lookup on one doc → frappe.db.get_value (promise; light)
├── Method on current document     → frm.call (controller must be @frappe.whitelist)
├── Any other whitelisted function → frappe.call ({ method, args }) → inspect r.message
└── Prefer promise-only ergonomics → frappe.xcall (same whitelist rules)
```

Performance guardrails (`frappe-impl-clientscripts`):

| Rule | Rationale |
|------|-----------|
| `set_query` only in `setup` | Avoid duplicate registration each refresh |
| Batch `frm.set_value({ ... })` | Fewer redraw passes |
| Cache heavy reads | e.g., `frm._cache_key = …` rather than repeating calls |
| NEVER server calls inside tight loops without batching | Prefer one batched whitelist method + map |

### ALWAYS / NEVER (workflow level)

- ALWAYS treat client validation as UX—pair with authoritative server checks whenever data integrity matters.
- ALWAYS migrate **UI > Client Script UI** workflows to `hooks.py → doctype_js` when scripts exceed ~50 lines, need CI, multi-site deploy, or team review.
- For conditional visibility/requirements, ALWAYS combine `refresh` (initial paint) **and** the driving `{fieldname}` handler **and** optionally `frm.trigger('field')` from `refresh` to sync startup state—never rely on only one of them.
- ALWAYS clear dependent Link fields after their parent filters change (`frm.set_value('child_link', '')`).
- ALWAYS use `flt()` for arithmetic on Doc values to absorb `null`/undefined safely.
- ALWAYS recalculate totals on `{table}_remove`, not only on field edits.
- NEVER rely on `frappe.msgprint` alone to abort saves—call `frappe.throw` (or validated async awaited checks) inside `validate` when persistence must stop (`frappe.validated = false` is brittle vs throw).
- NEVER add transactional buttons inside `setup`/`onload`—`refresh` is where UI chrome is reconstructed.
- NEVER block `validate` with slow server hops unless UX expectations are set (`async validate` still waits user-facing latency).
- ALWAYS `await` networked checks in `validate`; letting callbacks finish later means the doc may already save.

Custom-button workflow rules:

| ALWAYS | NEVER |
|--------|-------|
| Re-add buttons in `refresh` | Define action buttons purely in `setup`/`onload` |
| Check `frm.is_new()` plus `docstatus` | Offer actions that assume a persisted name without guards |
| Wrap labels via `__()` | Ship English-only literals |

### Anti-patterns (from impl guidance)

These are shorthand “what bites teams” distilled from workflow sections—see `frappe-syntax-clientscripts` for fuller API pitfalls.

| Pitfall | Why it fails |
|---------|---------------|
| Only `refresh` **or** only `{fieldname}` visibility toggles | Form loads stale or skips live edits |
| `set_query` in `refresh` | Re-registers unnecessarily; violates perf guidance |
| `refresh_field('items')` inside per-row loops after every `frappe.model.set_value` during bulk edits | Repeated grid renders—touch rows then refresh once unless framework auto-handles |
| Unguarded `frm.add_custom_button` | Duplicate buttons or actions on unsubmitted drafts/cancelled docs |
| `validate` firing `frappe.call` via callback stack | Race lets save slip through |
| Long client scripts stranded in Desk | No review history / environment parity |
| Clearing totals without `{table}_remove` hook | Row deletions silently desync aggregates |
