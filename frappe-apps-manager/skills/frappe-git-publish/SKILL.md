---
name: frappe-git-publish
description: After Frappe codegen, commit locally with frappe_tool then publish to GitHub using GitHub MCP or git remote.
---

# Frappe Git publish (Hermes / FrappeForge)

## When to use

- Immediately after completing the Implementation Task Plan for a generated Frappe app.
- After `frappe_tool` with `git_commit_all` has produced a successful commit (or `nothing_to_commit` if the tree was already clean).
- When the user wants code on GitHub (new repository, existing remote, or pull request).

## Mandatory local step

1. Call `frappe_tool` with `action=git_commit_all`, correct `app_name` (snake_case bench app id), and a meaningful `commit_message` (e.g. `feat: add leave application DocType`).
2. If the result includes `nothing_to_commit: true`, you may skip push only if there truly were no file changes since the last commit; otherwise fix files and commit again.
3. Optionally call `frappe_tool` with `action=git_status` to confirm the working tree is clean.

Local git identity for non-interactive commits uses `FRAPPEFORGE_GIT_AUTHOR_NAME` and `FRAPPEFORGE_GIT_AUTHOR_EMAIL` when set; otherwise sensible defaults are applied per repository via `git config` (not global).

## Publishing to GitHub (no duplicate MCP)

Do **not** implement a custom GitHub MCP server. Use the **hosted GitHub MCP** over HTTP (same surface as GitHub Copilot’s MCP gateway):

- **URL:** `https://api.githubcopilot.com/mcp/`
- **Config:** see `hermes/config.yaml.example` under `mcp_servers.github` (`url` + `Authorization: Bearer …` using `GITHUB_TOKEN`).
- **Env-only installs:** set `HERMES_MCP_github=https://api.githubcopilot.com/mcp/` and `GITHUB_TOKEN`; FrappeForge `configure_model.py` merges the URL and injects the `Authorization` header for the `github` server name.

If your editor or platform uses a JSON wrapper with `servers.github.type: http` and the same URL, that is equivalent to Hermes’ `mcp_servers.github.url` HTTP transport.

Typical patterns:

- **New repo**: use GitHub MCP tools exposed in your session (repository create, default branch, push policy per server capabilities). If MCP cannot push binary trees from disk, use `terminal` in the app root (`poc_sandbox/apps/<app>/`) with `git remote add`, `git push` using an HTTPS remote URL that embeds the PAT **only inside the container session** — prefer MCP file APIs when the server supports them.
- **Existing repo / PR**: create a branch locally (`terminal`), `git push -u origin <branch>`, then GitHub MCP to open a pull request against the default branch.

If GitHub MCP is **not** enabled, tell the user to add the `github` HTTP block to `~/.hermes/config.yaml` (or set `HERMES_MCP_github` + `GITHUB_TOKEN`), restart Hermes, and re-run publish steps.

**Optional fallback:** local stdio `@modelcontextprotocol/server-github` remains documented in `hermes/config.yaml.example` as a commented block when HTTP is unsuitable.

## Paths

- Default generated app root (Hermes overlay layout): `poc_sandbox/apps/<app_name>/` (outer bench app directory containing `setup.py` and the inner Python package).

## Security

- Never print `GITHUB_TOKEN` or embed it in skills, commits, or logs.
- Prefer short-lived fine-grained tokens with least privilege (`repo`, `pull_requests` as needed).
