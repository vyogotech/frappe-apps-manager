---
name: frappe-sne-runner
description: Set up local Frappe/ERPNext development using vyogo SNE (Single Node Environment) images. Replaces the traditional multi-container setup (MariaDB, Redis, workers, scheduler) with a single all-in-one container.
---

# Frappe SNE Runner -- Local Development Setup

Set up local Frappe/ERPNext development using vyogo's **SNE (Single Node Environment)** images. One container replaces the entire traditional Frappe stack.

## When to Use This Skill

Claude should invoke this skill when:
- User wants to set up Frappe or ERPNext locally
- User wants to run a Frappe app in a container for development
- User asks about local dev environment for Frappe
- User mentions `vyogo/erpnext`, `vyogo/frappe`, or SNE images
- User wants to replace a multi-container Frappe setup with something simpler
- User needs a quick ERPNext demo environment
- User wants to run `bench test` in an SNE container
- User wants a CI job that uses `sne-version-15` or `sne-version-16`

## Why SNE: Before vs After

### Traditional Setup (10+ containers)

A traditional containerized Frappe dev environment requires separate services for database, cache, workers, scheduler, websocket, and frontend:

```yaml
services:
  backend:
    image: frappe/erpnext:v15
  db:
    image: mariadb:10.6
  int-redis-cache:
    image: redis:6.2-alpine
  int-redis-queue:
    image: redis:6.2-alpine
  int-redis-socketio:
    image: redis:6.2-alpine
  frontend:
    image: frappe/erpnext:v15
    command: nginx-entrypoint.sh
  queue-default:
    image: frappe/erpnext:v15
    command: bench worker --queue default
  queue-long:
    image: frappe/erpnext:v15
    command: bench worker --queue long
  queue-short:
    image: frappe/erpnext:v15
    command: bench worker --queue short
  scheduler:
    image: frappe/erpnext:v15
    command: bench schedule
  websocket:
    image: frappe/erpnext:v15
    command: node socketio.js
  configurator:
    # configures db_host, redis_cache, etc.
  create-site:
    # creates site, installs apps
```

Plus separate named volumes for db-data, redis-data, sites, and logs.

### SNE Setup (1 container)

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-16
    ports:
      - "8000:8000"
```

That's it. MariaDB, Redis, workers, scheduler, websocket -- all run inside the single container. Site is pre-created. Apps are auto-discovered.

## Quick Start

### Run ERPNext Locally

```bash
podman run -p 8000:8000 docker.io/vyogo/erpnext:sne-version-16
```

Access at `http://localhost:8000` -- login: `Administrator` / `admin`.

### Develop a Custom App

Mount your app directory. The container auto-discovers it, runs `pip install -e`, and registers it:

```bash
podman run -p 8000:8000 \
  -v ./my_custom_app:/home/frappe/frappe-bench/apps/my_custom_app \
  docker.io/vyogo/erpnext:sne-version-16
```

No `bench get-app` needed.

### Develop Multiple Apps

```bash
podman run -p 8000:8000 \
  -v ./app_one:/home/frappe/frappe-bench/apps/app_one \
  -v ./app_two:/home/frappe/frappe-bench/apps/app_two \
  docker.io/vyogo/erpnext:sne-version-16
```

### Run Frappe Only (No ERPNext)

```bash
podman run -p 8000:8000 \
  -v ./my_app:/home/frappe/frappe-bench/apps/my_app \
  docker.io/vyogo/frappe:s2i-version-16
```

## Compose File for Development

### Single App

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-16
    ports:
      - "8000:8000"
    volumes:
      - .:/home/frappe/frappe-bench/apps/<app-name>
```

### With Site Persistence

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-16
    ports:
      - "8000:8000"
    volumes:
      - .:/home/frappe/frappe-bench/apps/<app-name>
      - site_data:/home/frappe/frappe-bench/sites
    environment:
      - ENABLE_ASSETS_CACHE=true

volumes:
  site_data:
```

### With Microservices

When pairing an SNE container with microservices, the SNE container acts as the central site. Microservices connect to its built-in MariaDB and Redis over a shared network:

```yaml
name: my-project-dev
services:
  central-site:
    image: docker.io/vyogo/erpnext:sne-version-16
    ports:
      - "8080:8000"
    networks:
      - dev-network

  my-service:
    image: my-microservice:latest
    ports:
      - "8002:8000"
    environment:
      - CENTRAL_SITE_URL=http://central-site:8000
      - DB_HOST=central-site
      - DB_PORT=3306
      - REDIS_HOST=central-site
      - REDIS_PORT=6379
    depends_on:
      central-site:
        condition: service_started
    networks:
      - dev-network

networks:
  dev-network:
    driver: bridge
```

