---
name: frappe-database-orm
description: >
  Use when reading or writing Frappe data safely — get_doc, get_all, get_list, frappe.db.get_value,
  parameterized frappe.db.sql, transactions, bulk ops, and performance. Prevents SQL injection and
  permission leaks from wrong API choice.
  Covers ORM reads/writes, raw SQL, transactions, bulk_update, N+1 avoidance.
  Keywords: frappe.db.sql, frappe.get_all, get_value, set_value, bulk update, N+1, db transaction,
  get_list, SQL injection, parameterized query.
license: MIT
compatibility: "Claude Code, Claude.ai Projects, Claude API. Frappe v14-v16."
metadata:
  author: sbknext
  version: "1.0"
---

# Frappe Database / ORM

Prefer the ORM; drop to SQL only when needed, and only parameterized.

Cross-ref: `frappe-syntax-query-builder` (frappe.qb deep dive), `frappe-errors-database` (debugging).

---

## Quick Reference

| Need | API | Permissions |
|------|-----|-------------|
| Full document | `frappe.get_doc(dt, name)` | Checks read |
| One field, fast | `frappe.db.get_value(dt, name, field)` | No check |
| List (server-side) | `frappe.get_all(...)` | **Ignores** user perms |
| List (user-facing) | `frappe.get_list(...)` | **Enforces** user perms |
| Single field write, no hooks | `frappe.db.set_value(...)` | No lifecycle |
| Full lifecycle write | `doc.save()` | Runs validate/hooks |
| Complex dynamic SQL | `frappe.qb` or `%s` parameterized SQL | — |

---

## Reads

```python
frappe.get_doc("Sales Order", "SO-0001")                    # full document (all children)
frappe.db.get_value("Sales Order", "SO-0001", "status")     # one field, fast
frappe.db.get_value("Sales Order", {"customer": "ACME"}, ["name", "status"], as_dict=True)
frappe.get_all("Sales Order",
    filters={"status": "Draft", "grand_total": [">", 1000]},
    fields=["name", "customer", "grand_total"],
    order_by="creation desc", limit=50)
frappe.get_list(...)   # same, but enforces the current user's permissions
```

`get_all` ignores user permissions (use server-side); `get_list` enforces them (use for user-facing).

## Writes

```python
frappe.db.set_value("Sales Order", "SO-0001", "status", "Closed")          # single field, no hooks
doc = frappe.get_doc("Sales Order", "SO-0001"); doc.status = "Closed"; doc.save()  # runs validate/hooks
frappe.db.set_value("Sales Order", {"customer": "ACME"}, "hold", 1)        # by filter
```

`db.set_value` skips controller hooks/validation — fast but bypasses business logic. `doc.save()`
runs the full lifecycle. Choose deliberately.

## Raw SQL — parameterized ONLY

```python
# RIGHT — %s placeholders
rows = frappe.db.sql("""
    SELECT customer, SUM(grand_total) AS total
    FROM `tabSales Order` WHERE status = %s AND company = %s
    GROUP BY customer
""", ("Draft", company), as_dict=True)

# WRONG — string interpolation = SQL injection
frappe.db.sql(f"... WHERE name = '{name}'")     # NEVER
```

Escape identifiers/values with `frappe.db.escape(value)` when you must build dynamically.

## Transactions

```python
frappe.db.savepoint("before_bulk")
try:
    ...
    frappe.db.commit()
except Exception:
    frappe.db.rollback(save_point="before_bulk")
```

Web requests auto-commit on success / rollback on exception. Background jobs must commit explicitly.

## Bulk update (v14+)

Update many documents in one SQL statement — skips controller hooks/validation:

```python
frappe.db.bulk_update(
    "Task",
    {
        "TASK-0001": {"status": "Closed"},
        "TASK-0002": {"status": "Open"},
    },
    chunk_size=200,
    update_modified=True,
)
```

Use when you need speed and know lifecycle hooks are not required.

## v16 `get_list` / `run=False` change

Prior to v16, `run=False` on `get_list` returned a SQL string. From v16 it returns a Query Builder object — call `.get_sql()` for the string or mutate before `.run()`.

## Transaction hooks (v15+)

```python
frappe.db.after_commit.add(my_func)
frappe.db.after_rollback.add(cleanup_func)
```

## frappe.qb.get_query (preferred for complex queries)

```python
query = frappe.qb.get_query("Sales Order",
    fields=["name", "customer.customer_name as customer_name",
            {"items": ["item_code", "qty"]}],
    filters={"docstatus": 1, "items.item_code": "ITEM-001"},
    limit=50)
rows = query.run(as_dict=True)
```

Use `ignore_permissions=False` when the query serves user-facing data. Use `for_update=True` for row locking.

## Performance

- Avoid **N+1**: fetch with one `get_all(filters={"parent": ["in", names]})` instead of looping `get_doc`.
- Select only the `fields` you need — never pull whole docs to read one column.
- Add DB indexes on hot filter/join columns (`search_index: 1` on the field, or a migration).
- For large bulk writes use `frappe.db.bulk_insert` / batched `set_value`, and commit periodically.

## Rules

- Never f-string/`%`-format values into `frappe.db.sql` — always `%s` params.
- `get_all` vs `get_list` — know which one applies permissions.
- `db.set_value`/`db.delete` skip hooks; use `doc.save()`/`doc.delete()` when lifecycle matters.
- Web requests auto-commit on successful POST/PUT; GET does not commit. Background jobs auto-commit on success.
- Rarely call `frappe.db.commit()` manually — exception: flush writes before `enqueue_after_commit` reads them.

## From Frappe docs

- Database API: https://docs.frappe.io/framework/user/en/api/database
- Query Builder: https://docs.frappe.io/framework/user/en/api/query-builder

---

*Contributed from sbknext/forge-frappe-skill (MIT) — https://github.com/sbknext/forge-frappe-skill*
