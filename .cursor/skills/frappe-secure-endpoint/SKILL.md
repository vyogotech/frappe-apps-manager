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

## How secure_route Works

`@app.secure_route` is a decorator that wraps your view with:
1. **Session validation**: OAuth2 Bearer, SID cookie, X-Frappe-SID, X-Internal-Token, or DB fallback
2. **User sync**: Sets `frappe.session.user` to the validated user
3. **Tenant resolution**: Calls `get_user_tenant_id(username)` and stores in `g.tenant_id`
4. **User injection**: Passes `username` as the first argument to your function
5. **Auto-jsonify**: Dict returns are auto-serialized (handles timedelta, Decimal, etc.)
6. **Error handling**: Catches Frappe exceptions and returns proper HTTP status codes

You do NOT need to manually call `get_current_tenant_id()` or `app.set_tenant_id()`.

## Core Patterns

### 1. Basic GET Endpoint

```python
@app.secure_route('/api/orders', methods=['GET'])
def list_orders(user):
    """user and g.tenant_id are automatically set."""
    orders = app.tenant_db.get_all(
        'Sales Order',
        filters={'status': request.args.get('status')},
        fields=['name', 'customer', 'grand_total', 'status'],
        limit_page_length=int(request.args.get('limit', 20)),
        limit_start=int(request.args.get('offset', 0)),
        order_by='modified desc'
    )
    return {"data": orders}
```

### 2. POST with Validation

```python
@app.secure_route('/api/orders', methods=['POST'])
def create_order(user):
    data = request.json
    if not data or not data.get('customer'):
        return {"error": "customer is required"}, 400

    doc = app.tenant_db.insert_doc('Sales Order', data)
    return {"name": doc.name, "status": doc.status}, 201
```

No manual commit needed -- after_request middleware auto-commits.

### 3. PUT / DELETE

```python
@app.secure_route('/api/orders/<name>', methods=['PUT'])
def update_order(user, name):
    data = request.json
    if not data:
        return {"error": "Request body required"}, 400
    doc = app.tenant_db.update_doc('Sales Order', name, data)
    return {"name": doc.name, "status": doc.status}

@app.secure_route('/api/orders/<name>', methods=['DELETE'])
def delete_order(user, name):
    app.tenant_db.delete_doc('Sales Order', name)
    return {"success": True}
```

### 4. Aggregation Endpoint

```python
@app.secure_route('/api/dashboard', methods=['GET'])
def dashboard(user):
    return {
        "total_orders": app.tenant_db.count('Sales Order'),
        "draft_orders": app.tenant_db.count('Sales Order', filters={'status': 'Draft'}),
        "total_revenue": app.tenant_db.get_value(
            'Sales Order', {'docstatus': 1}, 'sum(grand_total)'
        ) or 0
    }
```

### 5. Multi-Step Transaction

```python
@app.secure_route('/api/submit-order/<name>', methods=['POST'])
def submit_order(user, name):
    order = app.tenant_db.get_doc('Sales Order', name)
    if order.status != 'Draft':
        return {"error": "Only draft orders can be submitted"}, 400

    order.status = 'Submitted'
    order.save()

    for item in order.items:
        app.tenant_db.update_doc('Item', item.item_code, {
            'reserved_qty': item.qty
        })

    return {"name": order.name, "status": order.status}
```

If any exception occurs, `secure_route` auto-rolls back and returns the appropriate error.

### 6. Service-to-Service Call

```python
# Calling service uses X-Internal-Token header
import requests
resp = requests.post(
    'http://orders-service:8000/api/orders',
    json={"customer": "CUST-001"},
    headers={"X-Internal-Token": os.getenv("INTERNAL_SERVICE_TOKEN")}
)
```

The receiving service treats this as Administrator (no tenant_id resolution).

### 7. Central Site Client

```python
@app.secure_route('/api/user-profile', methods=['GET'])
def get_profile(user):
    user_doc = app.central.get_doc('User', user)
    return {"full_name": user_doc.get('full_name'), "email": user}
```

## Error Handling by secure_route

| Exception | HTTP Status | Response type |
|-----------|------------|---------------|
| `frappe.PermissionError` / `frappe.AuthenticationError` | 403 | PermissionError |
| `frappe.DoesNotExistError` / `frappe.LinkValidationError` | 404 | DoesNotExistError |
| `frappe.ValidationError` / `ValueError` / `TypeError` / `KeyError` | 400 | Validation error |
| Any other `Exception` | 500 | Internal error |

All errors auto-rollback the DB transaction. No manual try/except needed for standard cases.

## Key Rules

1. Always use `@app.secure_route` (never `@app.route` for data endpoints)
2. Don't manually set tenant_id -- `secure_route` handles it
3. Don't manually commit -- after_request middleware handles it
4. Use `app.tenant_db` for all data access (never `frappe.db`)
5. Return dicts -- they're auto-jsonified with proper encoding
6. Use proper HTTP status codes in tuples: `return {"data": ...}, 201`

## Public Endpoints

For unauthenticated endpoints (health checks, webhooks), use `@app.route`:
```python
@app.route('/webhook', methods=['POST'])
def webhook():
    return {"received": True}
```

Remember: This skill is model-invoked. Claude will use it autonomously when detecting secure endpoint development needs.
