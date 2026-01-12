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
