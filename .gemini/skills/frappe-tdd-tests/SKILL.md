---
name: Generate TDD Tests
description: Enforce the Iron Law of TDD for Frappe apps. Red-Green-Refactor cycle for DocTypes and Controllers.
---

# Generate TDD Tests (Iron Law)

"Write the test first. Watch it fail. Write minimal code to pass."

## The Iron Law

**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

If you write code before the test: **Delete it. Start over.** This is non-negotiable.

## Red-Green-Refactor Cycle

### 1. RED: Write Failing Test
Write one minimal test showing what should happen. Use `FrappeTestCase`.

```python
import frappe
from frappe.tests.utils import FrappeTestCase

class TestSalesOrder(FrappeTestCase):
    def test_status_must_be_draft_on_creation(self):
        # We wish for this behavior
        doc = frappe.get_doc({"doctype": "Sales Order", "customer": "Test Customer"})
        self.assertEqual(doc.status, "Draft")
```

**Verify RED**: Run `bench --site [site] run-tests --doctype "Sales Order"`. 
- **Must Fail**: If it passes, you are testing existing behavior. Fix the test.
- **Expected Failure**: Confirm it fails because `doc.status` is NOT "Draft".

### 2. GREEN: Minimal Code
Write the simplest code in the controller (`sales_order.py`) to pass the test.

```python
class SalesOrder(Document):
    def before_insert(self):
        self.status = "Draft"
```

**Verify GREEN**: Run the test again. It must pass.

### 3. REFACTOR: Clean Up
Clean up duplication, improve names, or extract helpers while keeping the test Green.

## Frappe Test Patterns

### Validation Tests
```python
def test_customer_is_mandatory(self):
    doc = frappe.get_doc({"doctype": "Sales Order", "customer": None})
    self.assertRaises(frappe.ValidationError, doc.insert)
```

### Permission Tests
```python
def test_regular_user_cannot_submit(self):
    frappe.set_user("regular_user@example.com")
    doc = frappe.get_doc("Sales Order", "SO-001")
    self.assertRaises(frappe.PermissionError, doc.submit)
```

### Mocking (Use only if unavoidable)
Prefer real data using `frappe.get_doc`. If you must mock external APIs:
```python
from unittest.mock import patch

@patch('frappe.make_get_request')
def test_api_integration(self, mock_get):
    mock_get.return_value = {"status": "success"}
    # ... call your method ...
```

## Anti-Patterns

| Avoid | Why | Instead |
|---|---|---|
| **Test After** | Fails to prove the test actually works. | **Test First**. |
| **Manual Cleanup** | Error-prone and slow. | Use `frappe.db.rollback()` in `tearDown`. |
| **Huge Setups** | Makes tests hard to read. | Use `frappe.get_test_records()`. |
| **Mocking Frappe** | Mocks don't test the DB state. | Use the real `frappe.db` in `FrappeTestCase`. |

## Checklist

- [ ] Every new function has a test.
- [ ] Watched each test fail for the right reason.
- [ ] Minimal code written to pass.
- [ ] `tearDown` performs rollback or cleanup.
- [ ] Edge cases (None, Empty, Invalid) covered.
