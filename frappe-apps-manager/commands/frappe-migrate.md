---
description: Run database migrations for Frappe apps
---

# Frappe Migrate Command

Execute database migrations for Frappe applications:

1. **Verify bench directory**: Confirm we're in a Frappe bench
2. **List sites**: Show all available sites in the bench
3. **Get migration details**:
   - Site name (or option to migrate all sites)
   - Specific app to migrate (optional - if empty, migrate all apps)
4. **Pre-migration checks**:
   - Backup database (ask user for confirmation)
   - Check for pending patches
   - Verify database connectivity
5. **Show migration plan**: Display what will be migrated:
   - Apps that have pending migrations
   - Number of patches to be applied
   - Schema changes if detectable
6. **Run migration**: Execute the appropriate command:
   - `bench --site <site-name> migrate` for specific site
   - `bench --site all migrate` for all sites
   - `bench --site <site-name> migrate --app <app-name>` for specific app
7. **Post-migration**:
   - Display migration summary
   - Check for any errors or warnings
   - Suggest clearing cache: `bench --site <site-name> clear-cache`
   - Recommend rebuilding search index if needed
8. **Rollback information**: Provide guidance on how to rollback if issues occur

**Safety**: Always emphasize the importance of backups before migrations, especially in production environments.
