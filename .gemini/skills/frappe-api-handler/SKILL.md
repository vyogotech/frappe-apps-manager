---
name: frappe-api-handler
description: Generate whitelisted API methods and REST endpoints for standard Frappe and microservices.
---

# Generate Frappe API Handler

Create secure API endpoints for Frappe applications. Supports both standard Frappe and microservices.

## When to Use

- Creating custom API endpoints
- Building REST APIs
- Creating whitelisted methods
- Building microservice endpoints

## Core Patterns

### 1. Standard Frappe API

```python
@frappe.whitelist()
def get_customer_details(customer_name):
    if not frappe.has_permission("Customer", "read"):
        frappe.throw(_("Not permitted"), frappe.PermissionError)
    
    customer = frappe.get_doc("Customer", customer_name)
    return {
        "name": customer.name,
        "customer_name": customer.customer_name,
        "email": customer.email_id
    }

@frappe.whitelist(allow_guest=True)
def public_api():
    return {"message": "Public data"}
```

### 2. REST Patterns

**GET with pagination:**
```python
@frappe.whitelist()
def get_items(filters=None, limit=20, page=1):
    filters = frappe.parse_json(filters) if isinstance(filters, str) else filters or {}
    if not frappe.has_permission("Item", "read"):
        frappe.throw(_("Not permitted"), frappe.PermissionError)
    
    items = frappe.get_all("Item", filters=filters, limit=limit, limit_start=(page-1)*limit)
    return {"items": items, "total": frappe.db.count("Item", filters=filters)}
```

**POST:**
```python
@frappe.whitelist()
def create_order(order_data):
    data = frappe.parse_json(order_data) if isinstance(order_data, str) else order_data
    if not data.get("customer"):
        frappe.throw(_("Customer is required"))
    
    so = frappe.get_doc({"doctype": "Sales Order", **data})
    so.insert()
    return {"success": True, "name": so.name}
```

**PUT/DELETE:** Similar pattern - get doc, update/delete, return result

### 3. Microservice API

```python
@app.secure_route('/api/customers', methods=['GET'])
def list_customers(user):
    tenant_id = get_current_tenant_id()
    app.set_tenant_id(tenant_id)
    customers = app.tenant_db.get_all('Customer', filters=request.args.get('filters', {}))
    return {"data": customers}

@app.secure_route('/api/customers', methods=['POST'])
def create_customer(user):
    tenant_id = get_current_tenant_id()
    app.set_tenant_id(tenant_id)
    customer = app.tenant_db.insert_doc('Customer', request.json)
    return {"success": True, "data": customer.as_dict()}, 201
```

### 4. Error Handling

```python
@frappe.whitelist()
def api_with_errors(param):
    try:
        if not param:
            frappe.throw(_("Required"), frappe.ValidationError)
        return {"success": True, "data": process(param)}
    except frappe.ValidationError as e:
        return {"success": False, "error": str(e), "code": "VALIDATION_ERROR"}, 400
    except frappe.PermissionError as e:
        return {"success": False, "error": str(e), "code": "PERMISSION_ERROR"}, 403
    except frappe.DoesNotExistError as e:
        return {"success": False, "error": str(e), "code": "NOT_FOUND"}, 404
    except Exception as e:
        frappe.log_error(f"API error: {e}")
        return {"success": False, "error": "Internal error", "code": "INTERNAL_ERROR"}, 500
```

### 5. Authentication

**Session-based:**
```python
@frappe.whitelist()
def authenticated_api():
    return {"user": frappe.session.user}
```

**API Key:**
```python
@frappe.whitelist()
def api_key_auth():
    api_key = frappe.get_request_header("X-API-Key")
    if not api_key:
        frappe.throw(_("API Key required"), frappe.AuthenticationError)
    # Validate key
    return {"authenticated": True}
```

## Key Patterns

1. Always check permissions with `frappe.has_permission()`
2. Parse JSON strings with `frappe.parse_json()`
3. Return proper HTTP status codes
4. Validate input before processing
5. Use `app.tenant_db` in microservices
6. Log errors with `frappe.log_error()`

## Best Practices

- Use `@frappe.whitelist()` decorator
- Check permissions before operations
- Validate all input
- Use `frappe._()` for translatable messages
- Consistent response format
- Document with docstrings

Remember: This skill is model-invoked. Claude will use it autonomously when detecting API development tasks.

## Decision Tree & Reference

Cross-package reference from `frappe-core-api` and `frappe-syntax-whitelisted`: where to expose logic, how clients call Frappe, and rules that extend the patterns above.

### Decision tree: API surfaces (integrations & clients)

```
What do you need?
├── CRUD on documents (external client)
│   ├── v14: REST /api/resource/{doctype}
│   └── v15+: REST /api/v2/document/{doctype} (new) or /api/resource/ (still works)
│
├── Call custom server logic (external client)
│   └── RPC: POST /api/method/{dotted.path.to.function}
│
├── Notify external systems on document events
│   └── Webhooks (configured in UI or via DocType)
│
├── Client-side calls (JavaScript in Frappe desk)
│   ├── frappe.xcall() — async/await (RECOMMENDED)
│   └── frappe.call() — callback/promise pattern
│
└── Authentication method?
    ├── Server-to-server integration → Token Auth (RECOMMENDED)
    ├── Third-party app / mobile → OAuth 2.0
    ├── Browser session (short-lived) → Session/Cookie Auth
    └── Quick scripting / testing → Token Auth
```

### Decision tree: `@frappe.whitelist()` design

