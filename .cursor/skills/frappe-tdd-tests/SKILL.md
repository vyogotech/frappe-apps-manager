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

    def tearDown(self):
        frappe.db.rollback()

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
from frappe_microservice.controller import DocumentController
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

    def test_before_insert_sets_defaults(self):
        doc = frappe.get_doc({"doctype": "Sales Order", "customer": "CUST-001"})
        controller = SalesOrder(doc)
        controller.before_insert()
        self.assertEqual(doc.status, "Draft")

    def test_attribute_sync(self):
        doc = frappe.get_doc({"doctype": "Sales Order", "customer": "CUST-001"})
        controller = SalesOrder(doc)
        controller.status = "Confirmed"
        self.assertEqual(doc.status, "Confirmed")

    def test_has_value_changed(self):
        doc = frappe.get_doc({"doctype": "Sales Order", "status": "Draft"})
        doc._doc_before_save = frappe._dict(status="Draft")
        controller = SalesOrder(doc)
        self.assertFalse(controller.has_value_changed("status"))
        doc.status = "Confirmed"
        self.assertTrue(controller.has_value_changed("status"))
```

### 3. TenantAwareDB Tests

```python
from unittest.mock import MagicMock, patch
from frappe_microservice.tenant import TenantAwareDB

class TestTenantAwareDB(FrappeTestCase):
    def setUp(self):
        self.get_tenant = MagicMock(return_value="tenant-001")
        self.db = TenantAwareDB(self.get_tenant)

    def test_add_tenant_filter_none(self):
        result = self.db._add_tenant_filter(None)
        self.assertEqual(result, {"tenant_id": "tenant-001"})

    def test_add_tenant_filter_dict(self):
        result = self.db._add_tenant_filter({"status": "Draft"})
        self.assertEqual(result, {"status": "Draft", "tenant_id": "tenant-001"})

    def test_add_tenant_filter_string(self):
        result = self.db._add_tenant_filter("SO-001")
        self.assertEqual(result, {"name": "SO-001", "tenant_id": "tenant-001"})

    def test_add_tenant_filter_list(self):
        result = self.db._add_tenant_filter([["status", "=", "Draft"]])
        self.assertEqual(result, [["status", "=", "Draft"], ["tenant_id", "=", "tenant-001"]])

    def test_no_tenant_raises(self):
        db = TenantAwareDB(MagicMock(return_value=None))
        with self.assertRaises(ValueError):
            db._add_tenant_filter(None)

    def test_system_tenant_rejected(self):
        db = TenantAwareDB(MagicMock(return_value="SYSTEM"))
        with self.assertRaises(ValueError):
            db._add_tenant_filter(None)
```

### 4. Microservice API Tests (Flask test_client)

```python
from unittest.mock import patch, MagicMock

class TestAPIEndpoints(FrappeTestCase):
    def setUp(self):
        frappe.set_user("Administrator")
        from server import app
        self.app = app
        self.client = app.flask_app.test_client()

    def tearDown(self):
        frappe.db.rollback()

    def test_health_endpoint(self):
        response = self.client.get('/health')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data['status'], 'healthy')

    def test_requires_authentication(self):
        response = self.client.get('/api/resource/Sales Order')
        self.assertEqual(response.status_code, 401)

    @patch.object(MagicMock, '_validate_session')
    def test_with_valid_session(self, mock_validate):
        mock_validate.return_value = ("user@example.com", None)
        with patch.object(self.app, '_validate_session', mock_validate):
            response = self.client.get('/api/resource/Sales Order')
            self.assertIn(response.status_code, [200, 401])
```

### 5. DocumentHooks Tests

```python
from frappe_microservice.hooks import DocumentHooks

