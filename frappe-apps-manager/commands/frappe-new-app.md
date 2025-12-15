---
description: Create a new Frappe application with proper structure
---

# Frappe New App Command

Create a new Frappe application following best practices:

1. **Verify bench directory**: Check if the current directory is a Frappe bench or ask the user for the bench path
2. **Ask for app details**:
   - App name (will be converted to snake_case)
   - App title (human-readable name)
   - App description
   - Publisher name
   - Email
3. **Create the app**: Run `bench new-app <app-name>` with the provided details
4. **Verify structure**: Check that the app was created with proper structure:
   - `<app-name>/__init__.py`
   - `<app-name>/hooks.py`
   - `<app-name>/modules.txt`
   - `<app-name>/patches.txt`
   - `setup.py`
5. **Post-creation steps**:
   - Ask if they want to install the app to a site immediately
   - Suggest next steps: creating DocTypes, pages, or custom scripts
   - Provide guidance on the app structure

**Important**: Ensure all prompts are interactive and user-friendly. Validate app names to ensure they follow Python package naming conventions.
