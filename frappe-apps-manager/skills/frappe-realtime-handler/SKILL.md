---
name: frappe-realtime-handler
description: Implement real-time communication in Frappe using Socket.io. Use for live updates, progress bars, notifications, and collaborative features.
---

# Frappe Real-time Handler

Enable real-time data push from server to client and pub/sub events in the Frappe Framework.

## When to Use

- Live dashboards and status updates
- Showing progress of background jobs
- Real-time notifications to specific users
- Collaborative editing indicators
- Chat or messaging features

## Core Patterns

### 1. Server-side Publish

```python
import frappe

# Publish to all users
frappe.publish_realtime('event_name', {'data': 'value'})

# Publish to a specific user
frappe.publish_realtime('event_name', {'data': 'value'}, user='test@example.com')

# Publish to a specific document (room)
frappe.publish_realtime('event_name', {'data': 'value'}, doctype='Task', docname='TASK-001')
```

### 2. Client-side Listener

```javascript
// Listen for global events
frappe.realtime.on('event_name', (data) => {
    console.log(data);
});

// Listen for document-specific events
frappe.realtime.on('doctype_event_name', (data) => {
    // Handle update
});
```

### 3. Progress Bar Pattern

**Server:**
```python
def long_task():
    for i in range(100):
        # Do work
        frappe.publish_realtime('task_progress', {
            'progress': i + 1,
            'total': 100,
            'message': f'Processing {i+1} of 100'
        })
```

**Client:**
```javascript
frappe.realtime.on('task_progress', (data) => {
    frappe.show_progress(data.message, data.progress, data.total);
});
```

## Best Practices

1. **Payload Size**: Keep real-time messages small. Pass IDs or small objects rather than large datasets.
2. **Frequency**: Avoid flooding the socket with too many events per second.
3. **Security**: Be careful with sensitive data in global events. Use the `user` or `doctype` parameters to scope messages.
4. **Cleanup**: Unsubscribe from events if using them in custom pages or components to prevent memory leaks.
5. **Namespace**: Use clear, descriptive event names to avoid collisions.

Remember: This skill is model-invoked. Claude will use it autonomously when detecting requirements for live updates or real-time feedback.
