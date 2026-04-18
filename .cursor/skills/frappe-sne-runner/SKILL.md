---
name: frappe-sne-runner
description: Run ERPNext/Frappe SNE (Single Node Environment) images for local development. All-in-one containers with MariaDB, Redis, and Frappe/ERPNext bundled together.
---

# Frappe SNE Runner

Run ERPNext and Frappe applications locally using vyogo's **Single Node Environment (SNE)** images. These all-in-one containers bundle MariaDB, Redis, Python, Node.js, Nginx, and Frappe/ERPNext into a single container -- no external database or cache services needed.

## When to Use This Skill

Claude should invoke this skill when:
- User wants to run ERPNext or Frappe locally in a container
- User asks about SNE images or single-node development
- User wants to develop a Frappe app with hot-reload in a container
- User mentions `vyogo/erpnext`, `vyogo/frappe`, or `sne` images
- User wants to package a custom app into a standalone image using S2I
- User needs to set up a quick ERPNext demo or dev environment

## Available Images

| Image | Description | Versions |
|-------|-------------|----------|
| `docker.io/vyogo/frappe:s2i-version-{VER}` | Base S2I builder (Frappe only, no ERPNext) | 15, 16 |
| `docker.io/vyogo/erpnext:sne-version-{VER}` | ERPNext SNE (Frappe + ERPNext) | 13, 14, 15, 16 |
| `docker.io/vyogo/crm:sne-version-{VER}` | Frappe CRM SNE | 15, 16 |
| `docker.io/vyogo/central-site:sne-version-{VER}` | Central site for microservice architecture | 15, 16 |

Multi-arch support: all images are available for both `linux/amd64` and `linux/arm64` (Apple Silicon).

## What's Inside an SNE Image

Each SNE image is self-contained:
- **MariaDB 10.11** -- starts automatically, root password: `ChangeMe` (configurable)
- **Redis 7** -- starts automatically, ephemeral mode (no persistence)
- **Python 3.14** with Frappe bench installed
- **Node.js 24** with Yarn
- **Nginx 1.22**
- **Pre-created site**: `dev.localhost` with admin password `admin`
- **S2I scripts** for building and running apps

## Quick Start

### 1. Run ERPNext (No Custom App)

```bash
# Using Docker
docker run -p 8000:8000 docker.io/vyogo/erpnext:sne-version-16

# Using Podman
podman run -p 8000:8000 docker.io/vyogo/erpnext:sne-version-16
```

Access ERPNext at `http://localhost:8000` (login: `Administrator` / `admin`).

### 2. Run with a Custom App (Hot-Reload Development)

Mount your app directory into the container. The SNE image **auto-discovers** any app under `/home/frappe/frappe-bench/apps/` at startup, runs `pip install -e`, and registers it in `apps.txt`.

```bash
# Mount your app for live development
podman run -p 8000:8000 \
  -v ./my_custom_app:/home/frappe/frappe-bench/apps/my_custom_app \
  docker.io/vyogo/erpnext:sne-version-16
```

No `bench get-app` needed -- the run script handles installation automatically.

### 3. Run with Multiple Custom Apps

```bash
podman run -p 8000:8000 \
  -v ./app_one:/home/frappe/frappe-bench/apps/app_one \
  -v ./app_two:/home/frappe/frappe-bench/apps/app_two \
  docker.io/vyogo/erpnext:sne-version-16
```

### 4. Run Frappe Only (No ERPNext)

Use the base S2I builder image to run Frappe without ERPNext:

```bash
podman run -p 8000:8000 \
  -v ./my_app:/home/frappe/frappe-bench/apps/my_app \
  docker.io/vyogo/frappe:s2i-version-16
```

## Compose File for Development

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-16
    ports:
      - "8000:8000"
    volumes:
      - ./my_custom_app:/home/frappe/frappe-bench/apps/my_custom_app
    environment:
      - MYSQL_ROOT_PASSWORD=ChangeMe
```

Start with `docker compose up` or `podman-compose up`.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_ROOT_PASSWORD` | `ChangeMe` | MariaDB root password |
| `ENABLE_ASSETS_CACHE` | `false` | Set to `true` to cache built assets and restore them when `sites/` is mounted as a volume |

## Packaging Custom Apps with S2I

S2I (Source-to-Image) lets you build a standalone image containing your app without writing a Dockerfile.

### Method 1: Using `apps.json`

Create an `apps.json` in your project root:

```json
[
    {
        "url": "https://github.com/frappe/erpnext.git",
        "branch": "version-16",
        "name": "erpnext"
    },
    {
        "url": "https://github.com/your-org/your-app.git",
        "branch": "main",
        "name": "your_app"
    }
]
```

