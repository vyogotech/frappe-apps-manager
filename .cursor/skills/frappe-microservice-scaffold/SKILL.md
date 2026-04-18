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

### 1. Service Entry Point (server.py)

```python
from frappe_microservice import create_microservice
from flask import request

app = create_microservice(
    "service-name",
    load_framework_hooks=['frappe', 'erpnext'],  # or ['frappe'] or 'none'
    doctypes_path="./service_name/service_name/doctype",  # optional: service DocType JSONs
    fixtures_path="./fixtures",                            # optional: fixture JSONs
    controllers_path="./controllers",                      # optional: auto-discovered
    log_level="INFO",                                      # or via LOG_LEVEL env var
)

# Auto-CRUD endpoints for DocTypes
app.register_resource("Sales Order")
app.register_resource("Customer")

# Custom secure endpoint
@app.secure_route('/api/dashboard', methods=['GET'])
def dashboard(user):
    """user and g.tenant_id are set automatically by secure_route."""
    orders = app.tenant_db.get_all('Sales Order', filters={'status': 'Draft'})
    total = app.tenant_db.count('Sales Order')
    return {"orders": orders, "total": total}

@app.secure_route('/api/orders', methods=['POST'])
def create_order(user):
    data = request.json
    if not data or not data.get('customer'):
        return {"error": "customer is required"}, 400
    doc = app.tenant_db.insert_doc('Sales Order', data)
    return {"name": doc.name}, 201

# Document lifecycle hooks
@app.tenant_db.on('Sales Order', 'before_insert')
def set_order_defaults(doc):
    if not doc.status:
        doc.status = 'Draft'

if __name__ == '__main__':
    app.run(debug=True)
```

### 2. Resource API (Auto-CRUD)

```python
app.register_resource("Sales Order")
# Auto-creates secured, tenant-scoped endpoints:
# GET    /api/resource/Sales Order        (list with pagination/filters)
# POST   /api/resource/Sales Order        (create)
# GET    /api/resource/Sales Order/<name>  (get one)
# PUT    /api/resource/Sales Order/<name>  (update)
# DELETE /api/resource/Sales Order/<name>  (delete)

# With custom handlers:
app.register_resource("Sales Order", custom_handlers={
    'list': my_list_handler,
    'post': my_create_handler,
})
```

### 3. Secure Endpoints

```python
@app.secure_route('/endpoint', methods=['GET'])
def handler(user):
    """secure_route auto-handles:
    - Session validation (Bearer/SID/X-Internal-Token)
    - tenant_id resolution → g.tenant_id
    - user injection as first arg
    - Dict return → jsonify (with timedelta/Decimal/etc. encoding)
    - Error mapping: PermissionError→403, DoesNotExistError→404, ValidationError→400
    - Auto-commit via after_request middleware
    """
    data = app.tenant_db.get_all('Sales Order')
    return {"data": data}
```

### 4. Tenant-Aware Database

```python
# All methods auto-inject tenant_id filter
app.tenant_db.get_all('DocType', filters={...})
app.tenant_db.get_doc('DocType', name)
app.tenant_db.insert_doc('DocType', data)
app.tenant_db.update_doc('DocType', name, data)
app.tenant_db.delete_doc('DocType', name)
app.tenant_db.count('DocType', filters={...})
app.tenant_db.exists('DocType', filters)
app.tenant_db.get_value('DocType', filters, 'fieldname')
app.tenant_db.set_value('DocType', name, 'field', 'value')
app.tenant_db.new_doc('DocType', field='value')  # creates but doesn't insert
```

### 5. Controllers (Auto-Discovered)

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

Auto-discovered from `controllers_path` or `$SERVICE_PATH/controllers/`.

### 6. Background Tasks (RQ)

```python
# Requires ENABLE_RQ=1 and REDIS_URL env vars
@app.secure_route('/process', methods=['POST'])
def start_processing(user):
    app.enqueue_task(heavy_task, request.json['id'], max_retries=3)
    return {"status": "queued"}
```

### 7. Containerfile

```dockerfile
FROM ghcr.io/your-org/frappe-microservice-base:latest

WORKDIR /app/service
COPY . .

ENV SERVICE_NAME=service-name
ENV SERVICE_APP=server:app
ENV SERVICE_PATH=/app/service

EXPOSE 8000
ENTRYPOINT ["python", "-m", "frappe_microservice.entrypoint"]
```

The entrypoint automatically:
1. Creates `site_config.json` from env vars
2. Pre-syncs DocTypes and fixtures to DB (once, idempotent)
3. Execs Gunicorn with `--preload`

### 8. Environment Variables

```bash
# Required
FRAPPE_SITE=site1.local
FRAPPE_SITES_PATH=/app/sites
DB_HOST=mariadb
DB_NAME=_xxxx
DB_USER=frappe
DB_PASSWORD=changeme
CENTRAL_SITE_URL=http://central-site:8000

# Optional
SERVICE_NAME=service-name
SERVICE_APP=server:app
SERVICE_PATH=/app/service
LOG_LEVEL=INFO
REDIS_HOST=redis
REDIS_PORT=6379
ENABLE_RQ=1                    # Enable background tasks
REDIS_URL=redis://redis:6379   # RQ Redis connection
INTERNAL_SERVICE_TOKEN=secret  # Service-to-service auth
OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:4317  # Tracing
ENCRYPTION_KEY=...             # Frappe encryption key
```

## File Structure

```
<service-name>-service/
├── server.py              # create_microservice + routes + hooks
├── Containerfile          # Container build
├── requirements.txt       # frappe-microservice-lib + deps
├── controllers/           # Auto-discovered DocType controllers
│   ├── __init__.py
│   └── sales_order.py
├── service_name/          # Frappe app module (if using service DocTypes)
│   └── service_name/
│       └── doctype/
│           └── my_doctype/
│               └── my_doctype.json
├── fixtures/              # Fixture JSONs for presync
│   └── sms_settings.json
└── tests/
    ├── conftest.py
    └── test_server.py
```

## Best Practices

1. Use `@app.secure_route` for all authenticated endpoints (never `@app.route`)
2. Use `app.tenant_db` for all data access (never raw `frappe.db`)
3. Use `register_resource()` for standard CRUD -- custom endpoints only for business logic
4. Let middleware handle commits -- no manual `app.tenant_db.commit()` needed in routes
5. Let `secure_route` handle tenant resolution -- no manual `app.set_tenant_id()` needed
6. Use `load_framework_hooks` to control which Frappe apps are loaded
7. Put DocType controllers in `controllers/` for auto-discovery

Remember: This skill is model-invoked. Claude will use it autonomously when detecting microservice scaffolding needs.
