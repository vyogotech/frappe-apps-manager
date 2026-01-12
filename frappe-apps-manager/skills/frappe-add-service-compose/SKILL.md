---
name: Add Service to Dev Compose
description: Add a new microservice to dev-podman-compose.yml with proper configuration, dependencies, and networking.
---

# Add Service to Dev Compose

Add a new microservice to `dev-podman-compose.yml` following the established patterns.

## When to Use

- Adding a new microservice to local development environment
- Setting up service dependencies and networking
- Configuring environment variables
- Setting up volumes and ports

## Instructions

### 1. Service Template

Add to `dev-podman-compose.yml` in the `services:` section:

```yaml
  # <Service Name> Microservice
  <service-name>-service:
    image: localhost/frappe-microservices-base:latest
    ports:
      - "<port>:8000"  # Use next available port (8002, 8003, 8004, etc.)
    environment:
      - FRAPPE_SITE=dev.localhost
      - FRAPPE_SITES_PATH=/app/sites
      - PYTHONUNBUFFERED=1
      - CENTRAL_SITE_URL=http://dev-frappe-ms-poc-dev-central-site-1:8000
      # Database configuration (central site)
      - DB_HOST=dev-frappe-ms-poc-dev-central-site-1
      - DB_PORT=3306
      - DB_NAME=_9079b9524fe5ca86
      - DB_PASSWORD=687FNguLvKKbFH3T
      - DB_TYPE=mariadb
      # Redis configuration
      - REDIS_HOST=dev-frappe-ms-poc-dev-central-site-1
      - REDIS_PORT=6379
    depends_on:
      dev-central-site:
        condition: service_started
    networks:
      - dev-frappe-network
    volumes:
      - ./<service-name>-service:/app/service 
      - ./<service-name>-service/entrypoint.py:/app/entrypoint.py
      - dev_site_data:/app/sites:ro  # Optional: if service needs site data
      - ./frappe-microservice-lib/frappe_microservice:/opt/venv/lib/python3.11/site-packages/frappe_microservice:ro
```

### 2. Port Assignment

Check existing ports and use next available:
- 8000: Kong Gateway
- 8080: Central Site
- 8002: signup-service
- 8003: orders-service
- 8004: auth-service
- 8005: subscription-service
- 8006: company-service

**Next available**: 8007, 8008, etc.

### 3. Service Naming Convention

- Service name: `<service-name>-service` (kebab-case)
- Directory: `./<service-name>-service/` (matches service name)
- Container name: Auto-generated as `dev-frappe-ms-poc-<service-name>-service-1`

### 4. Dependencies

All services depend on `dev-central-site`:

```yaml
depends_on:
  dev-central-site:
    condition: service_started
```

If service depends on another microservice, add it:

```yaml
depends_on:
  dev-central-site:
    condition: service_started
  orders-service:
    condition: service_started
```

### 5. Volumes

**Required volumes**:
```yaml
volumes:
  - ./<service-name>-service:/app/service 
  - ./<service-name>-service/entrypoint.py:/app/entrypoint.py
  - ./frappe-microservice-lib/frappe_microservice:/opt/venv/lib/python3.11/site-packages/frappe_microservice:ro
```

**Optional volumes**:
```yaml
  - dev_site_data:/app/sites:ro  # If service needs site data (read-only)
```

### 6. Environment Variables

**Required**:
- `FRAPPE_SITE=dev.localhost`
- `FRAPPE_SITES_PATH=/app/sites`
- `PYTHONUNBUFFERED=1`
- `CENTRAL_SITE_URL=http://dev-frappe-ms-poc-dev-central-site-1:8000`
- Database config (DB_HOST, DB_PORT, DB_NAME, DB_PASSWORD, DB_TYPE)
- Redis config (REDIS_HOST, REDIS_PORT)

**Service-specific** (add as needed):
```yaml
- SERVICE_SPECIFIC_VAR=value
```

### 7. Add to Kong Gateway

Update `kong.yml` to add route for new service:

```yaml
services:
  - name: <service-name>-service
    url: http://<service-name>-service:8000
    routes:
      - name: <service-name>-route
        paths:
          - /<service-name>
```

Then update `dev-podman-compose.yml` Kong service dependencies:

```yaml
  kong:
    depends_on:
      - auth-service
      - signup-service
      - subscription-service
      - company-service
      - orders-service
      - <service-name>-service  # Add here
```

### 8. Complete Example

For a new `inventory-service` on port 8007:

```yaml
  # Inventory Microservice
  inventory-service:
    image: localhost/frappe-microservices-base:latest
    ports:
      - "8007:8000"
    environment:
      - FRAPPE_SITE=dev.localhost
      - FRAPPE_SITES_PATH=/app/sites
      - PYTHONUNBUFFERED=1
      - CENTRAL_SITE_URL=http://dev-frappe-ms-poc-dev-central-site-1:8000
      - DB_HOST=dev-frappe-ms-poc-dev-central-site-1
      - DB_PORT=3306
      - DB_NAME=_9079b9524fe5ca86
      - DB_PASSWORD=687FNguLvKKbFH3T
      - DB_TYPE=mariadb
      - REDIS_HOST=dev-frappe-ms-poc-dev-central-site-1
      - REDIS_PORT=6379
    depends_on:
      dev-central-site:
        condition: service_started
    networks:
      - dev-frappe-network
    volumes:
      - ./inventory-service:/app/service 
      - ./inventory-service/entrypoint.py:/app/entrypoint.py
      - ./frappe-microservice-lib/frappe_microservice:/opt/venv/lib/python3.11/site-packages/frappe_microservice:ro
```

### 9. Verification Steps

After adding service:

1. **Check syntax**:
   ```bash
   podman compose -f dev-podman-compose.yml config
   ```

2. **Start service**:
   ```bash
   podman compose -f dev-podman-compose.yml up -d <service-name>-service
   ```

3. **Check logs**:
   ```bash
   podman compose -f dev-podman-compose.yml logs <service-name>-service
   ```

4. **Test endpoint**:
   ```bash
   curl http://localhost:<port>/health
   ```

## Key Patterns

1. **Consistent Naming**: Use kebab-case for service names
2. **Port Management**: Track used ports, use next available
3. **Dependencies**: Always depend on central-site
4. **Volumes**: Mount service code and library
5. **Environment**: Use same DB/Redis config as other services
6. **Networking**: Use `dev-frappe-network` for all services

## Common Issues

- **Port conflicts**: Check existing ports before assigning
- **Volume paths**: Ensure service directory exists
- **Dependencies**: Add to Kong depends_on if using gateway
- **Environment vars**: Copy from existing service, adjust as needed
