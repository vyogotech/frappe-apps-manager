---
name: frappe-compose-dev-generator
description: Generate compose.yml for local containerized development using vyogo's SNE (Single Node Environment) images. All-in-one containers with MariaDB, Redis, and Frappe/ERPNext bundled together.
---

# Frappe Compose Dev Generator

Generate `compose.yml` for local containerized development using vyogo's SNE images. These are all-in-one containers -- MariaDB, Redis, and Frappe/ERPNext are bundled inside, so no external database or cache services are needed.

## When to Use This Skill

Claude should invoke this skill when:
- User wants to set up local containerized development
- User needs a compose.yml for their Frappe app
- User mentions docker-compose, podman-compose, or local development
- During app generation to include compose.yml
- User wants to use vyogo's sne images for development

## How SNE Images Work

SNE images are self-contained. At startup, the container:
1. Starts the built-in MariaDB and Redis
2. Auto-discovers any app mounted under `/home/frappe/frappe-bench/apps/`
3. Runs `pip install -e` for each discovered app and updates `sites/apps.txt`
4. Runs `bench start` in the foreground

No `bench get-app` or manual installation is needed -- just mount your app directory.

## Capabilities

### 1. Basic Compose Template (Recommended)

Generate `compose.yml` for a single app:

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-16
    ports:
      - "8000:8000"
    volumes:
      - .:/home/frappe/frappe-bench/apps/<app-name>
```

Replace `<app-name>` with the actual app name (snake_case):
- `projectnext` -> `/home/frappe/frappe-bench/apps/projectnext`
- `my_custom_app` -> `/home/frappe/frappe-bench/apps/my_custom_app`

### 2. Version Selection

**Version 16 (default for new projects):**
```yaml
image: docker.io/vyogo/erpnext:sne-version-16
```

**Version 15 (stable, most production deployments):**
```yaml
image: docker.io/vyogo/erpnext:sne-version-15
```

**Version 14:**
```yaml
image: docker.io/vyogo/erpnext:sne-version-14
```

**Version 13:**
```yaml
image: docker.io/vyogo/erpnext:sne-version-13
```

**Frappe only (no ERPNext):**
```yaml
image: docker.io/vyogo/frappe:s2i-version-16
```

### 3. Port Configuration

**Default Port (8000):**
```yaml
ports:
  - "8000:8000"
```

**Custom Host Port:**
```yaml
ports:
  - "8080:8000"  # Host:Container
```

### 4. Volume Mounts

**Development (single app, hot-reload):**
```yaml
volumes:
  - .:/home/frappe/frappe-bench/apps/<app-name>
```

**Multiple apps:**
```yaml
volumes:
  - ./app_one:/home/frappe/frappe-bench/apps/app_one
  - ./app_two:/home/frappe/frappe-bench/apps/app_two
```

**Persisting site data across restarts:**
```yaml
volumes:
  - .:/home/frappe/frappe-bench/apps/<app-name>
  - ./sites:/home/frappe/frappe-bench/sites
environment:
  - ENABLE_ASSETS_CACHE=true
```

When mounting `sites/` as a volume, set `ENABLE_ASSETS_CACHE=true` so built assets are restored from the image cache into the mounted volume.

### 5. Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_ROOT_PASSWORD` | `ChangeMe` | MariaDB root password (built-in) |
| `ENABLE_ASSETS_CACHE` | `false` | Restore built assets when `sites/` is mounted as volume |

```yaml
environment:
  - MYSQL_ROOT_PASSWORD=ChangeMe
  - ENABLE_ASSETS_CACHE=true
```

### 6. Complete Example

For app named `projectnext` on version 16:

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-16
    ports:
      - "8000:8000"
    volumes:
      - .:/home/frappe/frappe-bench/apps/projectnext
    environment:
      - MYSQL_ROOT_PASSWORD=ChangeMe
```

### 7. Multi-App Development

When developing multiple apps together:

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-16
    ports:
      - "8000:8000"
    volumes:
      - ../app_one:/home/frappe/frappe-bench/apps/app_one
      - ../app_two:/home/frappe/frappe-bench/apps/app_two
    environment:
      - MYSQL_ROOT_PASSWORD=ChangeMe
```

All mounted apps are auto-discovered and installed at startup.

### 8. Multi-Container Setup (SNE + Microservices)

When running an SNE container alongside microservices, use a shared network. Do NOT add separate MariaDB/Redis containers -- they are built into the SNE image.

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-16
    ports:
      - "8000:8000"
    volumes:
      - .:/home/frappe/frappe-bench/apps/<app-name>
    environment:
      - MYSQL_ROOT_PASSWORD=ChangeMe
    networks:
      - frappe-network

  my-microservice:
    image: my-microservice:latest
    ports:
      - "8002:8000"
    environment:
      - CENTRAL_SITE_URL=http://frappe-sne:8000
      - DB_HOST=frappe-sne
      - DB_PORT=3306
      - REDIS_HOST=frappe-sne
      - REDIS_PORT=6379
    depends_on:
      - frappe-sne
    networks:
      - frappe-network

networks:
  frappe-network:
    driver: bridge
```

## Key Patterns

1. **Image**: Use `docker.io/vyogo/erpnext:sne-version-16` (or version-15 for stable)
2. **All-in-one**: SNE containers include MariaDB and Redis -- do NOT add them separately
3. **Auto-registration**: Mounted apps are auto-discovered -- no `bench get-app` needed
4. **Volume mount**: Mount app directory for hot-reload development
5. **Port mapping**: Map container port 8000 to host
6. **Default credentials**: Site `dev.localhost`, login `Administrator` / `admin`

## Best Practices

- Use `sne-version-16` for new projects, `sne-version-15` for stable/production-like dev
- Mount only your app directories -- let the container manage its own MariaDB/Redis
- Do NOT add separate `mariadb` or `redis` services when using SNE images
- Use `ENABLE_ASSETS_CACHE=true` when mounting `sites/` as a volume
- Pin specific image versions (e.g., `sne-version-16`), never use `sne-latest` in CI
- Use `.env` files for passwords instead of hardcoding in compose.yml

## Integration with frappe-new-app

When generating a new app, automatically include compose.yml:

1. After app creation, generate compose.yml
2. Use app name from app creation
3. Place compose.yml in app root directory
4. Default to `sne-version-16` unless user specifies a version

## Usage Instructions

**Start Development:**
```bash
docker compose up
# or
podman-compose up
```

**View Logs:**
```bash
docker compose logs -f frappe-sne
```

**Stop Services:**
```bash
docker compose down
```

**Shell into Container:**
```bash
docker compose exec frappe-sne bash
# Then use bench commands:
bench --site dev.localhost console
```
