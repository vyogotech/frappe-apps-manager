---
name: frappe-containerfile-generator
description: Generate Containerfile for Frappe apps based on vyogo's sne image patterns for version 15, following the Containerfile_v15 template.
---

# Frappe Containerfile Generator

Generate production-ready Containerfile for Frappe applications using vyogo's sne images (version 15).

## When to Use This Skill

Claude should invoke this skill when:
- User wants to create a Containerfile for a Frappe app
- User is setting up containerized development
- User needs to build a Docker image for their Frappe app
- User mentions containerization, Docker, or Containerfile
- During app generation (frappe-new-app) to include Containerfile

## Capabilities

### 1. Containerfile Template (Version 15)

Generate `Containerfile` based on the v15 pattern:

```dockerfile
FROM docker.io/frappe/erpnext:version-15
USER root
WORKDIR /home/frappe/frappe-bench

# Create necessary directories and set permissions
RUN mkdir -p sites/assets/<app-name> && \
    chown -R frappe:frappe sites/assets

USER frappe

WORKDIR /home/frappe/frappe-bench

# Copy application files
COPY --chown=frappe:frappe . ./apps/<app-name>/

# Install and build in a single layer
RUN env/bin/python3 -m pip install -e ./apps/<app-name> && \
    export BENCH_DEVELOPER=1 && \
    ls -1 ./apps > sites/apps.txt && \
    ls -l /home/frappe/frappe-bench/sites/assets/<app-name> && \
    # Update apps.txt properly
    cat sites/apps.txt

# Use fixed Gunicorn params as in original
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

### 2. App-Specific Customization

Replace `<app-name>` with the actual app name (snake_case):
- `projectnext` → `./apps/projectnext/`
- `my_custom_app` → `./apps/my_custom_app/`

### 3. Version Variations

**For Version 14:**
```dockerfile
FROM docker.io/frappe/erpnext:version-14
# ... rest remains the same
```

**For Version 13:**
```dockerfile
FROM docker.io/frappe/erpnext:version-13
# ... rest remains the same
```

### 4. Development vs Production

**Development (with hot-reload):**
```dockerfile
# Add volume mount in compose.yml instead
# Keep Containerfile same for development
```

**Production:**
```dockerfile
# Use the standard template above
# Assets are built during image build
```

### 5. Multi-App Support

If app depends on other apps:

```dockerfile
# Copy multiple apps
COPY --chown=frappe:frappe ./app1 ./apps/app1/
COPY --chown=frappe:frappe ./app2 ./apps/app2/

# Install all apps
RUN env/bin/python3 -m pip install -e ./apps/app1 && \
    env/bin/python3 -m pip install -e ./apps/app2 && \
    export BENCH_DEVELOPER=1 && \
    ls -1 ./apps > sites/apps.txt
```

### 6. Custom Build Steps

Add custom build steps if needed:

```dockerfile
# After copying app files, before install
RUN # Custom build commands here

# Install app
RUN env/bin/python3 -m pip install -e ./apps/<app-name>
```

### 7. Environment Variables

Add environment variables if needed:

```dockerfile
ENV BENCH_DEVELOPER=1
ENV FRAPPE_SITE=default
# Add other environment variables as needed
```

## Key Patterns

1. **Base Image**: Always use `docker.io/frappe/erpnext:version-15` (or appropriate version)
2. **User Context**: Switch to `frappe` user after root operations
3. **Directory Structure**: Follow `/home/frappe/frappe-bench` structure
4. **Asset Directory**: Create `sites/assets/<app-name>` for app assets
5. **Installation**: Use `pip install -e` for editable install
6. **Apps.txt**: Always update `sites/apps.txt` with installed apps
7. **Gunicorn**: Use fixed Gunicorn parameters for production

## Best Practices

- **Layer Optimization**: Combine RUN commands to reduce layers
- **Permissions**: Always set proper ownership with `--chown=frappe:frappe`
- **Asset Directory**: Create asset directory before copying files
- **Apps.txt**: Update apps.txt to register the app
- **Gunicorn Config**: Use production-ready Gunicorn settings
- **Version Pinning**: Pin specific version tags, not `latest`

## Integration with frappe-new-app

When generating a new app, automatically include Containerfile:

1. After app creation, generate Containerfile
2. Use app name from app creation
3. Place Containerfile in app root directory
4. Inform user about containerization options

## Example Output

For app named `projectnext`:

```dockerfile
FROM docker.io/frappe/erpnext:version-15
USER root
WORKDIR /home/frappe/frappe-bench

# Create necessary directories and set permissions
RUN mkdir -p sites/assets/projectnext && \
    chown -R frappe:frappe sites/assets

USER frappe

WORKDIR /home/frappe/frappe-bench

# Copy application files
COPY --chown=frappe:frappe . ./apps/projectnext/

# Install and build in a single layer
RUN env/bin/python3 -m pip install -e ./apps/projectnext && \
    export BENCH_DEVELOPER=1 && \
    ls -1 ./apps > sites/apps.txt && \
    ls -l /home/frappe/frappe-bench/sites/assets/projectnext && \
    # Update apps.txt properly
    cat sites/apps.txt

# Use fixed Gunicorn params as in original
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
