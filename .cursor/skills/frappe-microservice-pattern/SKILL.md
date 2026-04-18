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

**Central Site**: Single source of truth for authentication and user management. All microservices validate sessions against Central Site via HTTP or shared DB fallback.

**Microservice**: Independent Flask-based service built on `MicroserviceApp`. Composes `IsolationMixin`, `AuthMixin`, `ResourceMixin`, and `BackgroundTaskMixin`. Handles a specific business domain (e.g., Orders, Signups).

**Bounded Context**: Each microservice owns its data domain. Services share the same MariaDB but isolate data via `tenant_id` columns. Never access another service's DocTypes directly -- use APIs.

### MicroserviceApp Composition

```python
class MicroserviceApp(IsolationMixin, AuthMixin, ResourceMixin, BackgroundTaskMixin):
    pass
```

- **IsolationMixin**: Patches `frappe.get_installed_apps`, `get_all_apps`, `get_doc_hooks`, `get_attr`, and `_load_app_hooks` to filter out non-allowed apps. Reads from filesystem `apps.txt` instead of shared DB/Redis.
- **AuthMixin**: Validates sessions via Central Site (OAuth2 Bearer, SID cookie, X-Frappe-SID header) with DB fallback. Also supports `X-Internal-Token` for service-to-service calls.
- **ResourceMixin**: Auto-generates RESTful CRUD endpoints via `register_resource()`.
- **BackgroundTaskMixin**: Optional RQ-based background task processing via `enqueue_task()`.

### Key Principles

**1. Shared DB, Isolated Data**
Services share the same MariaDB but each tenant's data is isolated by `tenant_id`:
```yaml
services:
  orders-service:
    environment:
      - DB_HOST=mariadb          # Shared database
      - CENTRAL_SITE_URL=http://central-site:8000
  signup-service:
    environment:
      - DB_HOST=mariadb          # Same shared database
      - CENTRAL_SITE_URL=http://central-site:8000
```

**2. Central Site Authentication**
All services validate sessions against the Central Site. Auth priority:
1. `X-Internal-Token` header (service-to-service, maps to Administrator)
2. `Authorization: Bearer <token>` (OAuth2 via Central Site OIDC)
3. `sid` cookie or `X-Frappe-SID` header (Central Site get_logged_user)
4. Direct DB fallback (shared `tabSessions` table)

**3. Automatic Tenant Isolation**
`secure_route` automatically resolves `tenant_id` from the authenticated user and stores it in `g.tenant_id`. All `tenant_db` methods auto-inject tenant filters:
```python
@app.secure_route('/orders', methods=['GET'])
def list_orders(user):
    # g.tenant_id is already set by secure_route
    docs = app.tenant_db.get_all('Sales Order')  # Auto-filtered by tenant_id
    return {"data": docs}
```

**4. App Isolation**
The `IsolationMixin` ensures each microservice only sees its own apps:
```python
app = create_microservice(
    "orders-service",
    load_framework_hooks=['frappe', 'erpnext']  # Only load these + service app
)
# Allowed apps = {'frappe', 'erpnext', 'orders_service'}
# All other apps from central site are filtered out
```

### Service Structure

```
service-name-service/
├── server.py              # Main service file (create_microservice + routes)
├── controllers/           # DocType controllers (auto-discovered)
│   ├── __init__.py
│   └── sales_order.py     # SalesOrder(DocumentController)
├── doctypes/              # Service-owned DocType JSONs
│   └── sales_order/
│       └── sales_order.json
├── fixtures/              # Fixture JSONs (SMS Settings, Email Templates)
│   └── sms_settings.json
├── Containerfile          # Container definition
├── requirements.txt       # Dependencies
└── tests/
    └── test_server.py
```

### Authentication Flow

1. User logs in to Central Site (creates session in `tabSessions`)
2. Client sends request to microservice with `sid` cookie or Bearer token
3. `secure_route` calls `_validate_session()`:
   - Checks X-Internal-Token (service-to-service)
   - Checks Bearer token (OAuth2 via Central Site OIDC)
   - Checks sid cookie (Central Site get_logged_user)
   - Falls back to direct DB lookup in shared `tabSessions`
4. On success, resolves `tenant_id` via `get_user_tenant_id(username)`
5. Sets `g.tenant_id` and `g.current_user`
6. Injects `username` as first argument to the view function

### Tenant Resolution

`get_user_tenant_id(user_email)` resolves tenant from `tabUser`:
- Direct SQL: `SELECT tenant_id FROM tabUser WHERE name = %s AND enabled = 1`
- Rejects `Guest`, disabled users, and `SYSTEM` tenant_id (security)
- Falls back to `frappe.db.get_value` if SQL fails

### Database Patterns

**TenantAwareDB**: Wrapper that auto-injects `tenant_id` into all filters:

```python
# All these auto-add tenant_id filter
app.tenant_db.get_all('Sales Order', filters={'status': 'Draft'})
app.tenant_db.get_doc('Sales Order', 'SO-001')
app.tenant_db.insert_doc('Sales Order', {'customer': 'CUST-001'})
app.tenant_db.update_doc('Sales Order', 'SO-001', {'status': 'Confirmed'})
app.tenant_db.delete_doc('Sales Order', 'SO-001')
app.tenant_db.count('Sales Order', filters={'status': 'Draft'})
app.tenant_db.exists('Sales Order', {'name': 'SO-001'})
app.tenant_db.get_value('Sales Order', 'SO-001', 'status')
app.tenant_db.set_value('Sales Order', 'SO-001', 'status', 'Confirmed')
```

