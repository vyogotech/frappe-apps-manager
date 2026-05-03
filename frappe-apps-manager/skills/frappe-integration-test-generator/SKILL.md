---
name: frappe-integration-test-generator
description: Generate integration tests for multi-DocType workflows and distributed services in Frappe.
---

# Frappe Integration Test Generator

Build robust integration tests that validate the interaction between multiple DocTypes, Background Jobs, and external Microservices.

## Test Data Builder Pattern

Avoid messy `setUp` methods by using dedicated builder functions or the "Object Mother" pattern to create consistent test data.

```python
class TestDataBuilder:
    @staticmethod
    def create_customer(name="_Test Customer"):
        if not frappe.db.exists("Customer", name):
            return frappe.get_doc({
                "doctype": "Customer",
                "customer_name": name,
                "customer_group": "All Customer Groups",
                "territory": "All Territories"
            }).insert(ignore_permissions=True)
        return frappe.get_doc("Customer", name)

    @staticmethod
    def create_item(item_code="_Test Item"):
        # ... logic to create item with default warehouse ...
```

## Distributed Service & Health Checks

When testing integrations with external services (e.g., a Go-based Cloud Agent), verify the "Distributed Health" of the system.

```python
class TestMicroserviceIntegration(FrappeTestCase):
    def test_service_health(self):
        """Verify the external service is reachable before running tests"""
        from frappe.utils.commands import run_command
        # Example: check if a sidecar service is responsive
        response = frappe.make_get_request("http://cloud-agent:8080/health")
        self.assertEqual(response.get("status"), "UP")

    def test_distributed_transaction(self):
        """Test if a DocType change propagates to the external service"""
        doc = frappe.get_doc({"doctype": "K8s Cluster", "cluster_name": "Test"}).insert()
        # Wait for background job or async event
        frappe.db.commit() 
        # Verify side-effect in external system
        self.assertTrue(self._check_external_state("Test"))
```

## Workflow State Validation

Ensure state transitions are atomic and consistent across the testing pyramid.

| Step | Action | Expected State |
|---|---|---|
| 1 | Create Draft | `docstatus == 0` |
| 2 | Trigger Workflow | `status == "Pending Approval"` |
| 3 | Submit | `docstatus == 1` and Linked Docs Created |

## Best Practices

- **Idempotency**: Tests should be runnable multiple times on the same site without conflict (use `frappe.db.rollback()` or unique naming).
- **Background Jobs**: Use `frappe.enqueue` with `now=frappe.flags.in_test` to test async logic synchronously.
- **Sidecar Validation**: If your app depends on Redis or Socket.io, include a "Sanity Test" in your suite.
