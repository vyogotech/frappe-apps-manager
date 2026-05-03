---
name: frappe-ui-testing
description: Implement end-to-end UI tests for Frappe applications using Cypress, utilizing custom commands and best practices.
---

# Frappe UI Testing with Cypress

Automate user interface testing for Frappe applications using Cypress. This skill covers custom Frappe commands, test structure, and execution patterns.

## When to Use

- Verifying complex UI workflows (Signup, Checkout, Form Submission)
- Testing Client Scripts and UI triggers
- Regressing testing UI components
- Validating permissions and role-based access in the Desk

## Core Patterns

### 1. Custom Frappe Commands

Frappe provides many built-in utilities in its JS layer, often extended in `cypress/support/commands.js`.

```javascript
// login
cy.login('Administrator', 'admin');

// Database Operations (Bypass UI for setup)
cy.insert_doc('Task', { subject: 'Test Task', status: 'Open' });
cy.get_doc('Task', 'TEST-TASK-001');
cy.remove_doc('Task', 'TEST-TASK-001');

// Form Interaction
cy.new_form('ToDo');
cy.fill_field('description', 'Test Description', 'Text Editor');
cy.get_field('status', 'Select').select('Closed');
cy.save();

// Navigation
cy.go_to_list('User');
cy.awesomebar('Project');
```

### 2. Test Structure

Organize tests in `cypress/integration/` or `cypress/e2e/`.

```javascript
context('Sales Order Flow', () => {
    before(() => {
        cy.login();
        cy.visit('/app');
    });

    it('creates a new sales order', () => {
        cy.visit('/app/sales-order/new');
        cy.fill_field('customer', 'Test Customer');
        
        // Fill child table
        cy.get('.grid-add-row').click();
        cy.fill_table_field('items', 1, 'item_code', 'Laptop');
        cy.fill_table_field('items', 1, 'qty', 1);
        
        cy.get('.primary-action').contains('Save').click();
        cy.get('.indicator-pill').should('contain', 'Draft');
    });
});
```

### 3. Common Utility Commands (from projectnext)

| Command | Usage |
| :--- | :--- |
| `cy.call(method, args)` | Call a white-listed Python method |
| `cy.get_list(dt, fields, filters)` | Fetch a list of records |
| `cy.set_value(dt, name, obj)` | Update a field value via API |
| `cy.click_action_button(name)` | Click buttons in the "Actions" menu |
| `cy.click_menu_button(name)` | Click items in the "Menu" (three dots) |
| `cy.click_modal_primary_button(text)` | Click the primary button in an open dialog |

### 4. Running Tests

Use the `bench` CLI to run tests.

```bash
# Run on a specific site
bench --site [sitename] run-ui-tests [app_name]

# Headless mode for CI
bench --site [sitename] run-ui-tests [app_name] --headless
```

## Key Patterns

1. **Setup in `before`**: Use `cy.login()` and setup required data using `cy.insert_doc()` to ensure a clean test state.
2. **Data-Field Selectors**: Prefer `[data-fieldname="xyz"]` over generic CSS selectors.
3. **Wait for State**: Use `cy.get('body').should('have.attr', 'data-ajax-state', 'complete')` to ensure Frappe has finished loading.
4. **Child Tables**: Use `cy.get_table_field()` or `cy.fill_table_field()` to interact with rows.

## Best Practices

- **Bypass UI for Setup**: Don't use the UI to create prerequisite data; use `cy.insert_doc()` or `cy.call()` instead.
- **Atomic Tests**: Each `it` block should be independent.
- **Custom Commands**: Encapsulate repetitive UI actions (like complex table filling) into custom commands in `commands.js`.
- **Assertions**: Assert not just the presence of elements, but also their state (e.g., `should('be.visible')`, `should('have.value', '...')`).

## Reference

- [Frappe UI Testing Docs](https://docs.frappe.io/framework/user/en/ui-testing)
- [Cypress Documentation](https://docs.cypress.io)

Remember: This skill is model-invoked. Claude will use it autonomously when writing or debugging Frappe E2E tests.
