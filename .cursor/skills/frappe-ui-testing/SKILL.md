---
name: frappe-ui-testing
description: Senior E2E Automation skill using Cypress, POM, and Figma validation for Frappe applications.
---

# Frappe UI Testing (Cypress & POM)

You are a Senior QA Automation Engineer. Use this skill to build reliable, maintainable E2E suites that catch real bugs in critical user journeys.

## Strategic E2E (The Pyramid)

- **Few & Critical**: Only automate "Happy Paths" and critical revenue flows (e.g., Checkout, Login, core DocType cycles).
- **Unit for Edge Cases**: Do not test complex logic or boundary values in UI tests; use `frappe-tdd-tests` for that.
- **Fast & Reliable**: Aim for < 5 min per suite. Fix or remove flaky tests immediately.

## Page Object Model (POM) Pattern

Encapsulate Frappe Desk/Form/List interactions into Page Objects to maintain abstraction.

```javascript
// cypress/support/pages/todo.page.js
export class ToDoPage {
  visit() { cy.visit('/app/todo'); }
  
  create(description) {
    cy.new_form('ToDo');
    cy.fill_field('description', description, 'Text Editor');
    cy.save();
  }
  
  should_have_status(status) {
    cy.get('.indicator-pill').should('contain', status);
  }
}
```

## Figma & Visual Validation

### Design Parity Checklist
Before marking a UI test as passed, verify against Figma specs:
- [ ] **Colors**: Match exact Hex codes from Figma.
- [ ] **Typography**: Font size, weight, and line-height parity.
- [ ] **Spacing**: Padding/Margins match the 8px grid system.
- [ ] **Responsive**: Check behavior on mobile presets (iPhone 14, etc.).

### Visual Regression (Manual/Automated)
```javascript
it('matches the visual baseline for the Dashboard', () => {
    cy.visit('/app/dashboard');
    // Using screenshot as a simple visual baseline
    cy.screenshot('dashboard-baseline');
});
```

## Core Frappe Commands (Review)

| Command | Strategic Use Case |
|---|---|
| `cy.login(user, pwd)` | Always use in `before()` or `beforeEach()`. |
| `cy.insert_doc(dt, data)` | **Bypass UI for setup**. Create prerequisites via API. |
| `cy.fill_field(name, val, type)` | Use `[data-fieldname]` selectors under the hood. |
| `cy.get_list(dt, filters)` | Verify state via API after a UI action. |

## Anti-Patterns to Avoid

- **Testing Everything**: Don't automate every single field validation in UI.
- **Hard-coded Waits**: Never use `cy.wait(5000)`. Use `cy.get(selector).should('be.visible')`.
- **No Cleanup**: Always ensure your test doesn't break the next one (idempotency).
- **Ignoring Console**: Always check `cy.window().then((win) => { ... })` for JS errors.

## Execution

```bash
# Run headless for CI
bench --site [sitename] run-ui-tests [app_name] --headless
```

---
**"Stable tests are better than many tests."**
