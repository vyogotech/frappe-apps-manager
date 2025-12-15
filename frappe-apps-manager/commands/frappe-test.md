---
description: Run unit and integration tests for Frappe apps with coverage reports
---

# Frappe Test Command

Execute comprehensive tests for Frappe applications including unit tests, integration tests, and generate coverage reports.

## Steps to Execute

### 1. Verify Test Environment
- Check if current directory is a valid Frappe bench
- Verify bench command is available
- Check if site exists for testing
- Ensure test dependencies are installed:
  ```bash
  pip install coverage pytest
  ```

### 2. Determine Test Scope
Ask user what they want to test:

**A. Specific DocType**
- App name
- Module name
- DocType name
- Example: `test_[doctype_name].py`

**B. Specific App**
- App name only
- Tests all modules in the app

**C. All Apps**
- Run complete test suite
- May take significant time

**D. Specific Test File/Function**
- Full path to test file
- Optional: specific test function name

### 3. Test Execution Options

Offer test configuration options:

**Basic Options:**
- `--verbose`: Show detailed test output
- `--failfast`: Stop on first failure
- `--profile`: Profile test execution time

**Coverage Options:**
- `--coverage`: Generate coverage report
- `--html-coverage`: Generate HTML coverage report
- Coverage threshold (warning if below X%)

**Test Filtering:**
- Run specific test methods
- Skip certain tests
- Test by markers/tags

### 4. Run Tests

Execute appropriate test command based on scope:

**Test Specific DocType:**
```bash
bench --site [site-name] run-tests \
  --app [app-name] \
  --doctype "[DocType Name]" \
  [--verbose] \
  [--coverage]
```

**Test Specific App:**
```bash
bench --site [site-name] run-tests \
  --app [app-name] \
  [--module [module-name]] \
  [--verbose] \
  [--coverage]
```

**Test All Apps:**
```bash
bench --site [site-name] run-tests \
  [--verbose] \
  [--coverage]
```

**Test Specific File:**
```bash
bench --site [site-name] run-tests \
  --test [path/to/test_file.py] \
  [--verbose]
```

**Test with Coverage:**
```bash
bench --site [site-name] run-tests \
  --app [app-name] \
  --coverage \
  --coverage-report-html
```

### 5. Monitor Test Execution

Display progress information:
- Number of tests running
- Current test being executed
- Pass/fail status in real-time
- Execution time per test (if --profile enabled)

### 6. Analyze Test Results

After test completion, show:

**Test Summary:**
- Total tests run
- Tests passed ✓
- Tests failed ✗
- Tests skipped ⊘
- Execution time

**Failed Test Details:**
For each failed test:
- Test name and location
- Failure reason/assertion
- Stack trace
- Error message

**Coverage Report (if enabled):**
```
Name                                    Stmts   Miss  Cover
-----------------------------------------------------------
my_app/my_module/doctype/my_doctype.py    150     20    87%
my_app/api.py                              80     10    88%
-----------------------------------------------------------
TOTAL                                     230     30    87%
```

### 7. HTML Coverage Report

If HTML coverage requested, generate and show:
```bash
# Coverage report location
frappe-bench/sites/coverage_html/index.html

# Open in browser (offer to open)
xdg-open sites/coverage_html/index.html
```

### 8. Test Debugging Assistance

If tests fail, offer debugging help:

**Common Issues:**
- Missing test data/fixtures
- Database state issues
- Permission problems
- Import errors
- Timing/race conditions

**Debugging Commands:**
```bash
# Run single test with pdb
bench --site [site-name] run-tests --test [test-file] --pdb

# Run tests with logging
bench --site [site-name] run-tests --app [app-name] --verbose

# Check test data
bench --site [site-name] console
```

### 9. Continuous Testing Options

Suggest setting up continuous testing:

**Watch Mode:**
```bash
# Re-run tests on file changes (if using pytest-watch)
ptw -- bench --site [site-name] run-tests --app [app-name]
```

