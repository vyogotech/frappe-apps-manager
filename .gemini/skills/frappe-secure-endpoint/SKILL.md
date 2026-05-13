---
name: frappe-secure-endpoint
description: Generate secure, tenant-aware API endpoints with authentication and tenant isolation.
---

# Generate Secure Endpoint

Create secure API endpoints with automatic authentication and tenant isolation.

## When to Use

- Creating custom API endpoints
- Need tenant-aware data access
- Implementing business logic beyond CRUD
- Creating aggregated endpoints

## Core Patterns

### 1. Basic Secure Endpoint

```python
@app.secure_route('/endpoint', methods=['GET'])
def handler(user):
    tenant_id = get_current_tenant_id()
    app.set_tenant_id(tenant_id)
    data = app.tenant_db.get_all('DocType', filters={...})
    return {"data": data}
```

### 2. POST with Validation

```python
@app.secure_route('/endpoint', methods=['POST'])
def create_handler(user):
    data = request.json
    if not data or not data.get('required_field'):
        return {"error": "required_field is required"}, 400
    
    tenant_id = get_current_tenant_id()
    app.set_tenant_id(tenant_id)
    
    try:
        frappe.db.begin()
        doc = app.tenant_db.insert_doc('DocType', data)
        app.tenant_db.commit()
        return {"success": True, "data": doc.as_dict()}, 201
    except Exception as e:
        app.tenant_db.rollback()
        return {"error": str(e)}, 500
```

### 3. GET with Query Parameters

```python
@app.secure_route('/endpoint', methods=['GET'])
def list_handler(user):
    tenant_id = get_current_tenant_id()
    app.set_tenant_id(tenant_id)
    
    page = int(request.args.get('page', 1))
    limit = int(request.args.get('limit', 20))
    status = request.args.get('status')
    
    filters = {'status': status} if status else {}
    data = app.tenant_db.get_all('DocType', filters=filters, limit_page_length=limit, limit_start=(page-1)*limit)
    return {"data": data, "page": page, "limit": limit}
```

### 4. PUT/DELETE

```python
@app.secure_route('/endpoint/<name>', methods=['PUT'])
def update_handler(user, name):
    tenant_id = get_current_tenant_id()
    app.set_tenant_id(tenant_id)
    
    doc = app.tenant_db.get_doc('DocType', name)
    doc.update(request.json)
    doc.save()
    app.tenant_db.commit()
    return {"success": True, "data": doc.as_dict()}

@app.secure_route('/endpoint/<name>', methods=['DELETE'])
def delete_handler(user, name):
    tenant_id = get_current_tenant_id()
    app.set_tenant_id(tenant_id)
    
    doc = app.tenant_db.get_doc('DocType', name)
    doc.delete()
    app.tenant_db.commit()
    return {"success": True}
```

## Key Patterns

1. Always use `@app.secure_route` (never `@app.route`)
2. Set tenant_id first with `app.set_tenant_id()`
3. Use `app.tenant_db` (never `frappe.db`)
4. Use transactions for multi-step operations
5. Return proper HTTP status codes
6. Validate input before processing

## Best Practices

- Always authenticate with `@app.secure_route`
- Set tenant_id before database operations
- Use tenant_db for all queries
- Handle errors gracefully
- Use transactions for multi-step operations

Remember: This skill is model-invoked. Claude will use it autonomously when detecting secure endpoint development needs.

## Decision Tree & Reference

*Condensed from `frappe-core-permissions` (Frappe_Claude_Skill_Package): Frappe-native access control aligns with secure, user-facing endpoints.*

### Permission decision tree

```
Need access control?
├── Who can CRUD/submit/etc. on DocType? → Role Permissions on DocType
├── Which concrete records visible? → User Permissions (record-level filters on Link targets)
├── Which fields readable/editable? → Perm Levels (permlevel ≥ 1; grant 0 before higher levels)
├── Field values masked [v16+]? → Field mask + grant `mask` on role rows
├── Custom deny-only logic? → has_permission hook
├── Narrow list/query results before return? → permission_query_conditions hook
└── One-off sharing? → frappe.share helpers

Checking in Python?
├── Decide allow/deny → frappe.has_permission(...) or doc.has_permission(ptype)
├── Enforce abort → frappe.has_permission(..., throw=True) or doc.check_permission(ptype)
├── System/batch bypass → ignore_permissions (comments required)
└── User-facing listings → frappe.get_list (NOT get_all)
```

### Quick reference tables

**Layers**

| Layer | Purpose |
|-------|---------|
| Role permissions | Capability per DocType/action |
| User permissions | Allowed Link values per user |
| Perm levels | Hide/split sensitive fields |
| Hooks | Extend/deny programmatically |
| Data masking | Obfuscate sensitive fields |

**permission_query_conditions vs get_list**

| API | Applies user perms | Applies query hook |
|-----|--------------------|---------------------|
| `frappe.get_list()` | Yes | Yes |
| `frappe.get_all()` | No | No |

Typical **`ptype`** checks include `read`, `write`, `create`, `delete`, `submit`, `cancel`, `amend`; **`select`** exists for Link access (v14+).

### ALWAYS / NEVER (permissions)

| ALWAYS | NEVER |
|--------|--------|
| Prefer **`frappe.has_permission(doctype, ptype, ...)`** for authorization — not raw role string checks alone. | Return **`True` from `has_permission` hooks** to “grant”; use **`None`** to defer to core rules. |
| Use **`frappe.get_list`** for responses shown to authenticated users unless you deliberately bypass hooks. | Return user-controlled SQL fragments **without escaping** (`frappe.db.escape` for hook WHERE parts). |
| Return **`False`/`None`** appropriately from **`has_permission`**; document **`ignore_permissions`**. | Raise **`frappe.throw` inside permission hooks** when denying — return **`False`** instead. |
| Grant **`permlevel 0`** before granting higher permlevels. For hooks that build WHERE: prefix **`tab{Doctype}`** columns safely. | Assume **data masking** protects **raw SQL** or Query Reports — mask manually where needed **[v16+]** |

### Hook anti-pattern cheat sheet

| Avoid | Prefer |
|-------|--------|
| `if "Role" in frappe.get_roles():` alone for gates | `frappe.has_permission(doctype, permtype)` |
| `frappe.get_all()` for filtered user data | `frappe.get_list()` |
| Concatenating unescaped `%`/`f-string` values into hook SQL snippets | `'owner = ' + frappe.db.escape(user)` |

### Precedence snapshot

Administrator → Role permissions → User permissions → `has_permission` denials → Sharing/`if_owner` refinements — plan checks so cumulative rules stay predictable.