class TestDocumentHooks(FrappeTestCase):
    def test_register_and_run(self):
        hooks = DocumentHooks()
        called = []

        def handler(doc):
            called.append(doc.name)

        hooks.register('Sales Order', 'before_insert', handler)

        doc = frappe._dict(doctype='Sales Order', name='SO-001')
        hooks.run_hooks(doc, 'before_insert')
        self.assertEqual(called, ['SO-001'])

    def test_global_hooks_run_first(self):
        hooks = DocumentHooks()
        order = []

        hooks.register('*', 'before_insert', lambda doc: order.append('global'))
        hooks.register('Sales Order', 'before_insert', lambda doc: order.append('specific'))

        doc = frappe._dict(doctype='Sales Order', name='SO-001')
        hooks.run_hooks(doc, 'before_insert')
        self.assertEqual(order, ['global', 'specific'])

    def test_error_handling(self):
        hooks = DocumentHooks()
        hooks.register('Sales Order', 'validate', lambda doc: (_ for _ in ()).throw(Exception("fail")))

        doc = frappe._dict(doctype='Sales Order', name='SO-001')
        with self.assertRaises(Exception):
            hooks.run_hooks(doc, 'validate', raise_on_error=True)
```

### 6. ControllerRegistry Tests

```python
from frappe_microservice.controller import ControllerRegistry, DocumentController

class TestControllerRegistry(FrappeTestCase):
    def test_register_and_get(self):
        registry = ControllerRegistry()

        class MyController(DocumentController):
            pass

        registry.register('My DocType', MyController)
        self.assertTrue(registry.has_controller('My DocType'))
        self.assertEqual(registry.get_controller('My DocType'), MyController)

    def test_list_controllers(self):
        registry = ControllerRegistry()

        class OrderCtrl(DocumentController):
            pass

        registry.register('Sales Order', OrderCtrl)
        result = registry.list_controllers()
        self.assertEqual(result, {'Sales Order': 'OrderCtrl'})

    def test_filename_to_doctype(self):
        registry = ControllerRegistry()
        self.assertEqual(registry._filename_to_doctype('sales_order'), 'Sales Order')

    def test_filename_to_classname(self):
        registry = ControllerRegistry()
        self.assertEqual(registry._filename_to_classname('sales_order'), 'SalesOrder')
```

### 7. BDD Tests (Optional -- use when explicitly requested)

```python
from pytest_bdd import given, when, then, scenario

@scenario('api_tests.feature', 'Create order')
def test_create_order():
    pass

@given('I am authenticated')
def authenticated():
    return cookies

@when('I create order with customer "<customer>"')
def create_order(authenticated, customer):
    return response

@then('order should be created')
def verify_order(create_order):
    assert create_order.status_code == 201
```

## Test Configuration

**Pytest** (recommended for microservices):
```ini
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
markers =
    unit: Unit tests
    integration: Integration tests
```

**Frappe Bench**:
```bash
bench --site <site> run-tests --app <app>
bench --site <site> run-tests --app <app> --coverage
```

## Key Patterns

1. **FrappeTestCase**: Inherit from `frappe.tests.utils.FrappeTestCase`
2. **setUp**: Always `frappe.set_user("Administrator")`
3. **tearDown**: Always `frappe.db.rollback()` (faster than delete)
4. **Mock MicroserviceApp**: Use `unittest.mock` for `_validate_session`, `tenant_db`, etc.
5. **Test TenantAwareDB**: Mock `get_tenant_id` function, test filter injection
6. **Test Controllers**: Instantiate with mock doc, call lifecycle methods
7. **Test Hooks**: Use `DocumentHooks` directly, verify registration and execution order
8. **TDD Flow**: Test → Fail → Code → Pass → Refactor

## Best Practices

- Use `FrappeTestCase` base class
- Rollback in `tearDown` (not delete)
- Test validation, permissions, edge cases
- Keep tests fast (< 1 second)
- Independent and idempotent tests
- Use `frappe.get_test_records()` for fixtures
- Mock external dependencies (Central Site, Redis)

Remember: This skill is model-invoked. Use BDD only when explicitly requested.
