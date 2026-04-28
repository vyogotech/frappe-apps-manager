---
name: frappe-virtual-doctype
description: Guide for creating and implementing Virtual DocTypes in Frappe, where data is generated dynamically or fetched from an external API instead of the database.
---

# Frappe Virtual DocType

Create DocTypes where the data is not stored in the MariaDB/PostgreSQL database but is instead backed by a custom Python implementation. This is useful for exposing external APIs, system stats, or dynamically generated data as standard Frappe records.

## When to Use

- Integrating with external APIs and displaying the data in Frappe Desk.
- Aggregating data from multiple sources.
- Exposing system metrics or read-only operational data.
- When you want the standard Frappe List View, Form View, and Permissions applied to external data.

## Core Patterns

### 1. DocType JSON Configuration

To make a DocType virtual, you must set `"is_virtual": 1` in its JSON definition. Custom fields can still be defined as usual to map to the structure of your virtual data.

```json
{
  "doctype": "DocType",
  "name": "External User",
  "module": "Integration",
  "custom": 0,
  "is_virtual": 1,
  "fields": [
    {
      "fieldname": "id",
      "label": "ID",
      "fieldtype": "Data",
      "in_list_view": 1
    },
    {
      "fieldname": "username",
      "label": "Username",
      "fieldtype": "Data",
      "in_list_view": 1
    },
    {
      "fieldname": "email",
      "label": "Email",
      "fieldtype": "Data",
      "in_list_view": 1
    }
  ],
  "permissions": [
    {
      "role": "System Manager",
      "read": 1,
      "write": 1,
      "create": 1,
      "delete": 1
    }
  ]
}
```

### 2. Python Controller

For a Virtual DocType, Frappe expects the controller to override several core database methods. You must implement the data fetching and manipulation logic manually.

```python
import frappe
from frappe.model.document import Document
import requests

class ExternalUser(Document):
    def db_insert(self, *args, **kwargs):
        """Insert a new record into the external source."""
        # Example API call
        # response = requests.post("https://api.example.com/users", json=self.as_dict())
        # self.id = response.json().get("id")
        pass

    def db_update(self, *args, **kwargs):
        """Update an existing record in the external source."""
        pass

    def delete(self):
        """Delete the record from the external source."""
        pass

    @staticmethod
    def get_list(args):
        """
        Fetch a list of records for the List View or REST API.
        Must return a list of dictionaries or a list of lists.
        """
        start = args.get("start", 0)
        page_length = args.get("page_length", 20)
        
        # Example API call
        # response = requests.get(f"https://api.example.com/users?offset={start}&limit={page_length}")
        # return response.json()
        
        return [
            {"id": "1", "username": "john_doe", "email": "john@example.com"},
            {"id": "2", "username": "jane_doe", "email": "jane@example.com"}
        ]

    @staticmethod
    def get_count(args):
        """Return the total number of records for pagination."""
        # return int(requests.get("https://api.example.com/users/count").text)
        return 2

    @staticmethod
    def get_stats(args):
        """Return stats for the sidebar (optional but good for completeness)."""
        return {}
    
    @staticmethod
    def get_value(fields, filters, **kwargs):
        """
        Fetch a specific field value or multiple fields for a single record.
        Usually called by frappe.db.get_value().
        """
        # Parse filters to extract the ID and fetch from API
        # Return a single value if `fields` is a string, or a dict if `fields` is a list
        return None
```

## Key Patterns & Requirements

1. **`is_virtual: 1`**: Must be set in the DocType JSON.
2. **`get_list(args)`**: A `@staticmethod` that handles fetching data for List Views. The `args` dictionary contains pagination (`start`, `page_length`), `filters`, `fields`, and sorting (`order_by`).
3. **`get_count(args)`**: A `@staticmethod` that returns an integer representing the total count of records matching the filters. Essential for List View pagination.
4. **`db_insert`, `db_update`, `delete`**: Instance methods that handle mutations. If the virtual DocType is read-only, you can leave these as `pass` or raise a `frappe.PermissionError`.
5. **Data Mapping**: Ensure the keys in the dictionaries returned by `get_list` map exactly to the `fieldname`s defined in the DocType JSON.
## Best Practices

- **Read-only vs Read-Write**: If the external source is read-only, ensure you remove `write`, `create`, and `delete` permissions from the DocType JSON, or raise exceptions in `db_insert` and `db_update`.
- **Caching**: Network requests in `get_list` can slow down the List View. Consider using `frappe.cache()` to cache API responses if the data is not highly volatile.
- **Filter Handling**: Frappe passes filters to `get_list`. You should translate Frappe's SQL-like filters (`['name', '=', 'value']`) into the query parameters expected by your external API.
- **Authentication**: Store external API keys securely using the `Password` fieldtype in a separate Settings DocType, rather than hardcoding them in the controller.
- **Configuration**: Store URL or connection information API in a separate Settings DocType, rather than hardcoding them in the controller.