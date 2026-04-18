---
name: Validate Microservice Code
description: Validate code follows frappe-microservice-lib patterns, security best practices, and framework conventions.
---

# Validate Microservice Code

Check if code follows frappe-microservice-lib patterns and best practices.

## When to Use

- Reviewing code before commit
- Ensuring security compliance
- Verifying framework patterns
- Code quality checks

## Instructions

### Security Checks

**1. Authentication**
```python
# GOOD -- secure_route handles auth + tenant + user injection
@app.secure_route('/endpoint', methods=['GET'])
def handler(user):
    data = app.tenant_db.get_all('DocType')
    return {"data": data}

# BAD -- no authentication
@app.route('/endpoint', methods=['GET'])
def handler():
    data = frappe.db.get_all('DocType')
    return {"data": data}
```

**2. Tenant Isolation**
```python
# GOOD -- tenant_db auto-filters by tenant_id
data = app.tenant_db.get_all('DocType', filters={'status': 'Draft'})

# BAD -- no tenant isolation, returns ALL tenants' data
data = frappe.db.get_all('DocType', filters={'status': 'Draft'})
```

**3. SQL Injection Prevention**
```python
# GOOD -- parameterized
result = app.tenant_db.sql(
    "SELECT * FROM `tabDocType` WHERE tenant_id = %s AND status = %s",
    (tenant_id, 'Draft'),
    as_dict=True
)

# BAD -- string formatting
result = app.tenant_db.sql(
    f"SELECT * FROM `tabDocType` WHERE tenant_id = '{tenant_id}'"
)
```

### Framework Pattern Checks

**1. Tenant Resolution (Automatic)**
```python
# GOOD -- secure_route handles tenant resolution automatically
@app.secure_route('/endpoint', methods=['GET'])
def handler(user):
    # g.tenant_id is already set by secure_route
    data = app.tenant_db.get_all('DocType')
    return {"data": data}

# UNNECESSARY -- manual tenant resolution (secure_route does this)
@app.secure_route('/endpoint', methods=['GET'])
def handler(user):
    tenant_id = get_current_tenant_id()
    app.set_tenant_id(tenant_id)
    data = app.tenant_db.get_all('DocType')
    return {"data": data}
```

**2. Transaction Management (Automatic)**
```python
# GOOD -- middleware auto-commits after successful request
@app.secure_route('/endpoint', methods=['POST'])
def handler(user):
    doc = app.tenant_db.insert_doc('DocType', request.json)
    return {"name": doc.name}, 201

# UNNECESSARY -- manual commit (middleware handles this)
@app.secure_route('/endpoint', methods=['POST'])
def handler(user):
    doc = app.tenant_db.insert_doc('DocType', request.json)
    app.tenant_db.commit()  # Not needed
    return {"name": doc.name}, 201
```

**3. Error Handling (Automatic)**
```python
# GOOD -- secure_route auto-handles Frappe exceptions
@app.secure_route('/endpoint/<name>', methods=['GET'])
def handler(user, name):
    doc = app.tenant_db.get_doc('DocType', name)
    return doc.as_dict()
# DoesNotExistError → 404, PermissionError → 403 automatically

# UNNECESSARY -- manual error handling for standard cases
@app.secure_route('/endpoint/<name>', methods=['GET'])
def handler(user, name):
    try:
        doc = app.tenant_db.get_doc('DocType', name)
        return doc.as_dict()
    except frappe.DoesNotExistError:
        return {"error": "Not found"}, 404  # secure_route does this
```

**4. Service Initialization**
```python
# GOOD -- proper initialization
app = create_microservice(
    "service-name",
    load_framework_hooks=['frappe', 'erpnext'],
    controllers_path="./controllers",
)

# ACCEPTABLE -- create_microservice with defaults
# (tenant resolution happens automatically via secure_route)
app = create_microservice("service-name")
```

**5. Use register_resource for Standard CRUD**
```python
# GOOD -- auto-generates all CRUD endpoints
app.register_resource("Sales Order")

# UNNECESSARY -- manually writing CRUD that register_resource provides
@app.secure_route('/api/resource/Sales Order', methods=['GET'])
def list_orders(user):
    return {"data": app.tenant_db.get_all('Sales Order')}
```

### Controller Pattern Checks

**1. Controller Structure**
```python
# GOOD -- extends DocumentController
from frappe_microservice.controller import DocumentController

class SalesOrder(DocumentController):
    def validate(self):
        if not self.customer:
            self.throw("Customer is required")

# BAD -- not using DocumentController
class SalesOrder:
    def validate(self):
        pass
```

**2. Controller Discovery**
```python
# GOOD -- auto-discovered via controllers_path
app = create_microservice("my-service", controllers_path="./controllers")

# ALSO GOOD -- manual setup
from frappe_microservice.controller import setup_controllers
setup_controllers(app, "./controllers")

# BAD -- controllers defined but never registered
# (they won't be called during lifecycle events)
```

### Hook Pattern Checks

**1. Hook Registration**
```python
# GOOD -- registered with tenant_db
@app.tenant_db.on('Sales Order', 'before_insert')
def set_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'

# GOOD -- convenience decorator
@app.tenant_db.before_insert('Sales Order')
def set_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'

# BAD -- hook defined but not registered
def set_defaults(doc):
    doc.status = 'Draft'
```

**2. Hook Error Handling**
```python
# GOOD -- use frappe.throw for validation errors
@app.tenant_db.on('Sales Order', 'validate')
def validate_order(doc):
    if not doc.customer:
        frappe.throw("Customer is required")

# BAD -- bare Exception (not user-friendly)
@app.tenant_db.on('Sales Order', 'validate')
def validate_order(doc):
    if not doc.customer:
        raise Exception("Customer is required")
```

### Background Task Checks

```python
# GOOD -- using enqueue_task with proper context
app.enqueue_task(process_order, order_id, max_retries=3)

# GOOD -- run_background_task for thread-based execution
app.run_background_task(sync_data, external_id)

# BAD -- raw threading without Frappe context
import threading
threading.Thread(target=process_order, args=(order_id,)).start()
```

## Validation Checklist

- [ ] All data endpoints use `@app.secure_route` (not `@app.route`)
- [ ] All queries use `app.tenant_db` (not `frappe.db`)
- [ ] SQL queries use `%s` parameterization (not f-strings)
- [ ] Standard CRUD uses `register_resource()` instead of manual endpoints
- [ ] Controllers extend `DocumentController`
- [ ] Controllers are registered (auto-discovery or `setup_controllers`)
- [ ] Hooks are registered via `@app.tenant_db.on()` or convenience decorators
- [ ] No manual `app.set_tenant_id()` in `secure_route` handlers
- [ ] No manual `app.tenant_db.commit()` in `secure_route` handlers
- [ ] Background tasks use `enqueue_task` or `run_background_task`
- [ ] Input validation on POST/PUT endpoints (check `request.json`)
- [ ] Service-to-service calls use `X-Internal-Token` header

## Key Rules

1. **Always authenticate** -- Use `@app.secure_route`
2. **Always isolate** -- Use `app.tenant_db`
3. **Let middleware work** -- Don't manually commit, set tenant_id, or handle standard errors
4. **Use register_resource** -- For standard CRUD operations
5. **Parameterize SQL** -- Never use string formatting
6. **Use DocumentController** -- For class-based lifecycle logic
7. **Use enqueue_task** -- For background work (not raw threading)
