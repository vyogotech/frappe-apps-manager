---
description: Create a new DocType in a Frappe app
---

# Frappe New DocType Command

Create a new DocType with proper configuration:

1. **Verify environment**: Ensure we're in a Frappe bench directory
2. **Get DocType details**:
   - App name where DocType should be created
   - DocType name (will be in Title Case)
   - Module name (must exist in the app)
   - Is it a single DocType? (Single/submittable/standard)
   - Is it submittable?
   - Is naming automatic or based on a field?
3. **DocType configuration**:
   - Ask about common fields to add:
     - Naming series
     - Status field
     - Common fields (customer, company, etc.)
   - Ask about permissions (which roles should have access)
   - Track changes option
   - Quick entry option
4. **Create the DocType**: Use one of these approaches:
   - Via desk: Guide user to create via UI (recommended for complex DocTypes)
   - Via JSON: Create the JSON file directly in the app
   - Via bench console: Use Python script to create programmatically
5. **Add common fields**: If user wants, add standard fields:
   - Naming Series
   - Status (Draft, Submitted, Cancelled)
   - Amended From (for submittable docs)
   - Company (for multi-company setups)
6. **Set up permissions**: Create basic permission rules
7. **Post-creation steps**:
   - Run `bench --site <site-name> migrate` to sync DocType
   - Suggest creating related DocTypes (child tables, etc.)
   - Provide guidance on adding controller methods
   - Mention form scripts and customizations

**Development tips**: Explain DocType naming conventions, field types, and best practices for controller development.
