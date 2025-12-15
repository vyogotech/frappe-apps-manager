---
description: Start Frappe bench with proper configuration
---

# Frappe Bench Start Command

Start the Frappe bench development server with appropriate configuration:

1. **Verify bench directory**: Ensure we're in a valid Frappe bench directory
2. **Check for running processes**: Look for any existing bench processes and warn the user
3. **Configuration options**: Ask the user about startup preferences:
   - Port number (default: 8000)
   - Whether to run in debug mode
   - Whether to use a specific site
   - Whether to enable auto-reload
4. **Pre-start checks**:
   - Verify Redis is running
   - Check MariaDB/PostgreSQL connection
   - Ensure all required services are available
5. **Start bench**: Run the appropriate command:
   - `bench start` for full stack (web, worker, socketio, schedule)
   - `bench serve` for just the web server
   - `bench --site <site-name> serve` for specific site
6. **Post-start information**:
   - Display the URL where the site is accessible
   - Show how to access different sites
   - Provide instructions for stopping the server
   - Mention how to view logs

**Additional tips**: Inform users about common development workflows like running background workers separately, using VS Code debugger, or accessing the desk.
