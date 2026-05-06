---
name: frappe-portal-generator
description: Generate and configure Frappe Portal pages, web routes, and dynamic content. Use when building public websites, customer portals, or custom web views.
---

# Frappe Portal Generator

Create and manage the public-facing side of Frappe applications, including web pages, routes, and portal configurations.

## When to Use

- Building a customer or supplier portal
- Creating dynamic web pages from DocTypes (Generators)
- Setting up custom web routes and redirects
- Configuring portal sidebar and menu items
- Building public-facing landing pages

## Core Patterns

### 1. Web Page (Static)

Create a `.html` and `.py` (optional for logic) in the `www/` directory of your app.

**`www/hello.html`**:
```html
{% extends "templates/web.html" %}

{% block page_content %}
<h1>Hello {{ user_name }}!</h1>
<p>Welcome to our portal.</p>
{% endblock %}
```

**`www/hello.py`**:
```python
import frappe

def get_context(context):
    context.user_name = frappe.session.user
```

### 2. Generator (Dynamic Routes)

Used to create a web page for every record of a DocType.

In `doctype_name.py`:
```python
from frappe.website.website_generator import WebsiteGenerator

class MyDocType(WebsiteGenerator):
    def get_context(self, context):
        # Custom logic for the web page
        pass
```

In `doctype_name.json`:
- Set `has_web_view: 1`
- Set `route` field or logic

### 3. Portal Menu (hooks.py)

```python
portal_menu_items = [
    {"title": "My Tasks", "route": "/tasks", "role": "Customer"},
    {"title": "Profile", "route": "/profile", "role": "All"}
]
```

### 4. Custom Web Form (Portal)

While `frappe-web-form-builder` handles the form, the portal generator integrates it into the site navigation and layout.

## Best Practices

1. **Template Inheritance**: Always extend `templates/web.html` for a consistent look and feel.
2. **Context Management**: Use `get_context` to pass data from Python to Jinja templates.
3. **SEO**: Utilize `google_analytics_id` and meta tags in your web pages.
4. **Permissions**: Use `frappe.has_permission` within `get_context` to ensure portal security.
5. **Caching**: Understand how Frappe caches web pages and use `frappe.clear_cache()` when updating templates.

Remember: This skill is model-invoked. Claude will use it autonomously when detecting requirements for web-facing features or portal development.
