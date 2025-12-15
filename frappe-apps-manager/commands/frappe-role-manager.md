---
description: Manage user roles and permissions - create roles, assign permissions, manage access
---

# Frappe Role Manager Command

Comprehensive role and permission management for Frappe applications including role creation, permission assignment, and access control.

## Steps to Execute

### 1. Verify Environment
- Check if in valid Frappe bench
- Verify site exists
- Ensure user has System Manager role

### 2. Operation Selection

Ask user what they want to do:

**A. Create New Role**
- Define role name
- Set role permissions
- Assign to users

**B. Manage Permissions**
- View permission matrix
- Add/remove permissions
- Set permission levels

**C. Assign Roles to Users**
- Add roles to user
- Remove roles from user
- View user roles

**D. Test Permissions**
- Test user access to DocType
- Verify permission rules
- Debug permission issues

### 3. Role Creation

**Create New Role:**
```bash
bench --site [site-name] console
```

```python
# Create role
role = frappe.get_doc({
    'doctype': 'Role',
    'role_name': 'Custom Role',
    'desk_access': 1,  # Can access desk
    'disabled': 0
})
role.insert()
frappe.db.commit()
```

**Role Properties:**
- `role_name`: Unique role identifier
- `desk_access`: 1 = Can access desk, 0 = Portal only
- `two_factor_auth`: Require 2FA for this role
- `disabled`: 1 = Role disabled

### 4. Permission Management

**Add Permissions to DocType:**
```python
# Via console
from frappe.permissions import add_permission

add_permission('Customer', 'Custom Role', perm_level=0)

# Set specific permissions
add_permission('Customer', 'Custom Role',
    read=1, write=1, create=1, delete=0,
    submit=0, cancel=0, amend=0)

frappe.db.commit()
```

**View Permission Matrix:**
```python
# Get all permissions for DocType
permissions = frappe.get_all('Custom DocPerm',
    filters={'parent': 'Customer'},
    fields=['role', 'read', 'write', 'create', 'delete', 'submit']
)
print(permissions)
```

**Remove Permissions:**
```python
from frappe.permissions import remove_permission

remove_permission('Customer', 'Custom Role')
frappe.db.commit()
```

### 5. User Role Assignment

**Add Roles to User:**
```bash
bench --site [site-name] add-user-role user@example.com "Custom Role"
```

Or via console:
```python
user = frappe.get_doc('User', 'user@example.com')
user.add_roles('Custom Role', 'Sales User')
frappe.db.commit()
```

**Remove Roles:**
```python
user = frappe.get_doc('User', 'user@example.com')
user.remove_roles('Custom Role')
frappe.db.commit()
```

**View User Roles:**
```python
user = frappe.get_doc('User', 'user@example.com')
roles = [r.role for r in user.roles]
print(roles)
```

### 6. Permission Testing

**Test User Access:**
```python
# Set user context
frappe.set_user('user@example.com')

# Test read permission
can_read = frappe.has_permission('Customer', 'read')
print(f"Can read: {can_read}")

# Test write permission
can_write = frappe.has_permission('Customer', 'write')
print(f"Can write: {can_write}")

# Test specific document
can_access = frappe.has_permission('Customer', 'read', 'CUST-001')
print(f"Can access CUST-001: {can_access}")
```

**Debug Permission Issues:**
```python
# Get permission log
frappe.set_user('user@example.com')
try:
    doc = frappe.get_doc('Customer', 'CUST-001')
except frappe.PermissionError as e:
    print(f"Permission denied: {e}")
    print(frappe.get_traceback())
```

### 7. Advanced Permission Scenarios

**User Permissions (Restrict Access):**
```python
# Limit user to specific customer
from frappe.permissions import add_user_permission

add_user_permission('Customer', 'CUST-001', 'user@example.com')
frappe.db.commit()

# User can only access CUST-001
```

**Remove User Permission:**
```python
from frappe.permissions import remove_user_permission

remove_user_permission('Customer', 'CUST-001', 'user@example.com')
frappe.db.commit()
```

**View User Permissions:**
```python
perms = frappe.get_all('User Permission',
    filters={'user': 'user@example.com'},
    fields=['allow', 'for_value', 'applicable_for']
)
print(perms)
```

### 8. Permission Rules

**Set Field-Level Permissions:**
```python
# Make field read-only for specific role
# Edit DocType JSON or use Property Setter

frappe.make_property_setter({
    'doctype': 'Customer',
    'fieldname': 'credit_limit',
    'property': 'permlevel',
    'value': 1
})

# Set permission for level 1
add_permission('Customer', 'Sales Manager',
    perm_level=1, read=1, write=1)
```

**If Condition Permissions:**
```python
# Add permission with condition
# Via DocType permission editor or console

perm = frappe.get_doc({
    'doctype': 'Custom DocPerm',
    'parent': 'Sales Invoice',
    'parenttype': 'DocType',
    'role': 'Sales User',
    'if_owner': 1,  # Only if user created the doc
    'read': 1,
    'write': 1
})
perm.insert()
frappe.db.commit()
```

