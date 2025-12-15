---
description: Manage Redis cache - clear, monitor, and optimize Frappe cache performance
---

# Frappe Cache Command

Manage Frappe's Redis cache including clearing cache, monitoring cache statistics, and optimizing cache performance.

## Steps to Execute

### 1. Verify Environment
- Check if in valid Frappe bench
- Verify Redis is running: `redis-cli ping`
- Check site exists

### 2. Cache Operation Selection

Ask user what cache operation they want:

**A. Clear Cache**
- Clear all cache
- Clear specific doctype cache
- Clear user-specific cache
- Clear specific cache keys

**B. View Cache Stats**
- Cache size and memory usage
- Hit/miss ratio
- Key count
- Expiration info

**C. Inspect Cache**
- List cache keys
- View specific key values
- Search cache keys by pattern

**D. Monitor Cache**
- Real-time cache monitoring
- Performance metrics
- Memory usage trends

### 3. Clear Cache Operations

**Clear All Cache:**
```bash
bench --site [site-name] clear-cache
```

**Clear Specific DocType:**
```bash
bench --site [site-name] console
>>> frappe.clear_cache(doctype='Customer')
>>> exit()
```

**Clear User Cache:**
```bash
# Via console
bench --site [site-name] console
>>> frappe.clear_cache(user='user@example.com')
```

**Clear Specific Keys:**
```bash
# Via Redis CLI
redis-cli --scan --pattern "*customer*" | xargs redis-cli del
```

### 4. Cache Statistics

**View Cache Info:**
```bash
redis-cli info memory
redis-cli info stats
```

Display formatted output:
```
Memory Usage: 45.2 MB / 512 MB (8.8%)
Total Keys: 1,247
Hit Rate: 87.3%
Evictions: 12
```

**Key Count by Pattern:**
```bash
# Count DocType cache keys
redis-cli --scan --pattern "*doctype*" | wc -l

# Count user cache keys
redis-cli --scan --pattern "*user*" | wc -l
```

### 5. Cache Inspection

**List Recent Keys:**
```bash
redis-cli --scan --pattern "*" | head -20
```

**View Key Value:**
```bash
redis-cli get "cache_key_name"
```

**Check Key TTL:**
```bash
redis-cli ttl "cache_key_name"
```

**Search Keys:**
```bash
# Find keys matching pattern
redis-cli --scan --pattern "*customer*"
```

### 6. Cache Monitoring

**Monitor in Real-time:**
```bash
redis-cli monitor
```

**Watch Stats:**
```bash
watch -n 1 redis-cli info stats
```

**Memory Usage:**
```bash
redis-cli info memory | grep used_memory_human
```

### 7. Cache Optimization Suggestions

Analyze cache usage and suggest optimizations:

**High Memory Usage:**
- Review cache key patterns
- Set appropriate TTL values
- Identify large cached objects
- Suggest cache eviction policies

**Low Hit Rate:**
- Identify frequently missed keys
- Suggest pre-warming strategies
- Review caching logic in code
- Optimize cache key design

**Too Many Keys:**
- Identify unused patterns
- Suggest cleanup strategies
- Review cache key naming

### 8. Frappe-Specific Cache Operations

**Cache Patterns in Frappe:**
```python
# In bench console
frappe.cache().get_value('key')
frappe.cache().set_value('key', 'value', expires_in_sec=3600)
frappe.cache().delete_key('key')
frappe.cache().delete_keys('key*')
```

**Common Cache Keys:**
- `doctype_meta:[DocType]` - DocType metadata
- `user_info:[user]` - User information
- `permission:[doctype]:[user]` - Permission cache
- `report:[report_name]` - Report cache
- `home_page:[user]` - User home page

### 9. Cache Best Practices

**When to Clear Cache:**
- After modifying DocType JSON
- After changing permissions
- After code deployment
- When seeing stale data
- After database schema changes

**Selective Clearing:**
```python
# Clear only what's needed (via console)
frappe.clear_cache(doctype='Customer')  # Specific DocType
frappe.clear_cache(user='user@test.com')  # Specific user
frappe.cache().delete_keys('custom_cache_*')  # Pattern match
```

**Automatic Cache Clearing:**
- Frappe auto-clears cache on DocType save
- Automatic on permission changes
- Can configure in hooks.py

### 10. Troubleshooting Cache Issues

**Common Problems:**

**"Stale Data Showing"**
```bash
# Clear all cache
bench --site [site-name] clear-cache

# Reload DocType
bench --site [site-name] console
>>> frappe.reload_doctype('Customer')
```

