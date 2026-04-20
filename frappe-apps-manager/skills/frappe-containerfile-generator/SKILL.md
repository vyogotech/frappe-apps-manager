---
name: frappe-containerfile-generator
description: Generate Containerfile for Frappe apps using the official frappe/erpnext images with Gunicorn. The recommended pattern copies app source into the bench layout and runs Gunicorn directly.
---

# Frappe Containerfile Generator

Generate Containerfiles for Frappe applications using the official `docker.io/frappe/erpnext` base images.

**IMPORTANT**: Frappe apps are NOT normal Python apps. They run inside the Frappe bench directory structure (`/home/frappe/frappe-bench`) and require specific directory layout, user permissions, and the Gunicorn entry point `frappe.app:application`.

## When to Use This Skill

Use this skill when:
- Creating a Containerfile for any Frappe/ERPNext custom app
- Containerising a Frappe app for production deployment
- A DevOps agent needs to produce a Containerfile for a Frappe-based tech stack

## Recommended Containerfile Template

This is the **standard pattern** for all Frappe apps. Replace `<app-name>` with the actual app name (snake_case, matching the app's Python package name).

```dockerfile
FROM docker.io/frappe/erpnext:version-15
USER root
WORKDIR /home/frappe/frappe-bench

# Create asset directory and fix permissions
RUN mkdir -p sites/assets/<app-name> && \
    chown -R frappe:frappe sites/assets

USER frappe

WORKDIR /home/frappe/frappe-bench

# Copy application files
COPY --chown=frappe:frappe . ./apps/<app-name>/

# Install app, register in apps.txt, verify asset directory
RUN env/bin/python3 -m pip install -e ./apps/<app-name> && \
    export BENCH_DEVELOPER=1 && \
    ls -1 ./apps > sites/apps.txt && \
    ls -l /home/frappe/frappe-bench/sites/assets/<app-name> && \
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

### Concrete Example — app named `invoicing`

```dockerfile
FROM docker.io/frappe/erpnext:version-15
USER root
WORKDIR /home/frappe/frappe-bench

RUN mkdir -p sites/assets/invoicing && \
    chown -R frappe:frappe sites/assets

USER frappe

WORKDIR /home/frappe/frappe-bench

COPY --chown=frappe:frappe . ./apps/invoicing/

RUN env/bin/python3 -m pip install -e ./apps/invoicing && \
    export BENCH_DEVELOPER=1 && \
    ls -1 ./apps > sites/apps.txt && \
    ls -l /home/frappe/frappe-bench/sites/assets/invoicing && \
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

### App Name Substitution Rules (Mandatory)

- Replace `<app-name>` everywhere with the real app slug (snake_case)
- Keep the copy target and pip path in sync:
  - `COPY --chown=frappe:frappe . ./apps/<app-name>/`
  - `pip install -e ./apps/<app-name>`
- Ensure asset path matches the same app slug:
  - `sites/assets/<app-name>`

Example for `qrcode`:

```dockerfile
RUN mkdir -p sites/assets/qrcode && \
    chown -R frappe:frappe sites/assets

COPY --chown=frappe:frappe . ./apps/qrcode/

RUN env/bin/python3 -m pip install -e ./apps/qrcode && \
    export BENCH_DEVELOPER=1 && \
    ls -1 ./apps > sites/apps.txt && \
    ls -l /home/frappe/frappe-bench/sites/assets/qrcode && \
    cat sites/apps.txt
```

## Version Selection

Use the version that matches the target Frappe/ERPNext deployment:

| Version | Base image tag | Notes |
|---------|---------------|-------|
| 15 | `version-15` | **Default for new apps** — stable, widely deployed |
| 16 | `version-16` | Latest, use when targeting v16 sites |
| 14 | `version-14` | Legacy, only for existing v14 deployments |

```dockerfile
FROM docker.io/frappe/erpnext:version-15
FROM docker.io/frappe/erpnext:version-16
FROM docker.io/frappe/erpnext:version-14
```

## Multi-App Containerfile

When packaging multiple custom apps into one image:

```dockerfile
FROM docker.io/frappe/erpnext:version-15
USER root
WORKDIR /home/frappe/frappe-bench

RUN mkdir -p sites/assets/app_one sites/assets/app_two && \
    chown -R frappe:frappe sites/assets

USER frappe

WORKDIR /home/frappe/frappe-bench

COPY --chown=frappe:frappe ./app_one ./apps/app_one/
COPY --chown=frappe:frappe ./app_two ./apps/app_two/

RUN env/bin/python3 -m pip install -e ./apps/app_one && \
    env/bin/python3 -m pip install -e ./apps/app_two && \
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

## Critical Rules

1. **Base image**: Always use `docker.io/frappe/erpnext:version-{VER}` — NEVER use generic UBI, Python, or Debian images
2. **Directory layout**: Apps live under `/home/frappe/frappe-bench/apps/<app-name>/`
3. **Asset directory**: Must create `sites/assets/<app-name>` and chown to `frappe:frappe`
4. **User context**: Start as `root` for mkdir/chown, switch to `frappe` before COPY and RUN
5. **apps.txt**: Must regenerate `sites/apps.txt` after installing the app (`ls -1 ./apps > sites/apps.txt`)
6. **pip install**: Use `env/bin/python3 -m pip install -e` (the bench virtualenv)
7. **Entry point**: Gunicorn with `frappe.app:application` — NOT `flask run`, NOT `bench start`
8. **Port**: Bind to `0.0.0.0:8000` (Frappe's standard port)
9. **COPY ownership**: Always use `--chown=frappe:frappe`
10. **No EXPOSE needed**: Port 8000 is implicit from the Gunicorn bind

## Build and Run

```bash
podman build -t my-frappe-app .
podman run -p 8000:8000 my-frappe-app
```

## Best Practices

- **Volume mounts for dev**: don't bake app source into the image during development — use compose.yml with volume mounts instead
- **Layer optimization**: combine RUN commands to reduce image layers
- **Permissions**: always set `--chown=frappe:frappe` when copying files
- **Multi-arch**: build for both amd64 and arm64 if distributing images
- **Version pinning**: pin specific version tags, never use `latest`

## Integration with frappe-new-app

When generating a new app, automatically include:

1. `Containerfile` using the template above
2. Place `Containerfile` in the app root directory
3. Default to `version-15` unless user specifies a version