### 9. Role Hierarchy

**Standard Frappe Roles:**
```
System Manager (highest)
├── Administrator
├── All (all logged-in users)
├── Guest (not logged in)
└── Custom Roles
    ├── Sales Manager
    ├── Sales User
    ├── Purchase Manager
    ├── Purchase User
    ├── Stock Manager
    └── Stock User
```

**Check Role Hierarchy:**
```python
# Get roles for user including inherited
user_roles = frappe.get_roles('user@example.com')
print(user_roles)
```

### 10. Permission Reports

**Generate Permission Matrix:**
```python
# All permissions for DocType
matrix = frappe.db.sql("""
    SELECT
        role, read, write, create, delete,
        submit, cancel, amend
    FROM `tabCustom DocPerm`
    WHERE parent = %s
    ORDER BY permlevel, role
""", ('Customer',), as_dict=True)

for row in matrix:
    print(f"{row.role}: R={row.read} W={row.write} C={row.create}")
```

**User Access Report:**
```python
# All DocTypes accessible by user
frappe.set_user('user@example.com')
accessible = []

for doctype in frappe.get_all('DocType', pluck='name'):
    if frappe.has_permission(doctype, 'read'):
        accessible.append(doctype)

print(f"Accessible DocTypes: {accessible}")
```

## References

### Frappe Core Permission Examples (Primary Reference)

**Frappe Permission Module:**
- Permissions Core: https://github.com/frappe/frappe/blob/develop/frappe/permissions.py
- Has Permission: https://github.com/frappe/frappe/blob/develop/frappe/permissions.py#L50
- Permission Query: https://github.com/frappe/frappe/blob/develop/frappe/permissions.py#L300

**ERPNext Permission Patterns:**
- Sales Invoice Permissions: https://github.com/frappe/erpnext/blob/develop/erpnext/accounts/doctype/sales_invoice/sales_invoice.json
- Item Permissions: https://github.com/frappe/erpnext/blob/develop/erpnext/stock/doctype/item/item.json

**Real Permission Patterns:**

1. **Role-Based Access** (from Sales Invoice):
```json
{
  "permissions": [
    {
      "role": "Sales User",
      "read": 1,
      "write": 1,
      "create": 1
    },
    {
      "role": "Sales Manager",
      "read": 1,
      "write": 1,
      "create": 1,
      "delete": 1,
      "submit": 1,
      "cancel": 1
    },
    {
      "role": "Accounts User",
      "read": 1,
      "submit": 1
    }
  ]
}
```

2. **Owner-Only Access**:
```json
{
  "role": "Sales User",
  "if_owner": 1,
  "read": 1,
  "write": 1,
  "delete": 1
}
```

3. **Programmatic Permission Check** (from ERPNext):
```python
# See: erpnext/accounts/doctype/sales_invoice/sales_invoice.py
def has_permission(doc, ptype, user):
    if ptype == 'write' and doc.docstatus == 1:
        return False  # Cannot edit submitted docs
    return True
```

### Official Documentation (Secondary Reference)

- Permission System: https://frappeframework.com/docs/user/en/basics/users-and-permissions
- Role Permissions: https://frappeframework.com/docs/user/en/basics/users-and-permissions/role-based-permissions
- User Permissions: https://frappeframework.com/docs/user/en/basics/users-and-permissions/user-permissions

## Best Practices

1. **Principle of Least Privilege:** Grant minimum required permissions
2. **Role Hierarchy:** Use manager roles for elevated permissions
3. **Test Thoroughly:** Always test permissions with actual users
4. **Document Roles:** Clearly document role purposes
5. **Regular Audits:** Review permissions periodically
6. **User Permissions:** Use for data isolation (multi-tenant)
7. **Field-Level:** Use permission levels for sensitive fields
8. **If Owner:** Use for user-specific data access
9. **Submit/Cancel:** Restrict to manager roles
10. **Delete:** Restrict delete permissions carefully

## Security Considerations

- Never give delete permission to all users
- Restrict System Manager role to admins only
- Use User Permissions for data segregation
- Test permissions before deploying
- Review permission logs regularly
- Disable unused roles
- Set password policies
- Enable 2FA for sensitive roles
- Monitor permission changes
- Document permission schema

## Common Role Templates

**Sales Team:**
- Sales User: Create/read/write Sales documents
- Sales Manager: All Sales operations + submit/cancel

**Inventory Team:**
- Stock User: Create stock transactions
- Stock Manager: All stock operations + reports

**Accounts Team:**
- Accounts User: Create accounting entries
- Accounts Manager: All accounting + submit invoices

**Support Team:**
- Support User: Read-only access to customer data
- Support Manager: Create/update support tickets

## Important Notes

- Permissions cached - clear cache after changes
- User Permissions restrict data access
- Role Permissions grant capabilities
- Combine both for fine-grained control
- Permission check happens on every database read
- Custom permissions via `has_permission` method
- Test with actual users, not Administrator
- Document your permission model
