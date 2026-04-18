---
name: Explain Microservice Pattern
description: Explain frappe-microservice-lib architecture patterns, bounded context, and multi-tenancy principles.
---

# Explain Microservice Pattern

Explain frappe-microservice-lib architecture patterns and best practices.

## When to Use

- Understanding microservice architecture
- Learning bounded context principles
- Explaining multi-tenancy patterns
- Understanding service isolation

## Instructions

### Architecture Overview

**Central Site**: Single source of truth for authentication and user management. All microservices validate sessions against Central Site.

**Microservice**: Independent service with its own database (bounded context). Handles specific business domain (e.g., Orders, Signups).

**Bounded Context**: Each microservice owns its data. No shared database between services.

### Key Principles

**1. Independent Database**
Each microservice has its own database:
```yaml
services:
  orders-service:
    environment:
      - DB_HOST=orders-db  # Independent database
  signup-service:
    environment:
      - DB_HOST=signup-db  # Different database
```

**2. Central Site Authentication**
All services validate sessions via Central Site:
```python
# Microservice validates session cookie
# Central Site returns user profile with tenant_id
```

**3. Tenant Isolation**
Every document has `tenant_id`:
```python
# Automatic tenant filtering
app.set_tenant_id(tenant_id)
docs = app.tenant_db.get_all('DocType')  # Only returns tenant's data
```

**4. No Direct Database Access**
Never access another service's database directly. Use APIs.

### Service Structure

```
microservice/
├── server.py          # Main service file
├── controllers/       # DocType controllers (optional)
│   └── sales_order.py
├── Containerfile      # Container definition
├── entrypoint.py      # Service entrypoint
└── requirements.txt   # Dependencies
```

### Authentication Flow

1. User logs in to Central Site
2. Central Site creates session cookie
3. Microservice receives request with cookie
4. Microservice validates cookie with Central Site
5. Central Site returns user profile (includes tenant_id)
6. Microservice sets tenant_id in context
7. All database queries automatically filtered by tenant_id

### Tenant Resolution

```python
def get_current_tenant_id():
    from flask import g
    from frappe_microservice import get_user_tenant_id
    
    # Check cache
    if hasattr(g, 'tenant_id') and g.tenant_id:
        return g.tenant_id
    
    # Resolve from user
    if hasattr(g, 'current_user') and g.current_user:
        tenant_id = get_user_tenant_id(g.current_user)
        if tenant_id:
            g.tenant_id = tenant_id  # Cache for request
            return tenant_id
    
    return None
```

### Database Patterns

**TenantAwareDB**: Wrapper that automatically adds tenant_id to all queries:

```python
# ✅ Good - automatic tenant filtering
app.set_tenant_id(tenant_id)
docs = app.tenant_db.get_all('Sales Order')
# Automatically adds: WHERE tenant_id = 'xxx'

# ❌ Bad - no tenant isolation
docs = frappe.db.get_all('Sales Order')
# Returns ALL tenants' data!
```

### Service Communication

**Option 1: HTTP APIs**
```python
# Service A calls Service B via HTTP
response = requests.get('http://service-b:8000/api/endpoint')
```

**Option 2: Message Queue** (for async)
```python
# Publish event
publish_event('order.created', order_data)
```

**Option 3: Shared Events** (via Central Site)
```python
# Central Site acts as event bus
```

### Resource API Pattern

Automatic CRUD endpoints:
```python
app.register_resource("Sales Order")
# Creates:
# GET    /api/resource/sales-order
# POST   /api/resource/sales-order
# GET    /api/resource/sales-order/{name}
# PUT    /api/resource/sales-order/{name}
# DELETE /api/resource/sales-order/{name}
```

All endpoints automatically:
- Require authentication
- Filter by tenant_id
- Handle errors properly

### Controller Pattern

Traditional Frappe-style controllers:
```python
# controllers/sales_order.py
class SalesOrder(DocumentController):
    def validate(self):
        # Validation logic
    
    def before_insert(self):
        # Set defaults
```

Register controllers:
```python
from frappe_microservice.controller import setup_controllers
setup_controllers(app, "./controllers")
```

### Hook Pattern

Function-based lifecycle hooks:
```python
@app.tenant_db.on('Sales Order', 'before_insert')
def set_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'
```

### Decomposition Strategy

Gradual migration from monolith:
1. Identify module (e.g., Orders)
2. Extract DocTypes to new database
3. Create microservice with bounded context
4. Update clients to use microservice API
5. Repeat for other modules

### Security Best Practices

1. **Always authenticate** - Use `@app.secure_route`
2. **Tenant isolation** - Always use `app.tenant_db`
3. **Parameterized queries** - Never use string formatting in SQL
4. **Validate input** - Check all user input
5. **Error handling** - Don't expose internal errors

### Common Patterns

**Pattern 1: Minimal Service**
```python
app = create_microservice("my-service")
app.register_resource("DocType")  # That's it!
```

**Pattern 2: Service with Controllers**
```python
app = create_microservice("my-service")
setup_controllers(app, "./controllers")
```

**Pattern 3: Service with Hooks**
```python
app = create_microservice("my-service")
@app.tenant_db.on('DocType', 'before_insert')
def hook(doc):
    pass
```

**Pattern 4: Service with Custom Endpoints**
```python
app = create_microservice("my-service")
@app.secure_route('/custom', methods=['POST'])
def handler(user):
    pass
```

## Key Takeaways

1. **Bounded Context** - Each service owns its database
2. **Central Site** - Single source of truth for auth
3. **Tenant Isolation** - Automatic via TenantAwareDB
4. **No Shared DB** - Services communicate via APIs
5. **Gradual Migration** - Extract modules incrementally
