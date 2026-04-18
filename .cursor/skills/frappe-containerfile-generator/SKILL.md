---
name: frappe-containerfile-generator
description: Generate Containerfile for Frappe apps using vyogo's S2I builder images or the SNE all-in-one pattern. Supports versions 13-16.
---

# Frappe Containerfile Generator

Generate Containerfiles for Frappe applications using two approaches:
1. **S2I-based** (recommended) -- use `docker.io/vyogo/frappe:s2i-version-{VER}` as base, let S2I handle app installation and site creation
2. **Manual Gunicorn** -- directly copy app source into a Frappe image and configure Gunicorn

## When to Use This Skill

Claude should invoke this skill when:
- User wants to create a Containerfile for a Frappe app
- User needs to build a Docker/Podman image for their Frappe app
- User mentions containerization, Docker, Podman, or Containerfile
- During app generation (frappe-new-app) to include Containerfile
- User wants to package an app into a standalone image

## Approach 1: S2I-Based Containerfile (Recommended)

Uses vyogo's S2I builder images. The S2I assemble script handles app installation, site creation, and asset building automatically.

### Basic Template

```dockerfile
FROM docker.io/vyogo/frappe:s2i-version-16

ENV FRAPPE_SITE_NAME=dev.localhost

COPY apps.json /tmp/apps.json
COPY <app-name> /upload/src/<app-name>
```

Replace `<app-name>` with the actual app name (snake_case).

### With apps.json (Git Fetch)

Create `apps.json` to define apps fetched from git during build:

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

### With apps.json (Local Source)

Use the `source` field to copy from local directories in the build context:

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

### S2I Build Command

Instead of `podman build`, you can also use the `s2i` CLI directly:

```bash
s2i build . docker.io/vyogo/frappe:s2i-version-16 my-app-image
```

This reads `apps.json` from the current directory and produces a ready-to-run image.

### Version Variations

**Version 16 (latest):**
```dockerfile
FROM docker.io/vyogo/frappe:s2i-version-16
```

**Version 15 (stable):**
```dockerfile
FROM docker.io/vyogo/frappe:s2i-version-15
```

### S2I Lifecycle

During build, the S2I assemble script:
1. Starts MariaDB and Redis inside the build container
2. Reads `apps.json` and installs each app (git clone or local copy + `pip install -e`)
3. Creates a site from `site-config.json` (or defaults to `dev.localhost` / `admin`)
4. Runs `bench build --production` to compile assets
5. Stops services and commits the layer

At runtime, the S2I run script:
1. Starts MariaDB and Redis
2. Auto-discovers any mounted apps and registers them
3. Runs `bench start`

### Complete S2I Example

For app named `projectnext`:

```dockerfile
FROM docker.io/vyogo/frappe:s2i-version-16

ENV FRAPPE_SITE_NAME=dev.localhost

COPY apps.json /tmp/apps.json
COPY projectnext /upload/src/projectnext
```

With `apps.json`:

```json
[
    {
        "url": "https://github.com/frappe/erpnext.git",
        "branch": "version-16",
        "name": "erpnext"
    },
    {
        "name": "projectnext",
        "source": "projectnext"
    }
]
```

Build and run:

```bash
podman build -t projectnext-image .
podman run -p 8000:8000 projectnext-image
```

## Approach 2: Manual Gunicorn Containerfile

For cases where you need fine-grained control or want to use the official Frappe images without S2I.

### Template

```dockerfile
FROM docker.io/frappe/erpnext:version-16
USER root
WORKDIR /home/frappe/frappe-bench

RUN mkdir -p sites/assets/<app-name> && \
    chown -R frappe:frappe sites/assets

USER frappe

WORKDIR /home/frappe/frappe-bench

COPY --chown=frappe:frappe . ./apps/<app-name>/

RUN env/bin/python3 -m pip install -e ./apps/<app-name> && \
    export BENCH_DEVELOPER=1 && \
    ls -1 ./apps > sites/apps.txt && \
    cat sites/apps.txt

CMD [ \
    "/home/frappe/frappe-bench/env/bin/gunicorn", \
    "--chdir=/home/frappe/frappe-bench/sites", \
    "--bind=0.0.0.0:8000", \
    "--threads=4", \
    "--workers=2", \
    "--worker-class=gthread", \
    "--worker-tmp-dir=/dev/shm", \
    "--timeout=120", \
    "--preload", \
    "frappe.app:application" \
]
```

### Multi-App Support

```dockerfile
COPY --chown=frappe:frappe ./app1 ./apps/app1/
COPY --chown=frappe:frappe ./app2 ./apps/app2/

RUN env/bin/python3 -m pip install -e ./apps/app1 && \
    env/bin/python3 -m pip install -e ./apps/app2 && \
    export BENCH_DEVELOPER=1 && \
    ls -1 ./apps > sites/apps.txt
```

### Version Variations

```dockerfile
FROM docker.io/frappe/erpnext:version-15
FROM docker.io/frappe/erpnext:version-14
FROM docker.io/frappe/erpnext:version-13
```

## Configuration Files Reference

### site-config.json

Optional. Defines the site created during S2I build:

```json
{
    "site_name": "dev.localhost",
    "admin_password": "admin"
}
```

### bench-config.json

Optional. Defines bench initialization:

```json
{
    "branch": "version-16",
    "bench_name": "frappe-bench"
}
```

## Key Patterns

1. **Prefer S2I approach** for new projects -- handles app install, site creation, and asset build
2. **Use manual Gunicorn approach** when you need fine-grained control or use official Frappe images
3. **User context**: switch to `frappe` user after root operations in manual approach
4. **Directory structure**: always follow `/home/frappe/frappe-bench` layout
5. **Apps.txt**: always update `sites/apps.txt` with installed apps
6. **Version pinning**: pin specific version tags, never use `latest`

## Best Practices

- **S2I for packaging**: use `s2i build` or S2I-based Containerfile for repeatable builds
- **Volume mounts for dev**: don't bake app source into the image during development -- use compose.yml with volume mounts instead
- **Layer optimization**: combine RUN commands to reduce image layers
- **Permissions**: always set `--chown=frappe:frappe` when copying files
- **Multi-arch**: build for both amd64 and arm64 if distributing images
- **Production**: use S2I approach with `bench build --production` (handled automatically)

## Integration with frappe-new-app

When generating a new app, automatically include:

1. `Containerfile` using the S2I approach
2. `apps.json` with the new app and any dependencies
3. Place files in app root directory
4. Default to `s2i-version-16` unless user specifies a version
