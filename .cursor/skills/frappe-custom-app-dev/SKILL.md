---
name: frappe-custom-app-dev
description: Develop custom Frappe/ERPNext apps locally using SNE images with volume mounts. Covers bench new-app in a throwaway container, compose mounts, and day-to-day bench workflows.
---

# Custom App Development with SNE (Volume Mounts)

Develop custom Frappe apps by mounting source into a vyogo SNE image. The container auto-registers apps under `/home/frappe/frappe-bench/apps/` at startup (`pip install -e`, refresh `apps.txt`). You still run `bench install-app` once per site when needed.

## When to Use This Skill

Claude should invoke this skill when:
- User wants to create a new custom app and develop it with SNE
- User wants volume-mount based hot reload for a Frappe app
- User asks how to wire `compose.yml` for local app development
- User references scripts like `create_custom_app.sh` (bench new-app + compose update)

## Recommended Layout on the Host

Keep custom apps under an `apps/` directory next to `compose.yml`:

```
my-project/
  compose.yml
  apps/
    my_app/
      my_app/
        hooks.py
        ...
      setup.py
```

Mount path inside SNE must match the app name:

```yaml
volumes:
  - ./apps/my_app:/home/frappe/frappe-bench/apps/my_app
```

## Workflow A: Create the App with bench new-app (One-Off Container)

Use the same pattern as `create_custom_app.sh`: run a short-lived SNE container, mount an empty host folder, run `bench new-app` inside the bench directory.

```bash
APP_NAME=my_app
mkdir -p "apps/$APP_NAME"

docker run --rm -it \
  -v "$(pwd)/apps/$APP_NAME:/home/frappe/frappe-bench/apps/$APP_NAME" \
  docker.io/vyogo/erpnext:sne-version-16 \
  bash -c "set -e && cd /home/frappe/frappe-bench && bench new-app $APP_NAME"
```

Use `podman` instead of `docker` if preferred. Image tag can be `sne-version-15` or `sne-version-16` to match your target stack.

After this, add the volume to `compose.yml` (see below) and start the long-running dev container.

## Workflow B: Existing App + compose Only

If the app already exists on disk under `apps/my_app/`, only add the mount and start:

```yaml
services:
  frappe-sne:
    image: docker.io/vyogo/erpnext:sne-version-16
    ports:
      - "8000:8000"
    volumes:
      - ./apps/my_app:/home/frappe/frappe-bench/apps/my_app
```

```bash
docker compose up
# or: podman-compose up
```

## Install the App on the Site (First Time)

Auto-registration does not replace `install-app` on the site. After the dev container is up:

```bash
docker compose exec frappe-sne bash
bench --site dev.localhost install-app my_app
```

Default site is `dev.localhost`; default Administrator password is often `admin` on SNE images (confirm for your image version).

## Multiple Apps

Add one volume per app:

```yaml
    volumes:
      - ./apps/app_a:/home/frappe/frappe-bench/apps/app_a
      - ./apps/app_b:/home/frappe/frappe-bench/apps/app_b
```

## Persist Site Data (Optional)

To keep DB and site config across container recreation, mount `sites` and enable asset cache restore when using SNE:

```yaml
    volumes:
      - ./apps/my_app:/home/frappe/frappe-bench/apps/my_app
      - site_data:/home/frappe/frappe-bench/sites
    environment:
      - ENABLE_ASSETS_CACHE=true

volumes:
  site_data:
```

## Common bench Commands (Inside Container)

```bash
docker compose exec frappe-sne bash

bench --site dev.localhost migrate
bench --site dev.localhost clear-cache
bench build --app my_app
bench --site dev.localhost console
bench --site dev.localhost run-tests --app my_app
```

## Hot Reload Notes

- Python: editable install from the mount; web workers may need a restart for some changes.
- DocType JSON: run `bench migrate` after changes.
- JS/CSS: `bench build --app my_app` or rely on watchers depending on setup.

## Podman + SELinux

If bind mounts fail with permission errors on SELinux hosts, add the `:z` option on the volume line (e.g. `./apps/my_app:/home/frappe/frappe-bench/apps/my_app:z`).

## Troubleshooting

- **App not in `apps/` list**: Check mount path basename matches `app_name` in `hooks.py` / package name.
- **Import errors**: Ensure `pip install -e` succeeded; inspect container logs during startup.
- **App not on site**: Run `bench --site dev.localhost install-app <app>` once.

## Related Skills

- `frappe-sne-runner` — what SNE is, before/after vs multi-container stacks, image catalog.
- `frappe-compose-dev-generator` — minimal compose snippets for SNE-only dev.
