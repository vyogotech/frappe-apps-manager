---
name: frappe-workflow-generator
description: Generate Frappe Workflows for document state management and approvals. Use when creating approval workflows, state transitions, or multi-step document processes.
---

# Frappe Workflow Generator

Generate production-ready Frappe Workflows for document state management, approvals, and business process automation.

## When to Use This Skill

Claude should invoke this skill when:
- User wants to create approval workflows
- User needs document state transitions
- User requests multi-step approval processes
- User mentions workflows, approvals, or document states
- User wants role-based approval routing
- User needs to implement document lifecycle management

## Capabilities

### 1. Workflow JSON Generation

**Basic Approval Workflow:**
```json
{
  "name": "Sales Invoice Approval",
  "document_type": "Sales Invoice",
  "is_active": 1,
  "workflow_state_field": "workflow_state",
  "states": [
    {
      "state": "Draft",
      "doc_status": "0",
      "allow_edit": "Sales User",
      "update_field": "status",
      "update_value": "Draft"
    },
    {
      "state": "Pending Approval",
      "doc_status": "0",
      "allow_edit": "Sales Manager",
      "update_field": "status",
      "update_value": "Pending"
    },
    {
      "state": "Approved",
      "doc_status": "1",
      "update_field": "status",
      "update_value": "Approved"
    },
    {
      "state": "Rejected",
      "doc_status": "2",
      "update_field": "status",
      "update_value": "Rejected"
    }
  ],
  "transitions": [
    {
      "state": "Draft",
      "action": "Submit for Approval",
      "next_state": "Pending Approval",
      "allowed": "Sales User",
      "allow_self_approval": 0
    },
    {
      "state": "Pending Approval",
      "action": "Approve",
      "next_state": "Approved",
      "allowed": "Sales Manager"
    },
    {
      "state": "Pending Approval",
      "action": "Reject",
      "next_state": "Rejected",
      "allowed": "Sales Manager"
    },
    {
      "state": "Rejected",
      "action": "Revise",
      "next_state": "Draft",
      "allowed": "Sales User"
    }
  ]
}
```

### 2. Conditional Transitions

**Workflow with Amount-Based Routing:**
```json
{
  "transitions": [
    {
      "state": "Draft",
      "action": "Submit",
      "next_state": "Pending L1 Approval",
      "allowed": "Sales User",
      "condition": "doc.grand_total <= 10000"
    },
    {
      "state": "Draft",
      "action": "Submit",
      "next_state": "Pending L2 Approval",
      "allowed": "Sales User",
      "condition": "doc.grand_total > 10000 && doc.grand_total <= 50000"
    },
    {
      "state": "Draft",
      "action": "Submit",
      "next_state": "Pending Director Approval",
      "allowed": "Sales User",
      "condition": "doc.grand_total > 50000"
    }
  ]
}
```

## References

**Frappe Workflow Core:**
- Workflow: https://github.com/frappe/frappe/blob/develop/frappe/workflow/doctype/workflow/workflow.py
- Workflow State: https://github.com/frappe/frappe/blob/develop/frappe/workflow/doctype/workflow_state/workflow_state.py

**Official Documentation:**
- Workflows: https://frappeframework.com/docs/user/en/desk/workflows

## Decision Tree & Reference

### Decision tree — engine design (states, transitions, conditions)

```
Need workflow on a DocType?
├── Is DocType submittable?
│   ├── YES → States can use doc_status 0, 1, 2
│   └── NO  → ALL states MUST have doc_status = 0
├── Define states → Create Workflow State records first
├── Define transitions → Need Workflow Action Master records first
├── Who can edit in each state? → Set allow_edit per state
├── Need conditional transitions?
│   └── Use Python expressions with doc.field access (see conditions below)
├── Need to block self-approval?
│   └── Set allow_self_approval = 0 on specific transitions
└── Need email notifications?
    └── Set send_email_alert on Workflow + email templates on states
```

### Decision tree — implementation (approval pattern)

```
Starting a new workflow implementation?
├── What type of DocType?
│   ├── Submittable → doc_status can be 0, 1, 2
│   └── Non-submittable → ALL states must be doc_status = 0
├── How many approval levels?
│   ├── Single → Two-state: Draft → Approved
│   ├── Sequential → Chain: Draft → L1 → L2 → Approved
│   └── Conditional → Route by field values using transition conditions
├── Need self-approval blocking?
│   └── Set allow_self_approval = 0 on approval transitions
├── Need rejection/revision loop?
│   └── Add Reject (or equivalent) transition back to Draft or prior state
├── Need email notifications?
│   ├── Enable send_email_alert on Workflow
│   └── Link Email Template on each state (optional)
└── Need automated field updates?
    └── Use update_field + update_value on the target state row
```

**Routing logic:** use **workflow states and transitions** (with optional `condition` expressions)—not arbitrary controller code—for who may move the document and what the next state is. **Assignments** surface as **Workflow Action** rows for permitted roles; **`apply_workflow(doc, action)`** is how the engine applies a chosen transition—do **not** bypass the engine by manually toggling submit/cancel when the DocType is workflow-controlled.

### Quick reference — workflow record shape

```
Workflow DocType
├── states (Workflow Document State)
│   ├── state, doc_status (0 Draft / 1 Submitted / 2 Cancelled)
│   ├── allow_edit (Role), update_field / update_value, optional email fields
└── transitions
    ├── state, action → Workflow Action Master, next_state, allowed (Role)
    ├── allow_self_approval (default 1), condition (Python, optional)
    └── transition_tasks (v15+)
```

Key DocType-level fields (when defining in Desk or fixtures): only **one** active workflow per **document_type**; `workflow_state_field` (default `workflow_state`); `send_email_alert` for next-action emails.

### Quick reference — conditions (sandbox)

Expressions use `frappe.safe_eval()`. Typical globals: `frappe.db.get_value`, `frappe.db.get_list`, `frappe.session.user`, `frappe.utils` date helpers, and **`doc.<field>`** as a dict-like document reader.

Examples: `doc.grand_total > 50000`, `doc.department == "HR"`.

### ALWAYS / NEVER (workflow vs docstatus)

- **NEVER** call `doc.submit()` / `doc.cancel()` manually on workflow-controlled documents—the engine performs submit/cancel from state **doc_status** changes.
- **ALWAYS** keep docstatus transitions legal: mainly 0→0, 0→1, 1→1, 1→2; never from cancelled or submitted back to draft.
- **NEVER** activate a workflow without states that cover documents in draft (`docstatus=0`)—new docs need a valid initial state.
- For **non-submittable** DocTypes: **ALWAYS** set **every** state's `doc_status` to **0**.
- **NEVER** assign `doc_status = 1` to “intermediate” approval states—use `0` until the business step that should lock the doc as submitted.
- **NEVER** use `frappe.session.roles` inside conditions (**not** exposed); rely on **`doc`** and **`frappe.db` / **`frappe.session.user`**.
- **ALWAYS** use **`doc.fieldname`** syntax in `condition` strings.
- **Administrator** bypasses self-approval blocks; **`allow_self_approval = 0`** blocks the **document owner** from that transition (others with the role can still act).
