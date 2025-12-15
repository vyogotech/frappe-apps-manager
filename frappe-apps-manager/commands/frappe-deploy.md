---
description: Deploy Frappe apps to production environment
---

# Frappe Deploy Command

Guide deployment of Frappe applications to production:

1. **Pre-deployment checklist**:
   - Verify all changes are committed to git
   - Ensure migrations are tested
   - Check for breaking changes
   - Confirm backup exists
   - Review security settings
2. **Environment verification**:
   - Confirm target environment (staging/production)
   - Check SSH access to production server
   - Verify bench directory on production
3. **Deployment preparation**:
   - Ask about deployment method:
     - Git pull and migrate
     - Full bench update
     - Specific app update
   - Ask about downtime window
   - Confirm maintenance mode preference
4. **Deployment steps**:
   - Enable maintenance mode: `bench --site <site-name> set-maintenance-mode on`
   - Pull latest changes: `git pull` in app directory
   - Install dependencies: `bench setup requirements`
   - Run migrations: `bench --site <site-name> migrate`
   - Build assets: `bench build --app <app-name>`
   - Clear cache: `bench --site <site-name> clear-cache`
   - Restart services: `sudo supervisorctl restart all` or `bench restart`
   - Disable maintenance mode: `bench --site <site-name> set-maintenance-mode off`
5. **Post-deployment verification**:
   - Check site is accessible
   - Verify key functionality
   - Check error logs
   - Monitor performance
6. **Rollback plan**: Provide rollback instructions if issues occur:
   - Revert git commits
   - Restore from backup
   - Previous version migration

**Production safety**: Emphasize testing in staging first, backing up before deployment, and having a rollback plan ready.
