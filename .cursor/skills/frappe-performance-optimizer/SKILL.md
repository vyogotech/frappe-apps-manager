---
name: frappe-performance-optimizer
description: Generate optimized queries, caching, and indexes for Frappe performance. Use when optimizing slow queries, implementing caching, or improving performance.
---

# Frappe Performance Optimizer

Generate performance-optimized code including efficient queries, caching strategies, and database indexes for Frappe applications.

## When to Use This Skill

Claude should invoke this skill when:
- User reports slow queries or performance issues
- User wants to add caching
- User needs database indexing
- User mentions performance, optimization, or slow queries
- User wants to eliminate N+1 queries

## Capabilities

### 1. Query Optimization

**Optimized Report Query:**
```python
# Efficient query with proper indexing
def get_sales_summary(from_date, to_date):
    return frappe.db.sql("""
        SELECT
            si.customer,
            c.customer_name,
            c.customer_group,
            COUNT(si.name) as invoice_count,
            SUM(si.grand_total) as total_amount
        FROM `tabSales Invoice` si
        INNER JOIN `tabCustomer` c ON c.name = si.customer
        WHERE si.posting_date BETWEEN %s AND %s
            AND si.docstatus = 1
        GROUP BY si.customer
        ORDER BY total_amount DESC
        LIMIT 100
    """, (from_date, to_date), as_dict=True)

# Add index for performance
frappe.db.add_index('Sales Invoice', ['customer', 'posting_date', 'docstatus'])
```

### 2. Caching Implementation

**Cache Expensive Calculations:**
```python
def get_item_price(item_code, price_list, customer=None):
    """Get price with caching"""
    cache_key = f"price:{item_code}:{price_list}:{customer or 'default'}"

    # Try cache
    cached_price = frappe.cache().get_value(cache_key)
    if cached_price is not None:
        return cached_price

    # Calculate price (expensive)
    price = frappe.db.get_value('Item Price',
        filters={'item_code': item_code, 'price_list': price_list},
        fieldname='price_list_rate'
    )

    # Cache for 1 hour
    if price:
        frappe.cache().set_value(cache_key, price, expires_in_sec=3600)

    return price
```

### 3. Batch Operations

**Bulk Update Pattern:**
```python
def bulk_update_items(updates):
    """Update multiple items efficiently"""
    # updates = [{'item_code': 'ITEM-001', 'is_active': 1}, ...]

    # Build single query
    item_codes = [u['item_code'] for u in updates]

    frappe.db.sql("""
        UPDATE `tabItem`
        SET is_active = 1,
            modified = NOW(),
            modified_by = %s
        WHERE name IN %s
    """, (frappe.session.user, tuple(item_codes)))

    frappe.db.commit()
```

## References

**Performance Examples:**
- Stock Ledger: https://github.com/frappe/erpnext/blob/develop/erpnext/stock/stock_ledger.py
- Get Item Details: https://github.com/frappe/erpnext/blob/develop/erpnext/stock/get_item_details.py

## Decision Tree & Reference

*Condensed from `frappe-ops-performance` (Frappe_Claude_Skill_Package).*

### Stack rule

Tune **MariaDB**, **Redis**, **Gunicorn**, and **RQ** together — optimizing only one layer often shifts bottlenecks elsewhere.

### Performance decision tree

```
What is slow?
|
+-- Page loads slow? → Check Gunicorn saturation, MariaDB slow log, Redis memory/eviction; consider CDN for static assets
+-- Background jobs delayed? → bench doctor / pending jobs; scale RQ workers; find long-running jobs blocking queues
+-- DB queries slow? → Slow query log + EXPLAIN; indexes on hot filters; prefer get_cached_value over get_value for repeat reads
+-- OOM / high memory? → Fewer Gunicorn workers; Redis maxmemory; right-size innodb_buffer_pool_size; check custom leaks
+-- High CPU? → cProfile; N+1 patterns; heavy scheduled/custom jobs
```

### Quick reference

| Topic | Notes |
|--------|------|
| Health | `bench doctor`; jobs: `bench --site SITE show-pending-jobs`; clear: `bench --site SITE clear-cache` / `clear-website-cache`; stuck: `bench purge-jobs` |
| Gunicorn workers | `workers ≈ (2 × CPU_CORES) + 1`; plan ~150–300MB RAM **per worker**; never exceed RAM (swap destroys latency) |
| Redis (Frappe) | Three roles: cache (~13000), queue (~11000), socketio (~12000); set **maxmemory** on cache + **allkeys-lru** |
| InnoDB | **innodb_buffer_pool_size** dominates; ~50–70% RAM on DB-only host (lower if shared); **utf8mb4** for Frappe |
| CDN | `cdn_url` in `site_config.json` prefixes `/assets/` |

### Common symptoms → fixes

| Symptom | Likely cause | Direction |
|---------|----------------|-----------|
| Slow pages, high DB time | Missing indexes, N+1 | Indexes; batch queries; caching |
| Queue backlog | Too few workers / slow jobs | More workers; shorter jobs |
| OOM | Too many workers / unbounded Redis | Reduce workers; **maxmemory** |
| Timeouts under load | Low Gunicorn timeout / saturation | Tune `--timeout`, workers |

### ALWAYS / NEVER (ops & app reads)

| ALWAYS | NEVER |
|--------|--------|
| Set Redis **maxmemory** on cache (with eviction policy). | Run Redis cache without memory cap → OOM risk. |
| Size Gunicorn workers to **fit RAM** with DB + Redis + OS headroom. | Add workers beyond physical RAM → swapping. |
| Use **`frappe.db.get_cached_value`** (or Redis cache patterns) for hot repeated reads vs raw `get_value` every time. | Assume one layer tuning fixes everything without checking the others. |
| Prefer **utf8mb4** / **utf8mb4_unicode_ci** for MariaDB serving Frappe. | Rely on default query cache on modern MariaDB — disable where appropriate (`query_cache_type = 0`). |
