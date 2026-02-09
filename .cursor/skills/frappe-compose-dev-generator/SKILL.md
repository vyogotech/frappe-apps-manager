---
name: frappe-compose-dev-generator
description: Generate compose.yml for local containerized development using vyogo's sne images, following the projectnext compose.yml pattern.
---

# Frappe Compose Dev Generator

Generate `compose.yml` for local containerized development using vyogo's sne images.

## When to Use This Skill

Claude should invoke this skill when:
- User wants to set up local containerized development
- User needs a compose.yml for their Frappe app
- User mentions docker-compose, podman-compose, or local development
- During app generation to include compose.yml
- User wants to use vyogo's sne images for development

## Capabilities

### 1. Basic Compose Template

Generate `compose.yml` based on the projectnext pattern:

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-15
    ports:
      - "8000:8000"
    volumes:
      - .:/home/frappe/frappe-bench/apps/<app-name>
    # entrypoint: /usr/libexec/s2i/run
    # environment:
    #   MYSQL_ROOT_PASSWORD: securepassword
    #   ENTRYPOINT: /usr/libexec/s2i/run
```

### 2. App-Specific Customization

Replace `<app-name>` with actual app name:
- `projectnext` → `/home/frappe/frappe-bench/apps/projectnext`
- `my_custom_app` → `/home/frappe/frappe-bench/apps/my_custom_app`

### 3. Version Variations

**For Version 15:**
```yaml
image: docker.io/vyogo/erpnext:sne-version-15
```

**For Version 14:**
```yaml
image: docker.io/vyogo/erpnext:sne-version-14
```

**For Version 13:**
```yaml
image: docker.io/vyogo/erpnext:sne-version-13
```

### 4. Port Configuration

**Default Port (8000):**
```yaml
ports:
  - "8000:8000"
```

**Custom Port:**
```yaml
ports:
  - "8080:8000"  # Host:Container
```

**Multiple Ports:**
```yaml
ports:
  - "8000:8000"   # Web
  - "3306:3306"   # MySQL (if exposed)
  - "6379:6379"   # Redis (if exposed)
```

### 5. Volume Mounts

**Development (Hot Reload):**
```yaml
volumes:
  - .:/home/frappe/frappe-bench/apps/<app-name>
  # Mount entire app directory for live changes
```

**With Additional Volumes:**
```yaml
volumes:
  - .:/home/frappe/frappe-bench/apps/<app-name>
  - ./sites:/home/frappe/frappe-bench/sites  # Persist sites
  - ./logs:/home/frappe/frappe-bench/logs    # Persist logs
```

### 6. Environment Variables

**Basic:**
```yaml
environment:
  - FRAPPE_SITE=default
  - BENCH_DEVELOPER=1
```

**With Database:**
```yaml
environment:
  - MYSQL_ROOT_PASSWORD=securepassword
  - FRAPPE_SITE=default
  - BENCH_DEVELOPER=1
```

**Full Configuration:**
```yaml
environment:
  - MYSQL_ROOT_PASSWORD=securepassword
  - FRAPPE_SITE=default
  - BENCH_DEVELOPER=1
  - ENTRYPOINT=/usr/libexec/s2i/run
  - PYTHONUNBUFFERED=1
```

### 7. Entrypoint Configuration

**Using S2I Entrypoint:**
```yaml
entrypoint: /usr/libexec/s2i/run
```

**Custom Entrypoint:**
```yaml
entrypoint: ["/bin/bash", "-c"]
command: ["bench start"]
```

### 8. Network Configuration

**Default Network:**
```yaml
networks:
  - default
```

**Custom Network:**
```yaml
networks:
  frappe-network:
    driver: bridge
```

### 9. Complete Example

For app named `projectnext`:

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-15
    ports:
      - "8000:8000"
    volumes:
      - .:/home/frappe/frappe-bench/apps/projectnext
    environment:
      - FRAPPE_SITE=default
      - BENCH_DEVELOPER=1
      - PYTHONUNBUFFERED=1
    # Optional: Uncomment for S2I entrypoint
    # entrypoint: /usr/libexec/s2i/run
    # Optional: Database configuration
    # environment:
    #   MYSQL_ROOT_PASSWORD: securepassword
    #   ENTRYPOINT: /usr/libexec/s2i/run
```

### 10. Multi-Service Setup

If you need database and Redis:

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-15
    ports:
      - "8000:8000"
    volumes:
      - .:/home/frappe/frappe-bench/apps/<app-name>
      - ./sites:/home/frappe/frappe-bench/sites
    environment:
      - FRAPPE_SITE=default
      - BENCH_DEVELOPER=1
    depends_on:
      - mariadb
      - redis
  
  mariadb:
    image: mariadb:10.6
    environment:
      - MYSQL_ROOT_PASSWORD=securepassword
    volumes:
      - mariadb_data:/var/lib/mysql
  
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  mariadb_data:
  redis_data:
```

## Key Patterns

1. **Image**: Use `docker.io/vyogo/erpnext:sne-version-15` for vyogo's sne images
2. **Volume Mount**: Mount app directory for hot-reload development
3. **Port Mapping**: Map container port 8000 to host
4. **Environment**: Set `BENCH_DEVELOPER=1` for development mode
5. **Entrypoint**: Optional S2I entrypoint for production-like behavior

## Best Practices

- **Hot Reload**: Use volume mounts for live code changes
- **Port Management**: Use standard port 8000 or document custom ports
- **Environment Variables**: Set appropriate development flags
- **Comments**: Include commented options for easy configuration
- **Version Pinning**: Pin specific image versions, not `latest`
- **Security**: Don't commit passwords in compose.yml (use .env file)

## Integration with frappe-new-app

When generating a new app, automatically include compose.yml:

1. After app creation, generate compose.yml
2. Use app name from app creation
3. Place compose.yml in app root directory
4. Inform user about containerized development setup

## Usage Instructions

**Start Development:**
```bash
# Using Docker Compose
docker-compose up -d

# Using Podman Compose
podman-compose up -d
```

**View Logs:**
```bash
docker-compose logs -f frappe-sne
# or
podman-compose logs -f frappe-sne
```

**Stop Services:**
```bash
docker-compose down
# or
podman-compose down
```

**Rebuild:**
```bash
docker-compose up -d --build
# or
podman-compose up -d --build
```

## Example Output

For app named `projectnext`:

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-15
    ports:
      - "8000:8000"
    volumes:
      - .:/home/frappe/frappe-bench/apps/projectnext
    # entrypoint: /usr/libexec/s2i/run
    # environment:
    #   MYSQL_ROOT_PASSWORD: securepassword
    #   ENTRYPOINT: /usr/libexec/s2i/run
```
