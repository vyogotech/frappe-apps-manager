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
# ✅ Good
@app.secure_route('/endpoint', methods=['GET'])
def handler(user):
    pass

# ❌ Bad - no authentication
@app.route('/endpoint', methods=['GET'])
def handler():
    pass
```

**2. Tenant Isolation**
```python
# ✅ Good
tenant_id = get_current_tenant_id()
app.set_tenant_id(tenant_id)
data = app.tenant_db.get_all('DocType')

# ❌ Bad - no tenant isolation
data = frappe.db.get_all('DocType')
```

**3. SQL Injection Prevention**
```python
# ✅ Good - parameterized
result = app.tenant_db.sql(
    "SELECT * FROM `tabDocType` WHERE tenant_id = %s AND status = %s",
    (tenant_id, 'Draft'),
    as_dict=True
)

# ❌ Bad - string formatting
result = app.tenant_db.sql(
    f"SELECT * FROM `tabDocType` WHERE tenant_id = '{tenant_id}'"
)
```

### Framework Pattern Checks

**1. Tenant Resolution Function**
```python
# ✅ Good - proper tenant resolution
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

# ❌ Bad - missing security checks
def get_current_tenant_id():
    return frappe.session.user
```

**2. Database Access**
```python
# ✅ Good - uses tenant_db
app.set_tenant_id(tenant_id)
doc = app.tenant_db.get_doc('DocType', name)

# ❌ Bad - uses frappe.db directly
doc = frappe.get_doc('DocType', name)
```

**3. Transaction Management**
```python
# ✅ Good - proper transaction handling
try:
    frappe.db.begin()
    doc1 = app.tenant_db.insert_doc('DocType1', data1)
    doc2 = app.tenant_db.insert_doc('DocType2', data2)
    app.tenant_db.commit()
except Exception as e:
    app.tenant_db.rollback()
    raise

# ❌ Bad - no transaction management
doc1 = app.tenant_db.insert_doc('DocType1', data1)
doc2 = app.tenant_db.insert_doc('DocType2', data2)
```

### Code Structure Checks

**1. Service Initialization**
```python
# ✅ Good - proper initialization
app = create_microservice(
    "service-name",
    get_tenant_id_func=get_current_tenant_id,
    load_framework_hooks=['frappe', 'erpnext']
)

# ❌ Bad - missing tenant function
app = create_microservice("service-name")
```

**2. Error Handling**
```python
# ✅ Good - proper error responses
try:
    doc = app.tenant_db.get_doc('DocType', name)
    return {"data": doc.as_dict()}
except frappe.DoesNotExistError:
    return {"error": "Document not found"}, 404
except Exception as e:
    return {"error": str(e)}, 500

# ❌ Bad - no error handling
doc = app.tenant_db.get_doc('DocType', name)
return {"data": doc.as_dict()}
```

**3. Input Validation**
```python
# ✅ Good - validates input
data = request.json
if not data:
    return {"error": "No data provided"}, 400
if not data.get('required_field'):
    return {"error": "required_field is required"}, 400

# ❌ Bad - no validation
data = request.json
doc = app.tenant_db.insert_doc('DocType', data)
```

### Controller Pattern Checks

**1. Controller Structure**
```python
# ✅ Good - proper controller
from frappe_microservice.controller import DocumentController

class SalesOrder(DocumentController):
    def validate(self):
        if not self.customer:
            self.throw("Customer is required")
    
    def before_insert(self):
        if not self.status:
            self.status = 'Draft'

# ❌ Bad - not using DocumentController
class SalesOrder:
    def validate(self):
        pass
```

**2. Controller Registration**
```python
# ✅ Good - registers controllers
from frappe_microservice.controller import setup_controllers
setup_controllers(app, "./controllers")

# ❌ Bad - controllers not registered
# Controllers won't be called
```

### Hook Pattern Checks

**1. Hook Registration**
```python
# ✅ Good - proper hook registration
@app.tenant_db.on('Sales Order', 'before_insert')
def set_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'

# ❌ Bad - hook not registered with app
def set_defaults(doc):
    pass
```

**2. Hook Error Handling**
```python
# ✅ Good - handles errors
@app.tenant_db.on('Sales Order', 'validate')
def validate_order(doc):
    try:
        if not doc.customer:
            frappe.throw("Customer is required")
    except frappe.ValidationError:
        raise
    except Exception as e:
        frappe.log_error(f"Error: {e}")

# ❌ Bad - no error handling
@app.tenant_db.on('Sales Order', 'validate')
def validate_order(doc):
    if not doc.customer:
        raise Exception("Customer is required")
```

### Common Issues to Check

**1. Missing tenant_id Setting**
```python
# ❌ Bad - forgot to set tenant_id
@app.secure_route('/endpoint', methods=['GET'])
def handler(user):
    data = app.tenant_db.get_all('DocType')  # Will fail!

# ✅ Good
@app.secure_route('/endpoint', methods=['GET'])
def handler(user):
    tenant_id = get_current_tenant_id()
    app.set_tenant_id(tenant_id)
    data = app.tenant_db.get_all('DocType')
```

**2. Using frappe.session Directly**
```python
# ❌ Bad - direct session access
user = frappe.session.user

# ✅ Good - use injected user
@app.secure_route('/endpoint', methods=['GET'])
def handler(user):  # user is injected
    pass
```

**3. Missing Commit**
```python
# ❌ Bad - no commit
doc = app.tenant_db.insert_doc('DocType', data)
return {"success": True}

# ✅ Good - commits transaction
doc = app.tenant_db.insert_doc('DocType', data)
app.tenant_db.commit()
return {"success": True}
```

## Validation Checklist

- [ ] All endpoints use `@app.secure_route`
- [ ] Tenant ID is set before database operations
- [ ] All queries use `app.tenant_db` (not `frappe.db`)
- [ ] SQL queries are parameterized
- [ ] Transactions are properly managed (begin/commit/rollback)
- [ ] Input validation is performed
- [ ] Error handling returns proper HTTP status codes
- [ ] Controllers extend `DocumentController`
- [ ] Hooks are registered with `@app.tenant_db.on()`
- [ ] No direct `frappe.session` access in endpoints

## Key Rules

1. **Always authenticate** - Use `@app.secure_route`
2. **Always isolate** - Use `app.tenant_db`
3. **Always validate** - Check input and business rules
4. **Always handle errors** - Return proper status codes
5. **Always use transactions** - For multi-step operations
6. **Never use frappe.db** - In microservices
7. **Never use string formatting in SQL** - Always parameterize
