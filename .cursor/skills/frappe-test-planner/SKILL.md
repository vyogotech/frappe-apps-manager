---
name: frappe-test-planner
description: Generate comprehensive test plans, manual test cases, regression test suites, and bug reports for Frappe applications.
---

# Frappe Test Planner

A specialized skill for creating structured testing deliverables within the Frappe ecosystem. It ensures that testing is strategic, traceable, and focused on high-risk business logic.

## Core Deliverables

### 1. Test Plans
- **Scope**: What features and DocTypes are in/out of scope.
- **Strategy**: Manual vs. Automated mix based on the Testing Pyramid.
- **Criteria**: Clear entry/exit criteria (e.g., "90% coverage on backend controllers").
- **Risks**: Probability/Impact matrix for feature failures.

### 2. Manual Test Cases
Use this format for features not yet automated or too complex for E2E:
```markdown
## TC-[ID]: [Title]
**Priority**: High | Medium | Low
**Preconditions**: [e.g., User with 'System Manager' role]
**Steps**:
1. [Action] -> **Expected**: [Result]
2. [Action] -> **Expected**: [Result]
**Test Data**: [Sample JSON or CSV]
```

### 3. Regression Suites
- **Smoke Suite**: 5-10 tests covering login, core dashboard, and primary DocType creation.
- **Critical Path**: End-to-end flows like "Lead to Quotation" or "Issue to Resolution".

### 4. Bug Reports
Always include:
- **Environment**: Frappe/ERPNext version, Branch, Site Config.
- **Reproduction Steps**: Precise sequence to trigger the bug.
- **Visual Evidence**: Console logs, screenshots, or tracebacks.

## Frappe-Specific Verification

**Design Validation (Figma)**:
- [ ] Field layout matches Figma mockup.
- [ ] Sidebar and Dashboard widgets have correct icons/colors.
- [ ] Client Script behaviors (e.g., dynamic field hiding) match UI-UX spec.

**Data Integrity**:
- [ ] DocType triggers (`before_insert`, `on_update`) handle null values.
- [ ] Permissions (Role Permissions Manager) enforced correctly.
- [ ] Naming Series logic generates expected IDs.

## Test Planning Anti-Patterns

- **Missing Edge Cases**: Only testing the "Happy Path".
- **Vague Steps**: "Check if it works" is not a test step.
- **No Cleanup**: Leaving thousands of test records in the site.
- **Ignoring Hooks**: Forgetting to test how the feature interacts with global `hooks.py`.
