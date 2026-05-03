---
name: frappe-vue-component-integrator
description: Create and integrate custom Vue 3 components into Frappe Pages, Doctype Views, or Dialogs. Covers mounting, Pinia state management, and asset bundling via esbuild.
---

# Vue 3 Integration in Frappe

Frappe's modern desk allows mounting Vue 3 applications into standard UI wrappers (Pages, Doctype forms, or Dialogs). This pattern is superior to jQuery for complex, state-driven interfaces.

## When to Use This Skill

Invoke this skill when:
- User wants to build a complex dashboard or interactive widget in Frappe.
- Requirement involves real-time UI updates or complex state management (Pinia).
- Building a custom page that needs modern frontend components.

## 1. Directory Structure

Place your Vue source files in `public/js/` under a dedicated folder:

```
my_app/
  public/
    js/
      my-component/
        App.vue
        store.js (Pinia)
        components/
          Widget.vue
      my_component.bundle.js (Entry Point)
```

## 2. The Vue Component (`App.vue`)

Use Vue 3 Composition API for best results.

```vue
<template>
  <div class="my-app-container">
    <h1>{{ title }}</h1>
    <div class="stats-grid">
      <div v-for="stat in stats" :key="stat.label" class="stat-card">
        <h3>{{ stat.value }}</h3>
        <p>{{ stat.label }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

const props = defineProps(['title', 'initialData']);
const stats = ref(props.initialData || []);

onMounted(() => {
  console.log("Vue component mounted for:", props.title);
});
</script>

<style scoped>
.my-app-container { padding: 20px; }
.stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; }
.stat-card { border: 1px solid #ddd; padding: 15px; border-radius: 8px; }
</style>
```

## 3. The Bundle Entry Point (`my_component.bundle.js`)

This file is the bridge between Frappe (jQuery/Vanilla) and Vue.

```javascript
import { createApp } from "vue";
import { createPinia } from "pinia";
import App from "./my-component/App.vue";

frappe.provide("frappe.my_app.ui");

class MyComponentManager {
  constructor({ wrapper, page, settings }) {
    this.$wrapper = $(wrapper);
    this.page = page;
    this.settings = settings;
    this.init();
  }

  init() {
    const pinia = createPinia();
    const app = createApp(App, {
      title: this.settings.title,
      initialData: this.settings.data
    });

    app.use(pinia);
    
    // Set global frappe variables if needed in Vue
    app.config.globalProperties.$frappe = window.frappe;

    // Mount to the jQuery wrapper
    this.vue_app = app.mount(this.$wrapper.get(0));
  }
}

frappe.my_app.ui.MyComponentManager = MyComponentManager;
export default MyComponentManager;
```

## 4. Integration in Frappe Page

```javascript
frappe.pages['my-dashboard'].on_page_load = function(wrapper) {
    let page = frappe.ui.make_app_page({
        parent: wrapper,
        title: 'Vue Dashboard',
        single_column: true
    });

    // 1. Load the bundle
    frappe.require("my_component.bundle.js").then(() => {
        // 2. Initialize the bridge class
        new frappe.my_app.ui.MyComponentManager({
            wrapper: $(wrapper).find('.layout-main-section'),
            page: page,
            settings: {
                title: "Active Users",
                data: [{label: "Total", value: 100}]
            }
        });
    });
}
```

## 5. Register in `hooks.py`

Ensure Frappe bundles the JS during `bench build`.

```python
app_include_js = [
    "my_component.bundle.js"
]
```

## Key Pattern: The Bridge Class

Always use a "Bridge Class" (like `MyComponentManager`) in the bundle. This allows:
- Access to the `frappe.Page` object inside Vue if passed as a prop.
- Proper cleanup if the page is destroyed.
- Decoupling the Vue app from the Frappe page lifecycle logic.
