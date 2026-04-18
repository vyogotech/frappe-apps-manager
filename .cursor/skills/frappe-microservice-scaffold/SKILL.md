---
name: frappe-microservice-scaffold
description: Generate complete microservice boilerplate with tenant isolation, Containerfile, and entrypoint.
---

# Scaffold Frappe Microservice

Generate complete, production-ready Frappe microservice following frappe-microservice-lib patterns.

## When to Use

- Creating new microservice from scratch
- Need complete service structure
- Setting up tenant-aware endpoints
- Implementing multi-tenant isolation

## Core Patterns

### 1. Service Structure

```python
from frappe_microservice import create_microservice

def get_current_tenant_id():
    from flask import g
    from frappe_microservice import get_user_tenant_id
    
    if hasattr(g, 'tenant_id') and g.tenant_id:
        return g.tenant_id
    
    if hasattr(g, 'current_user') and g.current_user:
        user_email = g.current_user
        if user_email in ('Guest', 'Administrator'):
            return None
        tenant_id = get_user_tenant_id(user_email)
        if tenant_id:
            g.tenant_id = tenant_id
            return tenant_id
    return None

app = create_microservice(
    "service-name",
    get_tenant_id_func=get_current_tenant_id,
    load_framework_hooks=['frappe', 'erpnext']
)
```

### 2. Resource API

```python
# Auto CRUD endpoints
app.register_resource("DocType Name")
# Creates: GET, POST, GET/{name}, PUT/{name}, DELETE/{name}
```

### 3. Secure Endpoints

```python
@app.secure_route('/endpoint', methods=['GET'])
def handler(user):
    tenant_id = get_current_tenant_id()
    app.set_tenant_id(tenant_id)
    data = app.tenant_db.get_all('DocType', filters={...})
    return {"data": data}
```

### 4. Tenant-Aware Database

```python
# ✅ Good - automatic tenant filtering
app.tenant_db.get_all('DocType', filters={...})
app.tenant_db.get_doc('DocType', name)
app.tenant_db.insert_doc('DocType', data)

# ❌ Bad - no tenant isolation
frappe.db.get_all('DocType', filters={...})
```

### 5. Containerfile

```dockerfile
FROM frappe-microservice-base:latest
WORKDIR /app
COPY . /app/service/
RUN ln -s /app/service/entrypoint.py /app/entrypoint.py
EXPOSE 8000
CMD ["/opt/venv/bin/python", "/app/service/entrypoint.py"]
```

### 6. Entrypoint

```python
import sys
sys.path.insert(0, '/app/service')
from server import app
from frappe_microservice.entrypoint import run_app

if __name__ == '__main__':
    run_app(app)
```

## File Structure

```
<service-name>-service/
├── server.py
├── Containerfile
├── entrypoint.py
├── requirements.txt (optional)
├── controllers/ (optional)
└── tests/ (optional)
```

## Key Patterns

1. **Tenant Resolution**: Implement `get_current_tenant_id()`
2. **Database**: Use `app.tenant_db` exclusively
3. **Authentication**: Use `@app.secure_route`
4. **Error Handling**: Return proper HTTP status codes
5. **Transactions**: Use `frappe.db.begin()` and `app.tenant_db.commit()`

## Best Practices

- Always set tenant_id before database operations
- Use `app.tenant_db` for all queries
- Handle errors gracefully
- Use transactions for multi-step operations
- Log important operations

## Reference

**Example Services**: See `frappe_ms_poc/orders-service/server.py` and `frappe_ms_poc/signup-service/server.py`

Remember: This skill is model-invoked. Claude will use it autonomously when detecting microservice scaffolding needs.