## Available Images

| Image | Description | Versions |
|-------|-------------|----------|
| `docker.io/vyogo/erpnext:sne-version-{VER}` | ERPNext + Frappe (most common) | 13, 14, 15, 16 |
| `docker.io/vyogo/frappe:s2i-version-{VER}` | Frappe only (no ERPNext) | 15, 16 |
| `docker.io/vyogo/crm:sne-version-{VER}` | Frappe CRM | 15, 16 |
| `docker.io/vyogo/central-site:sne-version-{VER}` | Central site for microservices | 15, 16 |

All images support both `linux/amd64` and `linux/arm64` (Apple Silicon).

## What's Inside

Each SNE container runs:
- **MariaDB 10.11** -- auto-starts, root password `ChangeMe` (configurable via `MYSQL_ROOT_PASSWORD`)
- **Redis 7** -- auto-starts, ephemeral (no persistence)
- **Python 3.14** with bench, Gunicorn, workers, scheduler
- **Node.js 24** with Yarn, socketio
- **Nginx 1.22**
- **Pre-created site**: `dev.localhost`, admin password `admin`

## Version Guide

| Version | Use Case |
|---------|----------|
| `sne-version-16` | Latest features, new projects (default) |
| `sne-version-15` | Stable, production-like development |
| `sne-version-14` | Legacy apps |
| `sne-version-13` | Legacy apps |

## Testing with SNE

SNE images already include the full bench stack, so tests can run directly in the container with `bench test`.

### Local Test Run

```bash
podman run --rm -it \
  -v "$PWD":/home/frappe/frappe-bench/apps/<app-name> \
  docker.io/vyogo/erpnext:sne-version-16 \
  bench test --app <app-name>
```

Use `docker.io/vyogo/erpnext:sne-version-15` for stable branches.

### GitHub Actions Test Job

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: docker.io/vyogo/erpnext:sne-version-16
    steps:
      - uses: actions/checkout@v4
      - name: Run bench test
        run: bench test --app $(basename ${{ github.repository }})
```

Swap to `sne-version-15` when you want the stable image line.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_ROOT_PASSWORD` | `ChangeMe` | MariaDB root password |
| `ENABLE_ASSETS_CACHE` | `false` | Restore cached assets when `sites/` is a mounted volume |

## How Startup Works

1. MariaDB starts
2. Redis starts (ephemeral, stale cache cleared)
3. App auto-discovery: scans `apps/` directory, runs `pip install -e` for each, updates `apps.txt`
4. Asset restore if `ENABLE_ASSETS_CACHE=true`
5. `bench start` runs in foreground (web server + workers + scheduler)

## Packaging Apps with S2I

Build a standalone image containing your app using S2I (Source-to-Image):

### Using apps.json

```json
[
    {
        "url": "https://github.com/frappe/erpnext.git",
        "branch": "version-16",
        "name": "erpnext"
    },
    {
        "name": "my_app",
        "source": "my_app"
    }
]
```

Build:

```bash
s2i build . docker.io/vyogo/frappe:s2i-version-16 my-app-image
```

### Using a Containerfile

```dockerfile
FROM docker.io/vyogo/frappe:s2i-version-16
ENV FRAPPE_SITE_NAME=dev.localhost
COPY apps.json /tmp/apps.json
COPY my_app /upload/src/my_app
```

## Troubleshooting

### Redis Segfault on Apple Silicon

Use the ARM image:

```bash
podman run --platform linux/arm64 -p 8000:8000 \
  docker.io/vyogo/erpnext:sne-version-16
```

### App Not Detected

Ensure the mounted directory:
- Is directly under `/home/frappe/frappe-bench/apps/`
- Contains a valid `hooks.py` or `pyproject.toml`
- Uses snake_case naming matching the app module

### Port Conflict

```bash
podman run -p 8080:8000 docker.io/vyogo/erpnext:sne-version-16
```

## Best Practices

- Use `sne-version-16` for new projects
- Do NOT add separate MariaDB or Redis containers -- they are built in
- Mount only your app directories; let the container manage its own services
- Use `ENABLE_ASSETS_CACHE=true` when persisting `sites/` as a volume
- Pin image versions, never use `latest` in CI/CD
- For production, package your app using S2I rather than volume mounts
