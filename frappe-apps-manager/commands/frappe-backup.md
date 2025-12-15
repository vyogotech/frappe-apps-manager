---
description: Backup Frappe site data and files
---

# Frappe Backup Command

Create comprehensive backups of Frappe sites:

1. **Verify bench directory**: Ensure we're in a Frappe bench
2. **List sites**: Display all available sites
3. **Get backup details**:
   - Site name to backup
   - Backup type (database only, files only, or both)
   - Whether to include private files
   - Whether to include public files
   - Compression preference
4. **Backup options**: Explain and offer:
   - Regular backup: `bench --site <site-name> backup`
   - With files: `bench --site <site-name> backup --with-files`
   - Verbose output: Add `--verbose` flag
   - Backup to specific path: `--backup-path-db` and `--backup-path-files`
5. **Execute backup**: Run the selected backup command
6. **Verify backup**: Check that backup files were created:
   - Database backup (.sql.gz)
   - Private files backup (if requested)
   - Public files backup (if requested)
7. **Display backup information**:
   - Backup file locations
   - Backup file sizes
   - Timestamp of backup
   - Retention policy reminder
8. **Post-backup suggestions**:
   - Recommend offsite backup storage
   - Suggest automated backup scheduling
   - Provide restore command reference
   - Mention S3/cloud backup options

**Best practices**: Remind users about the 3-2-1 backup rule and the importance of testing restore procedures.
