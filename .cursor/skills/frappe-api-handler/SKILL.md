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

### 2. Microservice Auto-CRUD (Recommended)

```python
# Generates all CRUD endpoints automatically:
app.register_resource("Sales Order")
# GET    /api/resource/Sales Order        → list (paginated, filterable)
# POST   /api/resource/Sales Order        → create
# GET    /api/resource/Sales Order/<name>  → get one
# PUT    /api/resource/Sales Order/<name>  → update
# DELETE /api/resource/Sales Order/<name>  → delete

# With custom handlers for specific operations:
app.register_resource("Sales Order", custom_handlers={
    'list': my_custom_list,
    'post': my_custom_create,
})
```

All register_resource endpoints are secured, tenant-scoped, and have Swagger docs.

### 3. Microservice Custom Endpoints

```python
@app.secure_route('/api/customers', methods=['GET'])
def list_customers(user):
    """user and g.tenant_id set automatically by secure_route."""
    status = request.args.get('status')
    filters = {'status': status} if status else {}
    customers = app.tenant_db.get_all('Customer', filters=filters)
    return {"data": customers}

@app.secure_route('/api/customers', methods=['POST'])
def create_customer(user):
    data = request.json
    if not data or not data.get('customer_name'):
        return {"error": "customer_name is required"}, 400
    doc = app.tenant_db.insert_doc('Customer', data)
    return {"name": doc.name}, 201

@app.secure_route('/api/customers/<name>', methods=['PUT'])
def update_customer(user, name):
    data = request.json
    if not data:
        return {"error": "Request body required"}, 400
    doc = app.tenant_db.update_doc('Customer', name, data)
    return {"name": doc.name}

@app.secure_route('/api/customers/<name>', methods=['DELETE'])
def delete_customer(user, name):
    app.tenant_db.delete_doc('Customer', name)
    return {"success": True}
```

### 4. Error Handling

Standard Frappe:
```python
@frappe.whitelist()
def api_with_errors(param):
    try:
        if not param:
            frappe.throw(_("Required"), frappe.ValidationError)
        return {"success": True, "data": process(param)}
    except frappe.ValidationError:
        raise
    except Exception as e:
        frappe.log_error(f"API error: {e}")
        return {"success": False, "error": "Internal error"}, 500
```

Microservice (automatic via secure_route):
```python
@app.secure_route('/api/process', methods=['POST'])
def process(user):
    # secure_route auto-handles these exceptions:
    # PermissionError → 403
    # DoesNotExistError → 404
    # ValidationError/ValueError → 400
    # Any other Exception → 500 (with auto-rollback)
    doc = app.tenant_db.get_doc('Sales Order', request.json['name'])
    doc.status = 'Processed'
    doc.save()
    return {"status": doc.status}
```

### 5. Authentication Methods

**Microservice -- secure_route (automatic):**
```python
@app.secure_route('/api/data', methods=['GET'])
def get_data(user):
    # Auth handled: Bearer token, SID cookie, X-Internal-Token
    return {"user": user, "data": app.tenant_db.get_all('DocType')}
```

**Service-to-service:**
```python
# Caller
import requests
resp = requests.get(
    'http://orders-service:8000/api/orders',
    headers={"X-Internal-Token": os.getenv("INTERNAL_SERVICE_TOKEN")}
)

# Central Site client (built-in)
user = app.central.get_doc('User', 'admin@example.com')
users = app.central.get_list('User', filters={'enabled': 1})
result = app.central.call('frappe.client.get_count', {'doctype': 'User'})
```

### 6. Pagination (register_resource)

List endpoints from `register_resource` support Frappe-style query params:
- `fields` -- comma-separated fields to return
- `limit` / `limit_page_length` -- page size (default 20)
- `offset` / `limit_start` -- row offset
- `order_by` -- sort order (default: `modified desc`)
- All other query params become `filters`

```
GET /api/resource/Sales Order?status=Draft&limit=10&offset=20&order_by=name asc
```

## Key Patterns

1. Use `register_resource()` for standard CRUD (don't write manual endpoints)
2. Use `@app.secure_route` for custom business logic endpoints
3. Let `secure_route` handle auth, tenant, errors, and commits
4. Use `app.tenant_db` for all data access
5. Return dicts -- auto-serialized with proper type handling
6. Standard Frappe: Use `@frappe.whitelist()` + permission checks

## Best Practices

- Prefer `register_resource()` over manual CRUD endpoints
- Use `@app.secure_route` for authenticated endpoints
- Use `@app.route` only for public endpoints (health, webhooks)
- Validate input before processing (`request.json`)
- Use proper HTTP status codes (201 for create, 400 for bad input)
- Log important operations via `app.logger`

Remember: This skill is model-invoked. Claude will use it autonomously when detecting API development tasks.