**Pre-commit Hooks:**
```bash
# Add to .git/hooks/pre-commit
#!/bin/bash
bench --site test_site run-tests --app my_app --failfast
```

### 10. Test Report Export

Offer to export test results:

**JUnit XML (for CI/CD):**
```bash
bench --site [site-name] run-tests \
  --app [app-name] \
  --junit-xml test-results.xml
```

**JSON Report:**
```bash
bench --site [site-name] run-tests \
  --app [app-name] \
  --json-report test-results.json
```

## Test Best Practices

### Writing Good Tests

**Test Structure:**
```python
import frappe
import unittest

class TestMyDocType(unittest.TestCase):
    def setUp(self):
        """Set up test fixtures"""
        frappe.set_user("Administrator")

    def tearDown(self):
        """Clean up after test"""
        frappe.db.rollback()

    def test_creation(self):
        """Test DocType creation"""
        doc = frappe.get_doc({
            "doctype": "My DocType",
            "field1": "value1"
        })
        doc.insert()
        self.assertEqual(doc.field1, "value1")

    def test_validation(self):
        """Test validation logic"""
        doc = frappe.get_doc({
            "doctype": "My DocType",
            "field1": ""  # Required field
        })
        self.assertRaises(frappe.ValidationError, doc.insert)
```

**Test Categories:**
- Unit tests: Test individual methods
- Integration tests: Test DocType workflows
- API tests: Test API endpoints
- UI tests: Test client-side scripts

### Test Data Management

**Using Fixtures:**
```python
def setUp(self):
    # Load test fixtures
    frappe.get_test_records("Item")
    frappe.get_test_records("Customer")
```

**Creating Test Data:**
```python
def create_test_customer(self):
    customer = frappe.get_doc({
        "doctype": "Customer",
        "customer_name": "Test Customer",
        "customer_type": "Company"
    })
    customer.insert(ignore_if_duplicate=True)
    return customer
```

## Error Handling

### Common Test Errors:

**"No module named 'coverage'"**
- Install: `pip install coverage`

**"Site does not exist"**
- Create test site: `bench new-site test_site`
- Or specify existing site

**"Permission Error"**
- Tests run as Administrator by default
- Check role permissions in test setup

**"Database Errors"**
- Ensure test database is clean
- Use rollback in tearDown
- Check foreign key constraints

**"Import Error"**
- App not installed on test site
- Module path incorrect
- Missing dependencies

## Performance Tips

### Speed Up Tests

**Use Transaction Rollback:**
```python
def tearDown(self):
    frappe.db.rollback()  # Faster than deleting records
```

**Parallel Testing (Experimental):**
```bash
bench --site [site-name] run-tests --app [app-name] --parallel
```

**Skip Slow Tests in Development:**
```python
@unittest.skip("Slow integration test")
def test_complex_workflow(self):
    pass
```

**Use Test Markers:**
```python
@pytest.mark.slow
def test_heavy_operation(self):
    pass

# Run only fast tests
pytest -m "not slow"
```

## References

### Frappe Core App Examples (Primary Reference)

**Learn from Frappe Framework Tests:**
- Frappe Core Tests: https://github.com/frappe/frappe/tree/develop/frappe/tests
  - `test_db.py` - Database testing patterns
  - `test_document.py` - DocType testing
  - `test_permissions.py` - Permission testing
  - `test_api.py` - API endpoint testing
- Frappe Test Utilities: https://github.com/frappe/frappe/blob/develop/frappe/tests/utils.py
- Frappe Test Base Class: https://github.com/frappe/frappe/blob/develop/frappe/tests/test_runner.py

**ERPNext Test Examples:**
- ERPNext Tests: https://github.com/frappe/erpnext/tree/develop/erpnext/tests
- Accounting Tests: https://github.com/frappe/erpnext/tree/develop/erpnext/accounts/doctype
  - `sales_invoice/test_sales_invoice.py` - Transaction testing
  - `payment_entry/test_payment_entry.py` - Complex workflows
