---
name: Generate E2E Container Tests
description: Generate container-based E2E tests using podman/docker, testing complete workflows across microservices.
---

# Generate E2E Container Tests

Create container-based end-to-end tests that verify complete workflows across microservices.

## When to Use

- Testing complete user workflows
- Verifying multi-tenant isolation
- Testing service integration
- Validating authentication flows

## Core Patterns

### 1. Test Structure

```python
import requests
import subprocess
import time
import pytest

RUNTIME = 'podman'  # or 'docker'
COMPOSE_CMD = f'{RUNTIME} compose'
COMPOSE_FILE = 'dev-podman-compose.yml'

CENTRAL_SITE = "http://localhost:8080"
SERVICE_URL = "http://localhost:8000"
```

### 2. Service Management

```python
@pytest.fixture(scope="session", autouse=True)
def ensure_services():
    result = subprocess.run(
        [*COMPOSE_CMD.split(), '-f', COMPOSE_FILE, 'ps', '--services', '--filter', 'status=running'],
        capture_output=True, text=True
    )
    running = result.stdout.strip().split('\n')

    required = ['dev-central-site', 'orders-service']
    for service in required:
        if service not in running:
            subprocess.run(
                [*COMPOSE_CMD.split(), '-f', COMPOSE_FILE, 'up', '-d', service],
                check=True
            )
            time.sleep(10)

    yield
```

### 3. Tenant Creation & Auth

```python
def create_tenant(name, email, password):
    response = requests.post(
        f"{SERVICE_URL}/signup/tenant",
        json={
            "tenant_name": f"E2E {name}",
            "admin_email": email,
            "admin_password": password
        },
        timeout=60
    )
    assert response.status_code in [200, 201]
    return response.json().get('data')

def authenticate(email, password):
    response = requests.post(
        f"{CENTRAL_SITE}/api/method/login",
        json={'usr': email, 'pwd': password},
        timeout=60
    )
    assert response.status_code == 200
    return response.cookies

def authenticate_internal():
    """For service-to-service calls."""
    import os
    return {"X-Internal-Token": os.getenv("INTERNAL_SERVICE_TOKEN")}
```

### 4. CRUD Workflow Test

```python
def test_crud_workflow():
    cookies = authenticate("admin@tenant1.com", "password")

    # Create
    resp = requests.post(
        f"{SERVICE_URL}/api/resource/Sales Order",
        json={"customer": "CUST-001", "items": [{"item_code": "ITEM-001", "qty": 5}]},
        cookies=cookies, timeout=30
    )
    assert resp.status_code == 201
    name = resp.json()['name']

    # Read
    resp = requests.get(
        f"{SERVICE_URL}/api/resource/Sales Order/{name}",
        cookies=cookies, timeout=30
    )
    assert resp.status_code == 200
    assert resp.json()['customer'] == 'CUST-001'

    # Update
    resp = requests.put(
        f"{SERVICE_URL}/api/resource/Sales Order/{name}",
        json={"status": "Confirmed"},
        cookies=cookies, timeout=30
    )
    assert resp.status_code == 200

    # Delete
    resp = requests.delete(
        f"{SERVICE_URL}/api/resource/Sales Order/{name}",
        cookies=cookies, timeout=30
    )
    assert resp.status_code == 200
```

### 5. Multi-Tenant Isolation Test

```python
def test_multi_tenant_isolation():
    # Create two tenants
    tenant1 = create_tenant("Alpha", "admin1@test.com", "pass1")
    tenant2 = create_tenant("Beta", "admin2@test.com", "pass2")

    cookies1 = authenticate("admin1@test.com", "pass1")
    cookies2 = authenticate("admin2@test.com", "pass2")

    # Create orders for each tenant
    resp1 = requests.post(
        f"{SERVICE_URL}/api/resource/Sales Order",
        json={"customer": "Alpha-Customer"},
        cookies=cookies1, timeout=30
    )
    assert resp1.status_code == 201
    order1 = resp1.json()['name']

    resp2 = requests.post(
        f"{SERVICE_URL}/api/resource/Sales Order",
        json={"customer": "Beta-Customer"},
        cookies=cookies2, timeout=30
    )
    assert resp2.status_code == 201
    order2 = resp2.json()['name']

    # Tenant 1 cannot see Tenant 2's orders
    list1 = requests.get(
        f"{SERVICE_URL}/api/resource/Sales Order",
        cookies=cookies1, timeout=30
    ).json()
    names1 = {item['name'] for item in list1.get('data', [])}
    assert order1 in names1
    assert order2 not in names1

    # Tenant 2 cannot access Tenant 1's order directly
    resp = requests.get(
        f"{SERVICE_URL}/api/resource/Sales Order/{order1}",
        cookies=cookies2, timeout=30
    )
    assert resp.status_code in [403, 404]
```

### 6. Auth Flow Test

```python
def test_unauthenticated_rejected():
    resp = requests.get(f"{SERVICE_URL}/api/resource/Sales Order", timeout=10)
    assert resp.status_code == 401

def test_health_unauthenticated():
    resp = requests.get(f"{SERVICE_URL}/health", timeout=10)
    assert resp.status_code == 200
    assert resp.json()['status'] == 'healthy'

def test_bearer_token_auth():
    # Get OAuth2 token from Central Site
    token = get_oauth_token()
    resp = requests.get(
        f"{SERVICE_URL}/api/resource/Sales Order",
        headers={"Authorization": f"Bearer {token}"},
        timeout=30
    )
    assert resp.status_code == 200

def test_internal_token_auth():
    import os
    resp = requests.get(
        f"{SERVICE_URL}/api/resource/Sales Order",
        headers={"X-Internal-Token": os.getenv("INTERNAL_SERVICE_TOKEN")},
        timeout=30
    )
    assert resp.status_code == 200
```

### 7. Integration Test with Frappe Session (pytest conftest)

```python
# tests/integration/conftest.py
import pytest
import frappe
from frappe_microservice.tenant import TenantAwareDB, patch_valid_dict_for_tenant_id

@pytest.fixture(scope="session")
def frappe_session():
    """Initialize Frappe for integration tests."""
    site = os.getenv("FRAPPE_SITE", "site1.local")
    sites_path = os.getenv("FRAPPE_SITES_PATH", "/app/sites")
    frappe.init(site=site, sites_path=sites_path)
    frappe.connect()
    patch_valid_dict_for_tenant_id()
    yield
    frappe.destroy()

@pytest.fixture
def tenant_db(frappe_session):
    """Provide a TenantAwareDB scoped to test tenant."""
    db = TenantAwareDB(lambda: "test-tenant-001")
    yield db
    frappe.db.rollback()
```

## Key Patterns

1. **Runtime Detection**: Support both podman and docker
2. **Service Management**: Check and start services before tests
3. **Tenant Creation**: Use signup service or direct DB
4. **Authentication**: Login to Central Site, use cookies/Bearer/X-Internal-Token
5. **Isolation Testing**: Create data per tenant, verify no cross-access
6. **Error Handling**: Assert proper HTTP status codes
7. **Cleanup**: Rollback DB in fixtures, or use idempotent test data

## Best Practices

- Idempotent tests (runnable multiple times)
- Timeout protection for all network calls
- Clear assertions with descriptive messages
- Test both happy path and error cases
- Verify tenant isolation is enforced
- Test all auth methods (SID, Bearer, Internal Token)
- Use pytest fixtures for setup/teardown

Remember: This skill is model-invoked. Claude will use it autonomously when detecting E2E testing needs.
