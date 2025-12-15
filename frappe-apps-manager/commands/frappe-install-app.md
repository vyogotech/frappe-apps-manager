---
description: Install a Frappe app to a site
---

# Frappe Install App Command

Install a Frappe application to a specific site:

1. **Verify bench directory**: Confirm we're in a Frappe bench directory
2. **List available apps**: Show apps that are available in the bench but may not be installed on the site
3. **List available sites**: Display all sites in the bench
4. **Get installation details**:
   - App name to install
   - Site name where the app should be installed
5. **Pre-installation checks**:
   - Verify the app exists in the bench
   - Verify the site exists
   - Check if the app is already installed (warn user)
6. **Install the app**: Run `bench --site <site-name> install-app <app-name>`
7. **Verify installation**:
   - Check that the app appears in the site's installed apps
   - Look for any error messages
8. **Post-installation**:
   - Suggest running migrations if needed
   - Recommend restarting bench
   - Provide next steps for using the app

**Error handling**: Provide clear error messages if installation fails, including common issues like missing dependencies or database connection problems.
