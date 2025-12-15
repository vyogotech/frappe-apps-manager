---
description: View and analyze Frappe bench logs with filtering and search capabilities
---

# Frappe Logs Command

View, filter, and analyze Frappe bench logs including web server, background workers, scheduler, and error logs.

## Steps to Execute

### 1. Verify Bench Environment
- Check if current directory is a valid Frappe bench
- Look for `logs/` directory
- Verify log files exist

### 2. Determine Log Type to View

Ask user which logs to view:

**A. Web Server Logs**
- `logs/web.log` - Werkzeug development server logs
- `logs/web.error.log` - Web server error logs
- Shows HTTP requests, responses, errors

**B. Worker Logs**
- `logs/worker.log` - Background job worker logs
- `logs/worker.error.log` - Worker errors
- Shows async task execution

**C. Scheduler Logs**
- `logs/schedule.log` - Scheduled task logs
- Shows cron job execution

**D. Site-specific Logs**
- `sites/[site-name]/logs/` - Per-site logs
- Request logs, error logs

**E. All Logs**
- View combined logs from all sources

### 3. Log Viewing Options

Offer filtering and display options:

**Time-based:**
- Last N lines (default: 50)
- Last N minutes/hours
- Specific time range
- Real-time tail (follow mode)

**Level-based:**
- ERROR only
- WARNING and above
- INFO and above
- DEBUG (all logs)

**Pattern-based:**
- Search for specific text/pattern
- Filter by DocType name
- Filter by user
- Filter by IP address

### 4. Execute Log Viewing

Based on user choice, execute appropriate command:

**View Recent Web Logs:**
```bash
tail -n 50 logs/web.log
```

**View Error Logs Only:**
```bash
tail -n 100 logs/web.error.log
```

**Follow Logs in Real-time:**
```bash
tail -f logs/web.log
```

**Search for Specific Pattern:**
```bash
grep "pattern" logs/web.log | tail -n 50
```

**View Logs with Timestamps:**
```bash
tail -n 50 logs/web.log | grep -E '^\[.*\]'
```

**Multiple Log Files:**
```bash
tail -n 20 logs/web.log logs/worker.log logs/schedule.log
```

### 5. Format Log Output

Parse and display logs in readable format:

**Standard Format:**
```
[2025-12-15 14:30:45] ERROR: ValidationError in Document Customer
  File: frappe/model/document.py, Line: 234
  User: user@example.com
  Message: Email is required
```

**Structured Display:**
- Timestamp
- Log level (ERROR, WARNING, INFO)
- Module/File
- Line number
- User (if applicable)
- Error message
- Stack trace (for errors)

### 6. Analyze Common Errors

Identify and highlight common error patterns:

**Database Errors:**
- Connection failures
- Deadlocks
- Query timeouts
- Foreign key violations

**Permission Errors:**
- Access denied
- Missing permissions
- Role restrictions

**Validation Errors:**
- Required field missing
- Invalid values
- Duplicate entries

**API Errors:**
- 404 Not Found
- 500 Internal Server Error
- Authentication failures

### 7. Provide Error Context

For each error found:
- Show surrounding log lines
- Identify related errors
- Link to relevant code (if possible)
- Suggest potential fixes

### 8. Log Statistics

Generate summary statistics:

**Error Count by Type:**
```
ValidationError: 15
PermissionError: 8
DatabaseError: 3
TimeoutError: 1
```

**Error Frequency Timeline:**
```
14:00-14:30: 5 errors
14:30-15:00: 12 errors
15:00-15:30: 2 errors
```

**Top Error Sources:**
```
1. frappe.model.document (10 errors)
2. erpnext.accounts.doctype.sales_invoice (5 errors)
3. custom_app.api (3 errors)
```

### 9. Advanced Log Analysis

Offer advanced analysis:

**Trace Request Flow:**
- Follow a specific request through logs
- Show all log entries for a request ID
- Reconstruct request timeline

**Performance Analysis:**
- Identify slow requests (> 1 second)
- Database query performance
- API endpoint response times

**User Activity:**
- Filter logs by specific user
- Show user's actions
- Track user sessions

### 10. Log Management

Provide log management options:

**Archive Old Logs:**
```bash
# Rotate logs
bench --site [site-name] rotate-logs

# Archive logs older than 30 days
find logs/ -name "*.log" -mtime +30 -exec gzip {} \;
```

**Clear Logs:**
```bash
# Clear specific log
> logs/web.log

# Clear all logs (with confirmation)
rm logs/*.log
```

**Export Logs:**
```bash
# Export filtered logs
grep "ERROR" logs/web.log > error_report.txt

# Export with timestamp range
awk '/2025-12-15 14:00/,/2025-12-15 15:00/' logs/web.log > incident_logs.txt
```

## Log File Reference

### Core Frappe Log Files

**Development Logs:**
```
logs/
├── web.log              # Werkzeug dev server logs
├── web.error.log        # Web server errors
├── worker.log           # Background worker logs
├── worker.error.log     # Worker errors
├── schedule.log         # Scheduled tasks
└── redis_cache.log      # Redis cache operations
```

**Production Logs (with Nginx/Supervisor):**
```
logs/
├── nginx-access.log     # Nginx access logs
├── nginx-error.log      # Nginx errors
├── frappe-web.log       # Gunicorn web logs
├── frappe-worker.log    # RQ worker logs
└── supervisor.log       # Supervisor process logs
```

**Site-specific Logs:**
```
sites/[site-name]/
├── logs/
│   ├── request.log      # HTTP request logs
│   └── error.log        # Site-specific errors
└── site_config.json
```

### Log Format Examples

