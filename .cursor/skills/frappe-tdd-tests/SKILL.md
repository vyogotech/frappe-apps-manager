---
name: Generate TDD Tests
description: Generate Frappe-style unit tests using FrappeTestCase, with optional BDD API tests. Follow TDD principles.
---

# Generate TDD Tests

Create comprehensive test suites following TDD principles with FrappeTestCase. Optionally generate BDD-style API tests.

## When to Use

- Writing unit tests for DocTypes, controllers, APIs
- Testing tenant isolation
- Testing validation and business logic
- API integration testing (BDD optional)

## Core Patterns

### 1. Frappe Test Structure

```python
import frappe
from frappe.tests.utils import FrappeTestCase

class TestDocTypeName(FrappeTestCase):
    def setUp(self):
        frappe.set_user("Administrator")
        # Optional: frappe.get_test_records("Customer")
    
    def tearDown(self):
        frappe.db.rollback()  # Fast cleanup
    
    def test_document_creation(self):
        doc = frappe.get_doc({"doctype": "DocType", "field": "value"})
        doc.insert()
        self.assertIsNotNone(doc.name)
        self.assertTrue(frappe.db.exists("DocType", doc.name))
    
    def test_validation(self):
        doc = frappe.get_doc({"doctype": "DocType", "required_field": ""})
        self.assertRaises(frappe.ValidationError, doc.insert)
```

### 2. Controller Tests

```python
from controllers.sales_order import SalesOrder

class TestSalesOrderController(FrappeTestCase):
    def setUp(self):
        frappe.set_user("Administrator")
    
    def tearDown(self):
        frappe.db.rollback()
    
    def test_controller_validation(self):
        doc = frappe.get_doc({"doctype": "Sales Order", "customer": None})
        controller = SalesOrder(doc)
        self.assertRaises(frappe.ValidationError, controller.validate)
    
    def test_controller_lifecycle(self):
        doc = frappe.get_doc({"doctype": "Sales Order", "customer": "CUST-001"})
        controller = SalesOrder(doc)
        controller.before_insert()
        self.assertEqual(doc.status, "Draft")
```

### 3. Tenant Isolation Tests

```python
from frappe_microservice.core import get_user_tenant_id

class TestTenantIsolation(FrappeTestCase):
    def test_tenant_id_resolution(self):
        result = get_user_tenant_id("user@tenant.com")
        self.assertEqual(result, "tenant-001")
    
    def test_cross_tenant_access_prevented(self):
        # Create docs for different tenants
        doc1 = frappe.get_doc({"doctype": "Order", "tenant_id": "t1"})
        doc1.insert(ignore_permissions=True)
        
        doc2 = frappe.get_doc({"doctype": "Order", "tenant_id": "t2"})
        doc2.insert(ignore_permissions=True)
        
        # Query should only return tenant's docs
        orders = frappe.get_all("Order", filters={"tenant_id": "t1"})
        self.assertEqual(len(orders), 1)
```

### 4. API Endpoint Tests

```python
from server import app
from unittest.mock import patch

class TestAPIEndpoints(FrappeTestCase):
    def setUp(self):
        frappe.set_user("Administrator")
        self.client = app.flask_app.test_client()
    
    def tearDown(self):
        frappe.db.rollback()
    
    def test_requires_authentication(self):
        response = self.client.get('/api/resource/order')
        self.assertEqual(response.status_code, 401)
    
    def test_with_valid_session(self):
        with patch.object(app, '_validate_session', return_value=("user@example.com", None)):
            response = self.client.get('/api/resource/order')
            self.assertEqual(response.status_code, 200)
```

### 5. BDD Tests (Optional)

**When requested, use pytest-bdd:**

```python
from pytest_bdd import given, when, then, scenario

@scenario('api_tests.feature', 'Create order')
def test_create_order():
    pass

@given('I am authenticated')
def authenticated():
    # Login logic
    return cookies

@when('I create order with customer "<customer>"')
def create_order(authenticated, customer):
    # Create order
    return response

@then('order should be created')
def verify_order(create_order):
    assert create_order.status_code == 201
```

**Feature file** (`tests/features/api_tests.feature`):
```gherkin
Feature: Order API
  Scenario: Create order
    Given I am authenticated
    When I create order with customer "Test"
    Then order should be created
```

## Test Configuration

**Frappe Bench** (default):
```bash
bench --site <site> run-tests --app <app>
bench --site <site> run-tests --app <app> --coverage
```

**Pytest** (for microservices):
```ini
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
markers =
    unit: Unit tests
    integration: Integration tests
```

## Test Fixtures

**FrappeTestCase** (recommended):
```python
class TestMyDocType(FrappeTestCase):
    def setUp(self):
        frappe.set_user("Administrator")
    
    def tearDown(self):
        frappe.db.rollback()  # Automatic cleanup
```

**Pytest fixtures** (optional):
```python
# conftest.py
@pytest.fixture
def setup_frappe():
    frappe.set_user("Administrator")
    yield
    frappe.db.rollback()
```

## Key Patterns

1. **FrappeTestCase**: Inherit from `frappe.tests.utils.FrappeTestCase`
2. **setUp**: Always `frappe.set_user("Administrator")`
3. **tearDown**: Always `frappe.db.rollback()` (faster than delete)
4. **Test Structure**: `test_<what_is_tested>()`
5. **Validation**: `self.assertRaises(frappe.ValidationError, ...)`
6. **Permissions**: Test with `frappe.set_user("different_user")`
7. **TDD Flow**: Test → Fail → Code → Pass → Refactor

## Best Practices

- Use `FrappeTestCase` base class
- Rollback in `tearDown` (not delete)
- Use `frappe.get_doc()` for test data
- Test validation, permissions, edge cases
- Keep tests fast (< 1 second)
- Independent and idempotent tests
- Use `frappe.get_test_records()` for fixtures

## File Structure

```
app/
├── module/doctype/doctype_name/
│   └── test_doctype_name.py  # Unit tests
└── tests/
    ├── test_integration.py
    └── test_api.py
```

## Examples

**Simple Test**: See `projectnext/tests/test_materialmanagement.py`
**Complex Test**: See `projectnext/tests/test_material_allocation_request.py`
**Frappe Core**: See `frappe/tests/` for standard patterns

Remember: This skill is model-invoked. Use BDD only when explicitly requested.
