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
5. **Generate Containerfile** (if user wants containerization):
   - Use `frappe-containerfile-generator` skill
   - Generate Containerfile based on version-15 template
   - Place in app root directory
   - Use app name in paths and configurations

6. **Generate compose.yml** (if user wants local development):
   - Use `frappe-compose-dev-generator` skill
   - Generate compose.yml using vyogo's sne images
   - Configure volume mounts for hot-reload
   - Place in app root directory

7. **Post-creation steps**:
   - Ask if they want to install the app to a site immediately
   - Ask if they want containerization files (Containerfile, compose.yml)
   - Suggest next steps: creating DocTypes, pages, or custom scripts
   - Provide guidance on the app structure
   - If containerization files were created, provide usage instructions

**Important**: 
- Ensure all prompts are interactive and user-friendly
- Validate app names to ensure they follow Python package naming conventions
- When generating containerization files, automatically use the app name from step 2
- For Containerfile, use version-15 pattern by default (ask for version if needed)
- For compose.yml, use vyogo's sne-version-15 image by default