**Document Lifecycle Hooks** (run automatically by TenantAwareDB):
- `insert_doc`: before_validate → before_insert → DB INSERT → after_insert
- `update_doc`: before_update → update fields → before_validate → doc.save() → after_update
- `delete_doc`: before_delete → doc.delete() → after_delete

### Resource API Pattern

Auto-generates Frappe-style CRUD endpoints with Swagger docs:
```python
app.register_resource("Sales Order")
# Creates (all secured, tenant-scoped):
# GET    /api/resource/Sales Order       (list with pagination)
# GET    /api/resource/sales-order       (kebab-case alias)
# POST   /api/resource/Sales Order       (create)
# GET    /api/resource/Sales Order/<name> (get one)
# PUT    /api/resource/Sales Order/<name> (update)
# DELETE /api/resource/Sales Order/<name> (delete)
```

### Controller Pattern

Traditional Frappe-style controllers, auto-discovered from `controllers_path`:
```python
# controllers/sales_order.py
from frappe_microservice.controller import DocumentController

class SalesOrder(DocumentController):
    def validate(self):
        if not self.customer:
            self.throw("Customer is required")

    def before_insert(self):
        if not self.status:
            self.status = 'Draft'
```

Controllers are auto-discovered by filename convention: `sales_order.py` → `SalesOrder` class → `Sales Order` DocType.

### Hook Pattern

Function-based lifecycle hooks via TenantAwareDB:
```python
@app.tenant_db.on('Sales Order', 'before_insert')
def set_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'

@app.tenant_db.before_validate('*')
def global_validate(doc):
    pass
```

### Background Tasks (RQ)

Optional RQ-based background processing:
```python
# Enable via ENABLE_RQ=1 env var
app.enqueue_task(process_order, order_id, max_retries=3, job_timeout=120)
```

Tasks run with full Frappe context restored (init, connect, doctypes registered).

### Central Site Client

Lazy-initialized API client for calling the Central Site:
```python
# Read from Central Site
user_doc = app.central.get_doc('User', 'admin@example.com')
users = app.central.get_list('User', filters={'enabled': 1})
result = app.central.call('frappe.client.get_count', {'doctype': 'User'})
```

### Entrypoint & Deployment

Container entrypoint handles presync + Gunicorn:
```dockerfile
ENTRYPOINT ["python", "-m", "frappe_microservice.entrypoint"]
```

The entrypoint:
1. Creates `site_config.json` from env vars
2. Pre-syncs service DocTypes and fixtures to DB (once, before workers)
3. Execs Gunicorn with `--preload` (app loaded once in master, forked to workers)

### Middleware (Automatic)

- **before_request**: Restores frappe.local, opens DB on first request, pings/reconnects on subsequent
- **after_request**: Auto-commits DB (unless rolled back by error handler)
- **errorhandler**: Catches unhandled exceptions, returns JSON 500

### Global App Accessor

```python
from frappe_microservice import get_app
app = get_app()  # Returns the currently active MicroserviceApp
```

### Security Best Practices

1. **Always authenticate** -- Use `@app.secure_route` (never `@app.route` for data endpoints)
2. **Tenant isolation** -- Always use `app.tenant_db` (never raw `frappe.db`)
3. **Parameterized queries** -- Never string-format SQL; use `app.tenant_db.sql()` with `%s` placeholders
4. **SYSTEM tenant blocked** -- `get_user_tenant_id` rejects SYSTEM to prevent data leakage
5. **Error handling** -- `secure_route` auto-handles PermissionError→403, DoesNotExistError→404, ValidationError→400

### Common Patterns

**Pattern 1: Minimal Service with Auto-CRUD**
```python
app = create_microservice("my-service")
app.register_resource("Sales Order")
```

**Pattern 2: Service with Controllers (auto-discovered)**
```python
app = create_microservice("my-service", controllers_path="./controllers")
```

**Pattern 3: Service with Hooks**
```python
app = create_microservice("my-service")
@app.tenant_db.on('Sales Order', 'before_insert')
def hook(doc):
    doc.status = 'Draft'
```

**Pattern 4: Custom Endpoints**
```python
app = create_microservice("my-service")
@app.secure_route('/custom', methods=['POST'])
def handler(user):
    data = request.json
    doc = app.tenant_db.insert_doc('Sales Order', data)
    return {"name": doc.name}, 201
```

**Pattern 5: Background Tasks**
```python
# Set ENABLE_RQ=1
app = create_microservice("my-service")
@app.secure_route('/process', methods=['POST'])
def start_processing(user):
    app.enqueue_task(heavy_computation, request.json['id'])
    return {"status": "queued"}
```

## Key Takeaways

1. **Bounded Context** -- Each service owns its DocTypes and business logic
2. **Central Site** -- Single source of truth for auth (sessions validated via HTTP or shared DB)
3. **Automatic Tenant Isolation** -- `secure_route` resolves tenant, `tenant_db` enforces it
4. **Auto-CRUD** -- `register_resource()` generates complete REST APIs
5. **App Isolation** -- IsolationMixin filters apps/hooks/modules from shared Redis/DB
6. **Auto-Commit** -- Middleware commits after each request (no manual commit needed)
7. **Presync Entrypoint** -- DocTypes/fixtures synced once before Gunicorn starts
