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
