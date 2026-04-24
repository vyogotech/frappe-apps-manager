---
name: frappeforge-ingestion-tool
description: Trigger and monitor FrappeForge code graph ingestion from GitHub repositories into Neo4j.
---

# FrappeForge Ingestion Tool

Ingest Frappe/ERPNext GitHub repositories into the Neo4j knowledge graph.
The ingestion service runs at `https://frappeforge.atxinvox.com.au` (or `http://localhost:8080` with port-forward).

## API Endpoints

### Trigger Ingestion

```bash
POST /api/ingest/github
Content-Type: application/json

{
  "url": "https://github.com/frappe/erpnext",
  "branch": "version-16"
}
```

Response (async — ingestion runs in background):
```json
{
  "status": "ingestion_started",
  "project": "erpnext",
  "version": "version-16"
}
```

**Supported fields:** `url` or `repoUrl`, `branch` (defaults to `main`)

### Check Status

```bash
GET /api/projects
```

Returns list of ingested projects with `status` (`running` | `success`), `version`, and `lastUpdated`.

### Stats

```bash
GET /api/stats
```

Returns node counts: `docTypes`, `methods`, `fields`, `projects`, `nodes`.

### Ingestion Logs

```bash
GET /api/logs
```

Returns recent log entries with `level` (`INFO` | `SUCCESS` | `ERROR`) and `message`.

### Health

```bash
GET /api/health
```

### Graph Data (UI)

```bash
GET /api/graph
```

Returns up to 500 nodes and 1000 edges (DocType/Method/Field) for visualisation.

## Re-Ingest All 3 Core Apps

```bash
BASE=https://frappeforge.atxinvox.com.au

for app in frappe erpnext hrms; do
  curl -s -X POST $BASE/api/ingest/github \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"https://github.com/frappe/$app\", \"branch\": \"version-16\"}"
  echo " → $app triggered"
done
```

## Neo4j Graph Model

After ingestion, the graph contains:

| Node Label   | Key Properties                    |
|--------------|-----------------------------------|
| Project      | name, url, version, status        |
| DocType      | id, name, module, app             |
| Field        | id, fieldname, fieldtype, app     |
| Method       | id, qualname, path, app           |
| Controller   | id, className, path, app          |
| Hook         | id, doctype, event, handler, app  |
| ClientScript | id, doctype, path, type, app      |
| ClientEvent  | id, doctype, event, path, app     |

All nodes have `version` (e.g. `version-16`) and `app` (e.g. `erpnext`).

Key relationships: `HAS_FIELD`, `CALLS`, `HAS_CONTROLLER`, `REGISTERS_HOOK`,
`HAS_CLIENT_SCRIPT`, `HANDLES_EVENT`, `BELONGS_TO` (→ Project).

## Useful Neo4j Queries

```cypher
-- All DocTypes in ERPNext
MATCH (d:DocType {app: 'erpnext'}) RETURN d.name ORDER BY d.name

-- Methods that call a specific method
MATCH (a:Method)-[:CALLS]->(b:Method {id: 'Method::path::qualname'})
RETURN a.id, a.qualname

-- Everything linked to a project
MATCH (n)-[:BELONGS_TO]->(p:Project {name: 'erpnext'})
RETURN labels(n)[0] as type, count(n) as count

-- DocType with its fields
MATCH (d:DocType {name: 'Sales Order'})-[:HAS_FIELD]->(f:Field)
RETURN d.name, f.fieldname, f.fieldtype ORDER BY f.fieldname
```

## Local Port-Forward (Bolt access)

```bash
KUBECONFIG=~/personal/vyogo/r740-iac/ansible-atxinvox/kubeconfig-k3s \
  kubectl port-forward svc/frappeforge-neo4j-lb-neo4j 7474:7474 7687:7687 \
  -n frappeforge-system
```

Then open Neo4j Browser at `http://localhost:7474` with `bolt://localhost:7687`, user `neo4j`, password `frappeforge`.