**Web Server Log Entry:**
```
[2025-12-15 14:30:45,123] INFO in app: 127.0.0.1 - - [15/Dec/2025 14:30:45] "GET /api/resource/Customer/CUST-001 HTTP/1.1" 200 -
```

**Error Log Entry:**
```
[2025-12-15 14:30:45] ERROR:
Traceback (most recent call last):
  File "frappe/app.py", line 82, in application
    response = frappe.api.handle()
  File "frappe/api.py", line 51, in handle
    return frappe.handler.handle()
ValidationError: Email is required in row 1
```

**Worker Log Entry:**
```
[2025-12-15 14:30:45] INFO Worker rq:worker:worker-1 started
[2025-12-15 14:30:46] INFO Job frappe.email.queue.flush queued
[2025-12-15 14:30:47] INFO Job frappe.email.queue.flush finished
```

## Common Log Patterns

### Database Connection Issues

**Pattern:**
```
ERROR: could not connect to server: Connection refused
ERROR: OperationalError: (2002, "Can't connect to local MySQL server")
```

**Solution:**
- Check if MySQL/MariaDB is running
- Verify database credentials in site_config.json
- Check database port accessibility

### Permission Denied Errors

**Pattern:**
```
PermissionError: You need {permission} permission for {doctype}
frappe.exceptions.PermissionError: Insufficient Permission for Customer
```

**Solution:**
- Check user roles: `bench --site [site] console`
- Review permission rules in DocType
- Add required roles to user

### Import/Export Failures

**Pattern:**
```
ERROR in import: frappe.exceptions.DataImportError
ERROR: Duplicate entry 'CUST-001' for key 'PRIMARY'
```

**Solution:**
- Check data format
- Verify unique constraints
- Use ignore_if_duplicate flag

## References

### Frappe Core Log Examples (Primary Reference)

**Frappe Logging Implementation:**
- Frappe Logger: https://github.com/frappe/frappe/blob/develop/frappe/utils/logger.py
- Log Configuration: https://github.com/frappe/frappe/blob/develop/frappe/utils/data.py
- Error Handler: https://github.com/frappe/frappe/blob/develop/frappe/app.py

**ERPNext Logging Patterns:**
- Sales Invoice Logging: https://github.com/frappe/erpnext/blob/develop/erpnext/accounts/doctype/sales_invoice/sales_invoice.py
- Stock Entry Logging: https://github.com/frappe/erpnext/blob/develop/erpnext/stock/doctype/stock_entry/stock_entry.py

**Real Logging Examples from Core:**

1. **Custom Logger Usage** (from Frappe Core):
```python
# See: frappe/utils/logger.py
import frappe
from frappe.utils.logger import get_logger

logger = get_logger("my_app")
logger.info("Processing started")
logger.error("Error occurred", exc_info=True)
```

2. **Error Context Logging** (from ERPNext):
```python
# See: erpnext/accounts/doctype/payment_entry/payment_entry.py
try:
    doc.submit()
except Exception as e:
    frappe.log_error(
        title="Payment Entry Submission Failed",
        message=frappe.get_traceback()
    )
```

3. **Debug Logging** (from Frappe Core):
```python
# See: frappe/integrations/doctype/webhook/webhook.py
if frappe.conf.developer_mode:
    frappe.logger().debug(f"Webhook payload: {payload}")
```

### Official Documentation (Secondary Reference)

- Logging Guide: https://frappeframework.com/docs/user/en/debugging
- Bench Logs: https://frappeframework.com/docs/user/en/bench/reference/logs
- Error Handling: https://frappeframework.com/docs/user/en/api/exceptions

## Advanced Log Analysis

### Using Python for Log Analysis

**Parse Logs with Python:**
```python
import re
from datetime import datetime

# Parse Frappe log entries
log_pattern = r'\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\] (\w+): (.+)'

with open('logs/web.log', 'r') as f:
    for line in f:
        match = re.match(log_pattern, line)
        if match:
            timestamp, level, message = match.groups()
            if level == 'ERROR':
                print(f"{timestamp}: {message}")
```

### Real-time Log Monitoring

**Monitor Multiple Logs:**
```bash
# Watch all error logs
watch -n 1 'tail -n 5 logs/*.error.log'

# Monitor specific pattern
tail -f logs/web.log | grep --line-buffered "ERROR"

# Colored output
tail -f logs/web.log | grep --color=always -E "ERROR|WARNING|$"
```

### Log Aggregation

**Combine and Sort Logs:**
```bash
# Merge logs by timestamp
cat logs/web.log logs/worker.log | sort

# Count errors by type
grep "ERROR" logs/*.log | cut -d: -f3 | sort | uniq -c | sort -rn
```

## Performance Monitoring

### Identify Slow Requests

**Find Slow API Calls:**
```bash
# Look for requests taking > 1 second
grep "completed in" logs/web.log | awk '$NF > 1.0'
```

**Database Query Performance:**
```bash
# Find slow queries in logs
grep "query took" logs/web.log | sort -k4 -rn | head -20
```

### Memory and Resource Usage

**Monitor Worker Memory:**
```bash
# Check worker logs for memory issues
grep -i "memory" logs/worker.log
```

## Important Notes

- Logs rotate automatically based on size/time
- Old logs are compressed (`.gz`) to save space
- Production logs may be managed by logrotate
- Sensitive data (passwords, tokens) are typically masked
- Enable developer mode for verbose logging
- Use log levels appropriately (DEBUG in dev, INFO+ in prod)

## Troubleshooting Guide

**No logs appearing:**
- Check bench is running
- Verify log directory permissions
- Enable logging in site_config.json

**Logs too verbose:**
- Adjust log level in site_config.json
- Disable developer mode
- Use log filtering

**Disk space issues:**
- Enable log rotation
- Archive old logs
- Increase log rotation frequency
