---
name: frappe-web-tool-porter
description: Integrate third-party web tools (jQuery plugins, legacy JS libraries, or standalone HTML tools) into Frappe Pages or Doctype views. Covers asset migration, path refactoring, and lifecycle management.
---

# Integrating External Web Tools in Frappe

When standard Frappe UI components are insufficient, you can integrate external libraries (e.g., jQuery Gantt, specialized editors, or 3D viewers) into a Frappe Page.

## When to Use This Skill

Invoke this skill when:
- User wants to port a standalone HTML/JS tool into Frappe.
- Requirement involves legacy jQuery plugins (Gantt, Organigram, etc.).
- You need to load a large number of external CSS/JS dependencies for a single page.

## 1. Asset Migration

Move all external resources (JS, CSS, images, fonts) into your custom app's `public` directory. Organize them under a `libs` folder to avoid clutter.

```
my_app/
  public/
    js/
      libs/
        gantt/
          ganttMaster.js
          gantt.css
          images/
```

## 2. Refactor External CSS/JS Paths

External libraries often use relative paths for images or imports (e.g., `url('../images/icon.png')`). You **MUST** update these to absolute Frappe asset paths:

- **Original**: `../images/my-icon.png`
- **Refactored**: `/assets/my_app/js/libs/gantt/images/my-icon.png`

## 3. Creating the Page Wrapper

Create a new Frappe Page. In the `.js` file, use `frappe.require` to load the dependency tree before initializing the tool.

### Pattern: `frappe.require` Dependency Loading

```javascript
frappe.pages["my-external-tool"].on_page_load = function(wrapper) {
    let page = frappe.ui.make_app_page({
        parent: wrapper,
        title: __("External Tool Title"),
        single_column: true
    });

    // Load multiple dependencies in order
    frappe.require([
        '/assets/my_app/css/tool_style.css',
        '/assets/my_app/js/libs/tool_dependency.js',
        '/assets/my_app/js/libs/main_tool_logic.js'
    ]).then(() => {
        // Initialize the tool after resources are loaded
        new MyExternalTool(wrapper, page);
    });
};
```

## 4. Injecting the HTML Structure

External tools usually expect a specific DOM structure. Inject this into `page.main`.

```javascript
class MyExternalTool {
    constructor(wrapper, page) {
        this.wrapper = $(wrapper);
        this.page = page;
        this.setup_dom();
        this.init_plugin();
    }

    setup_dom() {
        // Inject the tool's required HTML
        this.wrapper.find('.layout-main-section').append(`
            <div id="tool-container" style="height: 600px;">
                <div class="tool-toolbar"></div>
                <div class="tool-workspace"></div>
            </div>
        `);
    }

    init_plugin() {
        // Call the third-party jQuery/JS initializer
        $("#tool-container").myPlugin({
            data: [],
            onSave: (data) => this.save_to_frappe(data)
        });
    }

    save_to_frappe(data) {
        frappe.call({
            method: "my_app.api.save_data",
            args: { data: data },
            callback: (r) => frappe.show_alert(__("Saved"))
        });
    }
}
```

## 5. Handling Hot Reload and Resizing

- **Show Event**: Use `$(wrapper).bind("show", ...)` to re-render or refresh the tool when the user navigates back to the page.
- **Resize**: If the tool has a custom scroll or grid, listen for `window.resize` to adjust the container height relative to Frappe's navbar and footer.

## 6. Registration in `hooks.py`

If the tool is needed globally (rare), add to `app_include_js`. Otherwise, rely on `frappe.require` within the page to keep the initial desk load light.
