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

# Detect runtime
def detect_runtime():
    try:
        subprocess.run(['podman', '--version'], capture_output=True, check=True)
        return 'podman'
    except:
        try:
            subprocess.run(['docker', '--version'], capture_output=True, check=True)
            return 'docker'
        except:
            raise RuntimeError("Neither podman nor docker found")

RUNTIME = detect_runtime()
COMPOSE_FILE = 'dev-podman-compose.yml' if RUNTIME == 'podman' else 'docker-compose.yml'
COMPOSE_CMD = f'{RUNTIME} compose' if RUNTIME == 'podman' else 'docker-compose'

# Service URLs
CENTRAL_SITE = "http://localhost:8080"
SERVICE_URL = "http://localhost:8000"
```

### 2. Service Management

```python
def ensure_services_running():
    result = subprocess.run(
        [*COMPOSE_CMD.split(), '-f', COMPOSE_FILE, 'ps', '--services', '--filter', 'status=running'],
        capture_output=True, text=True
    )
    running = result.stdout.strip().split('\n')
    
    for service in ['dev-central-site', '<service>-service']:
        if service not in running:
            subprocess.run([*COMPOSE_CMD.split(), '-f', COMPOSE_FILE, 'up', '-d', service], check=True)
            time.sleep(5)
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
    if response.status_code in [200, 201]:
        return response.json().get('data')
    return None

def authenticate_tenant(tenant_info):
    response = requests.post(
        f"{CENTRAL_SITE}/api/method/login",
        json={'usr': tenant_info['admin_email'], 'pwd': tenant_info['admin_password']},
        timeout=60
    )
    if response.status_code == 200:
        return response.cookies
    return None
```

### 4. Test Workflow

```python
def test_workflow():
    ensure_services_running()
    
    # Create tenant
    tenant_info = create_tenant("Test", "admin@test.com", "password")
    if not tenant_info:
        return False
    
    # Authenticate
    cookies = authenticate_tenant(tenant_info)
    if not cookies:
        return False
    
    # Test service
    response = requests.post(
        f"{SERVICE_URL}/api/resource/doctype",
        json={"field": "value"},
        cookies=cookies,
        timeout=30
    )
    
    return response.status_code in [200, 201]
```

### 5. Multi-Tenant Isolation Test

```python
def test_multi_tenant_isolation():
    tenant1 = create_tenant("Alpha", "admin1@test.com", "pass1")
    tenant2 = create_tenant("Beta", "admin2@test.com", "pass2")
    
    cookies1 = authenticate_tenant(tenant1)
    cookies2 = authenticate_tenant(tenant2)
    
    # Create resources for each
    # Verify no overlap
    data1 = requests.get(f"{SERVICE_URL}/api/resource/doctype", cookies=cookies1).json()
    data2 = requests.get(f"{SERVICE_URL}/api/resource/doctype", cookies=cookies2).json()
    
    ids1 = {item['name'] for item in data1.get('data', [])}
    ids2 = {item['name'] for item in data2.get('data', [])}
    
    return len(ids1.intersection(ids2)) == 0
```

## Key Patterns

1. **Runtime Detection**: Auto-detect podman/docker
2. **Service Management**: Check and start services
3. **Tenant Creation**: Use signup service
4. **Authentication**: Login to central site
5. **Isolation Testing**: Verify no cross-tenant access
6. **Error Handling**: Comprehensive try/except

## Best Practices

- Idempotent tests (runnable multiple times)
- Clean state when possible
- Clear success/error messages
- Timeout protection for network calls
- Resource cleanup when possible

## Reference

**Complete Example**: See `frappe_ms_poc/tests/e2e_test_simple.py` for full implementation

Remember: This skill is model-invoked. Claude will use it autonomously when detecting E2E testing needs.
