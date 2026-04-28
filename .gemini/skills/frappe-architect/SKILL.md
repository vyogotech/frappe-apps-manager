---
name: frappe-architect
description: Architectural guidelines and best practices for designing Frappe applications, data modeling, and integrations.
---

# Frappe Architect

Architectural guidelines and decision-making frameworks for Frappe ecosystems.

## When to Use

- Designing system architecture and boundaries.
- Deciding between patterns for data modeling and external integrations.
- Structuring microservices vs monolithic apps.
- Designing the user experience and navigation for new custom apps.

## Architectural Principles

### 1. The Frappe Design Decision Tree
When mapping business requirements to technical implementation, evaluate options in the following order of preference to maintain a clean and maintainable architecture:

1.  **Reuse Existing DocTypes:** Always look for existing standard Frappe/ERPNext DocTypes (e.g., Customer, Sales Invoice, Item) that fit the business need before creating anything new.
2.  **Extend DocTypes:** If an existing DocType is close but missing fields, extend it using **Custom Fields** and **Property Setters** rather than duplicating the DocType.
3.  **Build Virtual DocTypes:** When integrating with external APIs where Frappe acts as a UI or a bridge, use **Virtual DocTypes** (`is_virtual: 1`). Do not copy data from external systems of record into Frappe standard DocTypes just to display it. Virtual DocTypes prevent data duplication, avoid complex synchronization logic, and ensure data is always real-time.
4.  **Custom Code / New DocTypes:** Only build entirely new standard (database-backed) DocTypes or custom integration logic when the requirement involves completely new domain entities that must be persisted and queried heavily within the Frappe ecosystem.

### 2. User Experience & Analytics (New Apps)
When designing a new custom app, you must provide a complete user experience out-of-the-box. Do not just create DocTypes; ensure users can navigate and analyze the data effectively:
-   **Workspaces:** Create dedicated Workspaces to group related DocTypes, reports, and settings. This is the primary entry point for users navigating your app.
-   **Dashboards & Charts:** Define standard Dashboard Charts (e.g., Number Cards, Time Series) to provide immediate analytical value. Link these to the Workspace.
-   **Quick Lists:** Configure Quick Lists on the Workspace so users can see recent or important records at a glance without navigating to the full List View.

### 3. Bounded Contexts
Ensure each microservice owns its own data. Do not share databases directly across microservices. Services should communicate via well-defined REST APIs or message queues.

### 4. Multi-Tenancy
When building microservices that interact with a central Frappe Site, ensure strict multi-tenancy. Use the `TenantAwareDB` pattern to automatically filter queries by `tenant_id` and validate sessions against the central site.

### 5. Data Duplication vs Virtualization
Avoid copying data from a system of record into Frappe unless Frappe needs to run complex relational SQL queries or aggregate reports on that data locally. If Frappe is simply a UI or pass-through for the data, Virtualization is the correct architectural choice.