```
What kind of endpoint?
|
+-- Standalone API (utility, integration, dashboard)?
|   --> @frappe.whitelist() on a module-level function
|   --> Call via: frappe.call('myapp.api.function')
|   --> URL: /api/method/myapp.api.function
|
+-- Document-specific action?
|   --> @frappe.whitelist() on a Document class method
|   --> Call via: frm.call('method_name')
|   --> URL: /api/method/run_doc_method (internal)
|
+-- Server Script (no-code)?
    --> Use Server Script DocType instead (no decorator needed)

Who may call the API?
|
+-- Anyone (including guests)?
|   --> allow_guest=True + thorough input validation + rate limiting
|
+-- Logged-in users only?
    +-- Specific role? --> frappe.only_for("RoleName")
    +-- DocType-level? --> frappe.has_permission(doctype, ptype, throw=True)
    +-- Document-level? --> frappe.has_permission(doctype, ptype, doc, throw=True)

Which HTTP methods?
|
+-- Read only? --> methods=["GET"]
+-- Write only? --> methods=["POST"]
+-- Both? --> methods=["GET","POST"] or default
```

### Quick reference tables

Module-level RPC / Desk entrypoint: **`/api/method/{dotted.module.path.function_name}`** (returns JSON with `message` carrying the Python return value on success.)

| RPC decorator option | Effect | Notes |
|----------------------|--------|--------|
| `allow_guest=True` | No login required | ALWAYS tighten validation + consider `@rate_limit` |
| `xss_safe=True` | Skips XSS escaping | NEVER without fully trusted/sanitized output |
| `methods=[...]` | Limits HTTP verbs | e.g. `["POST"]` for mutations |
| `force_types=True` | [v15+] Require param annotations | Missing annotations → `FrappeTypeError` |

| REST operation | Method | v14 | v15+ (v2) |
|----------------|--------|-----|-----------|
| List | GET | `/api/resource/{doctype}` | `/api/v2/document/{doctype}` |
| Create | POST | `/api/resource/{doctype}` | `/api/v2/document/{doctype}` |
| Read | GET | `/api/resource/{doctype}/{name}` | `/api/v2/document/{doctype}/{name}` |
| Update | PUT | `/api/resource/{doctype}/{name}` | PATCH `/api/v2/document/{doctype}/{name}` |
| Delete | DELETE | `/api/resource/{doctype}/{name}` | DELETE `/api/v2/document/{doctype}/{name}` |

| Code | Typical meaning |
|------|-----------------|
| 200 | Success |
| 400 | Bad request / validation |
| 401 | Not authenticated |
| 403 | Authenticated but not permitted |
| 404 | Missing doc/resource |
| 417 | `frappe.throw` / expectation failed |
| 429 | Rate limited |
| 500 | Unhandled server error |

| `frappe.client` RPC (Desk / token) | Purpose |
|-------------------------------------|---------|
| `get_value`, `get_list`, `get` | Read |
| `insert`, `save`, `submit`, `cancel`, `delete` | Writes / workflow |
| `get_count` | Count with filters |

List query params clients often send: `fields`, `filters`, `or_filters`, `order_by`, `limit_start`, `limit_page_length` (`limit` alias on v15+), optional `debug`.

### ALWAYS / NEVER (additive — extends Key Patterns above)

- **ALWAYS** send **`Accept: application/json`** when calling Frappe REST from scripts or services (otherwise responses may be HTML).
- **ALWAYS** use **parameterized** DB access — **NEVER** build SQL by interpolating user input.
- **ALWAYS** set a **timeout** (e.g. `timeout=30`) on outbound `requests` to third parties.
- **ALWAYS** keep secrets in **`frappe.conf` or environment variables** — **NEVER** hardcode keys in repo.
- **ALWAYS** **paginate** list-style API responses intended for arbitrary-sized data.
- **ALWAYS** **verify webhook HMAC** (`X-Frappe-Webhook-Signature`) when exposing inbound webhook receivers.
- **NEVER** use **`allow_guest=True`** on endpoints that change data or privileged state without extra gates (validation + rate limit + minimal surface).
- **NEVER** **log credentials** or PCI/secret-bearing payloads.
- **NEVER** use **Administrator API keys** for integrations — dedicate least-privilege API users.
- **NEVER** rely on **`@frappe.whitelist()`** alone for authorization — treat login as authentication only; still enforce **`frappe.has_permission` / `frappe.only_for`** as needed (see **Key Patterns** above).
- **NEVER** return raw **stack traces** to API clients — use **`frappe.log_error`** and a safe user-facing message.
- **NEVER** use **`ignore_permissions=True`** without an explicit preceding **role/security guard**.
- **ALWAYS** apply **`@rate_limit`** on **guest-visible** endpoints to reduce abuse.

### Critical Rules (sources — condensed)

From **frappe-core-api**: prefer token auth for integrations; store API secrets immediately when generated (shown once); session cookies expire (~3 days) — not for long-lived integrations; set Webhook secrets; use Jinja2 conditions on webhook conditions; outbound integration calls need timeouts and safe credential storage.

From **frappe-syntax-whitelisted**: HTTP parameters arrive as strings — coerce types and **`frappe.parse_json`** for JSON blobs; Desk callers should **`JSON.stringify`** complex `frappe.call` args; **`frappe.form_dict`** for dynamic param maps; **[v15+]** optional **`force_types`** and site hook **`require_type_annotated_api_methods`** enforce annotations; **`frappe.local.response["http_status_code"]`** for non-default RPC HTTP status where applicable.