**"Redis Connection Error"**
```bash
# Check Redis status
redis-cli ping

# Restart Redis
sudo systemctl restart redis-server

# Check Redis config in site_config.json
cat sites/[site-name]/site_config.json | grep redis
```

**"High Memory Usage"**
```bash
# Find large keys
redis-cli --bigkeys

# Set memory limit in redis.conf
maxmemory 512mb
maxmemory-policy allkeys-lru
```

**"Cache Not Working"**
```python
# Verify cache is enabled
bench --site [site-name] console
>>> frappe.cache().get_value('test_key')
>>> frappe.cache().set_value('test_key', 'test_value')
>>> frappe.cache().get_value('test_key')  # Should return 'test_value'
```

## References

### Frappe Core Cache Implementation (Primary Reference)

**Frappe Cache Module:**
- Cache Implementation: https://github.com/frappe/frappe/blob/develop/frappe/utils/redis_wrapper.py
- Cache Manager: https://github.com/frappe/frappe/blob/develop/frappe/cache_manager.py
- Clear Cache Function: https://github.com/frappe/frappe/blob/develop/frappe/__init__.py

**ERPNext Cache Usage Examples:**
- Item Price Caching: https://github.com/frappe/erpnext/blob/develop/erpnext/stock/get_item_details.py
- Report Caching: https://github.com/frappe/erpnext/tree/develop/erpnext/accounts/report

**Real Cache Patterns from Core:**

1. **Cache with TTL** (from ERPNext):
```python
# See: erpnext/stock/get_item_details.py
def get_price_list_rate(args):
    cache_key = f"price_list_rate:{args.item_code}:{args.price_list}"
    cached_rate = frappe.cache().get_value(cache_key)

    if cached_rate:
        return cached_rate

    # Fetch from database
    rate = frappe.db.get_value('Item Price', filters, 'price_list_rate')

    # Cache for 1 hour
    frappe.cache().set_value(cache_key, rate, expires_in_sec=3600)
    return rate
```

2. **Cache Invalidation** (from Frappe Core):
```python
# See: frappe/model/document.py
def save(self):
    # ... save logic ...

    # Clear cache after save
    frappe.clear_cache(doctype=self.doctype)
    frappe.clear_document_cache(self.doctype, self.name)
```

3. **Global Cache** (from Frappe Core):
```python
# See: frappe/cache_manager.py
def clear_global_cache():
    frappe.cache().delete_keys('*')
    frappe.cache().delete_keys('global:*')
```

### Official Documentation (Secondary Reference)

- Caching Guide: https://frappeframework.com/docs/user/en/api/cache
- Redis Configuration: https://frappeframework.com/docs/user/en/bench/reference/redis
- Performance: https://frappeframework.com/docs/user/en/performance

## Advanced Cache Management

### Cache Key Patterns

**Frappe Standard Keys:**
```
doctype_meta:{doctype}
user_info:{user_id}
defaults:{user}:{key}
permission:{doctype}:{ptype}:{user}
global:{key}
temp:{random}
```

### Cache Configuration

**Site Config (site_config.json):**
```json
{
  "redis_cache": "redis://localhost:13000",
  "redis_queue": "redis://localhost:11000",
  "cache_ttl": 3600
}
```

**Redis Config (redis.conf):**
```
maxmemory 512mb
maxmemory-policy allkeys-lru
save ""
appendonly no
```

### Performance Optimization

**Cache Hit Rate:**
```bash
# Monitor hit rate
redis-cli info stats | grep keyspace
```

**Memory Efficiency:**
```bash
# Find memory hogs
redis-cli --bigkeys

# Sample random keys
redis-cli --memkeys
```

### Custom Caching

**In Your App:**
```python
from frappe.utils.caching import redis_cache

@redis_cache(ttl=3600)
def expensive_operation(param):
    # Automatically cached for 1 hour
    return calculate_something(param)
```

## Important Notes

- Cache clearing is safe - Frappe rebuilds as needed
- User-specific cache clears on login/logout
- DocType meta cache clears on save
- Global cache clear affects all users
- Redis restart clears all cache
- Cache is primarily for read-heavy operations
- Write operations should clear relevant cache
- Use cache for expensive queries only

## Monitoring Best Practices

1. **Regular Health Checks:** Monitor cache hit rate
2. **Memory Limits:** Set maxmemory in Redis config
3. **Eviction Policy:** Use allkeys-lru for LRU eviction
4. **Key Expiration:** Set appropriate TTL values
5. **Pattern Analysis:** Monitor which keys are accessed most
6. **Clear Strategically:** Don't clear all cache unnecessarily
7. **Log Cache Operations:** Track cache performance in logs