- Stock Tests: https://github.com/frappe/erpnext/tree/develop/erpnext/stock/doctype
  - `stock_entry/test_stock_entry.py` - Inventory testing
  - `item/test_item.py` - Master data testing

**Real Test Patterns from Core Apps:**

1. **Transaction Testing** (from Sales Invoice):
```python
# See: erpnext/accounts/doctype/sales_invoice/test_sales_invoice.py
def test_sales_invoice_with_discount(self):
    si = frappe.copy_doc(test_records[0])
    si.discount_amount = 104.95
    si.append("items", {
        "item_code": "_Test Item",
        "qty": 10,
        "rate": 100
    })
    si.insert()
    si.submit()
    self.assertEqual(si.total, 1000)
    self.assertEqual(si.grand_total, 895.05)
```

2. **Permission Testing** (from Frappe Core):
```python
# See: frappe/tests/test_permissions.py
def test_user_permissions(self):
    frappe.set_user("test@example.com")
    # Test read permission
    doc = frappe.get_doc("DocType Name", "DOC-001")
    # Test write permission
    doc.field = "new_value"
    doc.save()
```

3. **API Testing** (from Frappe Core):
```python
# See: frappe/tests/test_api.py
def test_api_call(self):
    from frappe.handler import execute_cmd
    frappe.set_user("Administrator")
    response = execute_cmd("my_app.api.method_name")
    self.assertEqual(response["status"], "success")
```

### Official Documentation (Secondary Reference)

- Testing Guide: https://frappeframework.com/docs/user/en/testing
- Test Runner CLI: https://frappeframework.com/docs/user/en/bench/reference/bench-cli#run-tests
- Python unittest: https://docs.python.org/3/library/unittest.html

## CI/CD Integration

### GitHub Actions Example:
```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Bench
        run: |
          # Setup Frappe bench
          bench init frappe-bench
          cd frappe-bench
          bench new-site test_site
          bench --site test_site install-app my_app
      - name: Run Tests
        run: |
          cd frappe-bench
          bench --site test_site run-tests \
            --app my_app \
            --coverage \
            --junit-xml test-results.xml
      - name: Publish Test Results
        uses: EnricoMi/publish-unit-test-result-action@v1
        if: always()
        with:
          files: frappe-bench/test-results.xml
```

## Advanced Testing

### API Testing:
```python
def test_api_endpoint(self):
    response = frappe.get_doc({
        "doctype": "Integration Request",
        "integration_type": "Remote",
        "url": "/api/method/my_app.api.get_data"
    })
    self.assertEqual(response.status_code, 200)
```

### Performance Testing:
```python
def test_query_performance(self):
    import time
    start = time.time()

    # Run query
    frappe.db.get_all("Item", limit=1000)

    duration = time.time() - start
    self.assertLess(duration, 1.0)  # Should complete in < 1 second
```

### Mock Testing:
```python
from unittest.mock import patch

def test_with_mock(self):
    with patch('frappe.sendmail') as mock_email:
        # Test email sending without actually sending
        doc.send_notification()
        mock_email.assert_called_once()
```

## Test Organization

**Recommended Structure:**
```
my_app/
├── my_module/
│   └── doctype/
│       └── my_doctype/
│           ├── my_doctype.py
│           ├── my_doctype.json
│           ├── my_doctype.js
│           └── test_my_doctype.py  ← Unit tests
├── tests/
│   ├── __init__.py
│   ├── test_integration.py        ← Integration tests
│   └── test_api.py                ← API tests
└── fixtures/
    └── test_data.json             ← Test fixtures
```

## Important Notes

- Always use a separate test site (never production!)
- Tests should be independent and idempotent
- Use setUp and tearDown for clean test state
- Mock external services and APIs
- Keep tests fast (< 1 second per test)
- Aim for 80%+ code coverage
- Write tests for bug fixes
- Run tests before committing code