For local source directories (no git fetch), use the `source` field instead of `url`:

```json
[
    {
        "name": "erpnext",
        "source": "erpnext"
    },
    {
        "name": "my_app",
        "source": "my_app"
    }
]
```

Build with S2I:

```bash
s2i build . docker.io/vyogo/frappe:s2i-version-16 my-app-image
```

### Method 2: Using a Containerfile

```dockerfile
FROM docker.io/vyogo/frappe:s2i-version-16

ENV FRAPPE_SITE_NAME=dev.localhost

COPY apps.json /tmp/apps.json
COPY my_custom_app /upload/src/my_custom_app
```

Build:

```bash
podman build -t my-app-image .
```

### Method 3: Using the Makefile (Frappista Repo)

From the frappista repo, use `s2i-podman.sh` to build layered images:

```bash
# Build ERPNext SNE for current arch
make erpnext

# Build for specific architecture
make erpnext-amd64
make erpnext-arm64

# Push multi-arch manifest
make erpnext-manifest
```

Override the Frappe version:

```bash
make erpnext FRAPPE_VERSION=version-15
```

## Configuration Files

### apps.json

Defines which apps to install during S2I build. Supports two modes:

- **Git mode**: `url` + `branch` -- fetches from git during build
- **Local mode**: `source` -- copies from a local directory in the build context

### site-config.json

Defines the site to create during build:

```json
{
    "site_name": "dev.localhost",
    "admin_password": "admin"
}
```

If omitted, defaults to site `dev.localhost` with password `admin`.

### bench-config.json

Defines bench initialization parameters:

```json
{
    "branch": "version-16",
    "bench_name": "frappe-bench"
}
```

## How SNE Startup Works

1. **MariaDB starts** with PID file at `/tmp/pids/mysqld.pid`
2. **Redis starts** in ephemeral mode (no persistence, stale cache cleared)
3. **App auto-discovery**: scans `/home/frappe/frappe-bench/apps/` for mounted apps, runs `pip install -e` for each, updates `sites/apps.txt`
4. **Asset restore** (if `ENABLE_ASSETS_CACHE=true`): restores pre-built assets from image cache
5. **MariaDB remote access** enabled for root user
6. **Cache cleared**: `bench --site all clear-cache`
7. **`bench start`** runs in foreground (Gunicorn web server + workers)

## Version Selection Guide

| Version | Frappe | Python | Node.js | Use Case |
|---------|--------|--------|---------|----------|
| `sne-version-16` | v16 | 3.14 | 24 | Latest features, new projects |
| `sne-version-15` | v15 | 3.11+ | 18+ | Stable, most production deployments |
| `sne-version-14` | v14 | 3.10+ | 16+ | Legacy support |
| `sne-version-13` | v13 | 3.8+ | 14+ | Legacy support |

## Troubleshooting

### Redis Segfault (QEMU Emulation)

If running an `amd64` image on an Apple Silicon (ARM) Mac, Redis may segfault under QEMU emulation. Use the `arm64` image instead:

```bash
podman run --platform linux/arm64 -p 8000:8000 \
  docker.io/vyogo/erpnext:sne-version-16
```

Or build the ARM image locally:

```bash
make erpnext-arm64
```

### App Not Detected at Startup

The auto-discovery looks for directories directly under `/home/frappe/frappe-bench/apps/`. Ensure:
- The volume mount target is a directory (not a file)
- The app directory contains a valid `hooks.py` or `pyproject.toml`
- The directory name matches the app's module name (snake_case)

### Port Already in Use

```bash
# Check what's using port 8000
lsof -i :8000

# Use a different host port
podman run -p 8080:8000 docker.io/vyogo/erpnext:sne-version-16
```

### Persisting Site Data Across Restarts

Mount the `sites` directory to preserve database and site config:

```bash
podman run -p 8000:8000 \
  -v ./sites:/home/frappe/frappe-bench/sites \
  -e ENABLE_ASSETS_CACHE=true \
  docker.io/vyogo/erpnext:sne-version-16
```

Use `ENABLE_ASSETS_CACHE=true` so built assets are restored into the mounted volume.

## Best Practices

- Use `sne-version-16` for new projects (latest Frappe features)
- Mount only app directories for development; let the container manage MariaDB/Redis
- Do NOT run a separate MariaDB or Redis alongside an SNE container -- they are built in
- Use `apps.json` with `source` fields for packaging apps with local source code
- Pin image versions (e.g., `sne-version-16`), never use `sne-latest` in CI
- For production, build a standalone image using S2I rather than mounting volumes
