---
name: frappe-desk-branding
description: >-
  Implements or adjusts Frappe Desk branding (colors, typography, navbar/logo,
  login/splash, boot payload, Navbar Settings). Use when customizing Frappe
  Desk UI theme, replacing the default logo, setting app_color, wiring
  app_include_css/js, extend_bootinfo, or exporting Navbar Settings fixtures.
---

# Frappe Desk Branding

## Goal

Apply **Desk-wide** visual branding using Frappe’s hooks and assets: palette + typography, navbar/home logo, optional login/splash tweaks, and consistent values in `frappe.boot` for client scripts.

Use **placeholders** (`YOUR_APP`, `YOUR_PRIMARY_HEX`, logo path) — keep the skill vendor-neutral.

## Prerequisites

- Custom app package (e.g. `your_app/`) with `hooks.py` on the Python path.
- Static files under `your_app/public/` (built to `/assets/your_app/...` after `bench build` or equivalent).

## Implementation checklist

1. **Assets**
   - Add logo(s) under `your_app/public/images/` (SVG or PNG).
   - Prefer one “full color” mark for light backgrounds and optionally a monochrome/inverted variant for dark navbars.

2. **`hooks.py` — global CSS/JS**
   - `app_include_css`: path under `/assets/your_app/css/...` for Desk.
   - `app_include_js`: optional client script for DOM/boot-dependent tweaks.
   - `web_include_css`: optional; reuse theme CSS for website templates if desired.

3. **`hooks.py` — built-in branding fields**
   - `app_logo_url`: `/assets/your_app/images/your-logo.svg` (or PNG).
   - `app_color`: primary accent as hex (e.g. `"#2563eb"`).
   - `website_context`: optional `brand_html` (snippet replacing default brand markup where applicable).

4. **Boot payload — `extend_bootinfo`**
   - Register in `hooks.py`: `extend_bootinfo = "your_app.boot.extend_bootinfo"`.
   - In `your_app/boot.py`, define `extend_bootinfo(bootinfo)` and set:
     - `bootinfo.app_name`, `bootinfo.app_logo_url`, `bootinfo.brand_html` as needed.
     - Optional nested dict e.g. `bootinfo.theme` for colors the client reads at runtime.

5. **Navbar logo (database)**
   - Set **Navbar Settings → App Logo** via Desk **or** ship a fixture JSON and list it under `fixtures` in `hooks.py` so installs stay consistent.

6. **Theme CSS (`public/css/...`)**
   - Override Frappe CSS variables on `:root`, commonly:
     - `--primary-color`, `--navbar-bg`, `--navbar-color`, sidebar/workspace-related vars if used by your version.
   - Scope additional rules to Desk selectors (navbar, `.btn-primary`, form focus, list/workspace shells, login `.for-login`, splash `#startup_div` / `.splash` if needed).
   - Prefer variables + light overrides over copying large upstream bundles.

7. **Optional client JS (`public/js/...`)**
   - Run after boot: `frappe.ready`, `$(document).on('startup', ...)`, and `frappe.router.on('change', ...)` if the navbar re-renders.
   - Typical tasks: inject webfont `<link>`, set `document.title`, replace `.navbar-home a` innerHTML from `frappe.boot.brand_html`, apply `document.documentElement.style.setProperty('--primary-color', ...)`.
   - Override toolbar helpers only when necessary (e.g. custom About dialog); prefer standard `frappe.ui.toolbar.show_about` behavior unless product requires a bespoke panel.

8. **Verify**
   - Hard refresh / clear cache after asset changes.
   - Confirm Desk, login, and splash (if styled) and that router navigation does not revert the navbar brand.

## Minimal patterns (templates)

### `extend_bootinfo`

```python
def extend_bootinfo(bootinfo):
    bootinfo.app_name = "YOUR_SHORT_APP_LABEL"
    bootinfo.app_logo_url = "/assets/your_app/images/your-logo.svg"
    bootinfo.brand_html = (
        '<img src="/assets/your_app/images/your-logo.svg" '
        'alt="YOUR_PRODUCT_NAME" class="app-logo" style="height: 28px;">'
    )
    bootinfo.theme = {
        "primary_color": "#YOUR_PRIMARY_HEX",
        "navbar_bg": "#YOUR_NAVBAR_HEX",
    }
    return bootinfo
```

### `hooks.py` snippets

```python
app_include_css = "/assets/your_app/css/desk-branding.css"
app_include_js = "/assets/your_app/js/desk-branding.js"

app_logo_url = "/assets/your_app/images/your-logo.svg"
app_color = "#YOUR_PRIMARY_HEX"

extend_bootinfo = "your_app.boot.extend_bootinfo"

fixtures = [
    {"doctype": "Navbar Settings", "filters": [["name", "=", "Navbar Settings"]]},
]
```

### CSS variables (starter)

```css
:root {
    --brand-primary: #YOUR_PRIMARY_HEX;
    --brand-navbar-bg: #YOUR_NAVBAR_HEX;
    --brand-navbar-fg: #YOUR_NAVBAR_TEXT_HEX;
    --primary-color: var(--brand-primary);
    --navbar-bg: var(--brand-navbar-bg);
    --navbar-color: var(--brand-navbar-fg);
}
```

## Guardrails

- Do **not** commit secrets or license-restricted artwork; use org-approved assets.
- Keep overrides **maintainable**: prefer CSS variables and targeted selectors; avoid `!important` unless fighting upstream specificity briefly.
- Test across **light/dark** if Theme Switcher remains enabled; variables may need both themes or neutral defaults.

## When not to use this skill

- Website-only theming without Desk: consider Website Theme / SCSS hooks instead.
- Deep UX redesigns: this skill covers branding surfaces, not wholesale layout rewrites.
