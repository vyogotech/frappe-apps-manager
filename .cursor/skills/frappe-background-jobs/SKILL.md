---
name: frappe-background-jobs
description: Manage background jobs and scheduled tasks in Frappe using frappe.enqueue and Python RQ. Use when implementing long-running tasks, email queues, or periodic data processing.
---

# Frappe Background Jobs

Implement and manage asynchronous tasks and scheduled jobs in the Frappe Framework.

## When to Use

- Processing large datasets without blocking the UI
- Sending bulk emails
- Integrating with external APIs that have high latency
- Running periodic cleanup or maintenance tasks
- Offloading heavy computations from the request-response cycle

## Core Patterns

### 1. Enqueueing a Job

```python
import frappe

# Simple enqueue
frappe.enqueue(
    'my_app.tasks.process_data',
    queue='long',
    timeout=600,
    data=data_object
)

# Enqueue with document context
frappe.enqueue(
    'my_app.tasks.generate_report',
    queue='default',
    doc=doc,
    user=frappe.session.user
)
```

### 2. Job Queues

- **`short`**: Tasks taking < 2 minutes
- **`default`**: Tasks taking 2-10 minutes
- **`long`**: Tasks taking up to 30 minutes

### 3. Scheduled Tasks (Hooks)

In `hooks.py`:

```python
scheduler_events = {
    "all": [
        "my_app.tasks.all"
    ],
    "daily": [
        "my_app.tasks.daily_cleanup"
    ],
    "hourly": [
        "my_app.tasks.hourly_update"
    ],
    "weekly": [
        "my_app.tasks.weekly_report"
    ],
    "monthly": [
        "my_app.tasks.monthly_billing"
    ],
    "cron": {
        "0 0 * * *": [
            "my_app.tasks.midnight_job"
        ]
    }
}
```

### 4. Handling Job Failure

```python
def process_data(data):
    try:
        # Business logic here
        pass
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Background Job Failed")
        # Optional: Notify user or retry logic
```

## Best Practices

1. **Keep it Idempotent**: Jobs should be safe to run multiple times.
2. **Atomic Operations**: Use `frappe.db.commit()` only when necessary and understand its impact on background jobs.
3. **Monitor Queues**: Use `bench worker` to manage workers and `frappe.get_all("Scheduled Job Log")` to monitor scheduled tasks.
4. **Avoid Large Objects**: Pass document names (IDs) instead of full document objects when possible.
5. **Set Timeouts**: Always specify a `timeout` for jobs that might run longer than the default.

Remember: This skill is model-invoked. Claude will use it autonomously when detecting background processing or scheduling requirements.
