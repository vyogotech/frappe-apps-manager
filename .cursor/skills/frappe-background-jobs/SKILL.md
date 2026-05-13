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

## Decision Tree & Reference

### Choosing execution model

```
Need periodic execution?
├─ Fixed interval (hourly / daily / weekly / monthly)
│  → scheduler_events in hooks.py (parameterless handlers)
├─ Custom schedule
│  → scheduler_events["cron"] in hooks.py (croniter-compatible expressions)
├─ User-configurable interval
│  → Scheduled Job Type DocType
└─ No — triggered by user / event / code
   ├─ Method on a specific document → frappe.enqueue_doc(...)
   ├─ Standalone function async → frappe.enqueue(...)
   └─ From Document controller → self.queue_action(...)
```

**Main fork: `scheduler_events` vs `frappe.enqueue`**

| Aspect | scheduler_events | frappe.enqueue |
|--------|------------------|----------------|
| Trigger | Time / interval | Code execution |
| Definition | hooks.py | Call site |
| Arguments | NONE (handlers must be parameterless) | Serializable kwargs |
| Typical use | Maintenance, sync on a schedule | User-triggered or event-driven async work |

### Which scheduler hook key?

| Need | Event key | Default queue implication |
|------|-----------|---------------------------|
| Every scheduler tick (`all`: v14 ~240s, v15+ ~60s) | `all` | default — keep handler very short |
| Hourly | `hourly` / `hourly_long` | Use `*_long` if work can exceed ~5 minutes |
| Daily | `daily` / `daily_long` | Same |
| Weekly | `weekly` / `weekly_long` | Same |
| Monthly | `monthly` / `monthly_long` | Same |
| Custom timing | `"cron": { "expr": [...] }` | Put heavy work in `_long` or enqueue from thin handler |

**Built-in scheduler_events keys**: `all`, `hourly`, `daily`, `weekly`, `monthly`, `hourly_long`, `daily_long`, `weekly_long`, `monthly_long`, plus `cron` mapping expressions to dotted task paths.

### Queue names and timeouts (`frappe.enqueue`)

| Queue | Default timeout | Use when |
|-------|-----------------|----------|
| `short` | 300s (5 min) | Very quick tasks (order of seconds) |
| `default` | 300s (5 min) | Routine background work (~30s–5 min) |
| `long` | 1500s (25 min) | Heavy work up to ~25 min |
| Custom `timeout=` | Overrides queue default | Longer jobs; split work >25 min into chained batches |

```python
# Common parameters (subset)
frappe.enqueue(
    method,                      # required: callable or "dotted.module.path"
    queue="default",             # "short", "default", "long", or custom
    timeout=None,               # seconds; overrides queue default
    is_async=True,               # False = synchronous path
    now=False,                   # True = frappe.call()-style immediate run
    job_id=None,                 # [v15+] deduplication key
    enqueue_after_commit=False, # wait for DB commit before enqueue (e.g. after save)
    at_front=False,
    on_success=None,
    on_failure=None,
    **kwargs,                    # forwarded to target
)
```

Cron field layout (croniter-compatible): `minute hour day-of-month month day-of-week`.

| Symbol | Meaning | Example |
|--------|---------|---------|
| `*` | any | run every occurrence of that field |
| `,` | list | `1,15` in minute = minutes 1 and 15 |
| `-` | range | `9-17` in hour |
| `/` | step | `*/10` every 10 units of that field |

Common examples: every 5 min `*/5 * * * *`; weekdays 09:00 `0 9 * * 1-5`; monthly 1st `0 0 1 * *`.

### ALWAYS / NEVER (consolidated)

- **ALWAYS** run `bench migrate` after any `scheduler_events` change so registration updates.
- **ALWAYS** treat scheduled handlers as Administrator context; set `owner` / permissions explicitly when creating docs.
- **ALWAYS** use `enqueue` (or `enqueue_doc` / `queue_action`) for heavy work; keep scheduler entry points thin.
- **ALWAYS** use `job_id` with `frappe.utils.background_jobs.is_job_enqueued(job_id)` for deduplication on v15+ user-triggered jobs.
- **ALWAYS** pick queue and optional `timeout` from expected duration; specify `queue=` explicitly in new code (do not rely on implicit defaults alone).
- **ALWAYS** use try/except with clear logging for batch/async work so one failure does not silently drop others.
- **NEVER** add parameters to scheduler hook targets — use settings, env, or DB reads instead.
- **NEVER** use deprecated **`job_name`** for deduplication in new code; use **`job_id`** [v15+].
- **NEVER** run long or CPU-heavy logic directly inside frequent `all`/tick handlers — enqueue downstream jobs.
