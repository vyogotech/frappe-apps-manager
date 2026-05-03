---
name: frappe-sne-image-builder
description: Build bootable SNE (Simple-No-Errors) images for Frappe custom apps using S2I (Source-to-Image) and Frappista scripts. Enables automated image generation for production and high-fidelity dev environments.
---

# SNE Image Building with S2I & Frappista

This skill automates the creation of "bootable" Frappe images. Unlike standard images, SNE images are pre-configured to initialize the bench, install custom apps, and prepare the site environment upon startup.

## When to Use This Skill

Invoke this skill when:
- Creating a CI/CD pipeline for a custom Frappe app.
- Building a standalone production image that includes the app and all its dependencies.
- Automating the generation of "SNE" (Simple-No-Errors) images for the Vyogo platform.

## 1. Prerequisites (S2I Installation)

The build environment must have the `s2i` binary installed.

```bash
wget -q https://github.com/openshift/source-to-image/releases/download/v1.3.1/source-to-image-v1.3.1-a5a77147-linux-amd64.tar.gz
sudo tar xzf source-to-image-v1.3.1-a5a77147-linux-amd64.tar.gz -C /usr/local/bin ./s2i
rm -f source-to-image-v1.3.1-a5a77147-linux-amd64.tar.gz
```

## 2. Generate the S2I Dockerfile

S2I takes your source code and a base image (e.g., `erpnext:sne-version-16`) and produces a Dockerfile that "assembles" the app.

```bash
# From the root of the custom app
s2i build . docker.io/vyogo/erpnext:sne-version-16 \
    --as-dockerfile /tmp/sne-build/Dockerfile
```

## 3. Inject Frappista Scripts

To make the image "bootable" and robust, we inject optimized S2I scripts from the **Frappista** project.

```bash
# Clone Frappista
git clone --depth 1 --branch version-16 \
    https://github.com/vyogotech/frappista.git /tmp/frappista

# Copy scripts to the build context
mkdir -p /tmp/sne-build/upload/scripts
cp -r /tmp/frappista/s2i/bin/* /tmp/sne-build/upload/scripts/

# Inject the COPY command into the generated Dockerfile
# We insert it before the default 'assemble' script execution
sed -i '/\/usr\/libexec\/s2i\/assemble/i COPY upload/scripts /usr/libexec/s2i/' \
    /tmp/sne-build/Dockerfile
```

## 4. Build and Push

Once the Dockerfile is patched, use standard build tools (Docker/Buildx/Podman) to create the final image.

```bash
docker build -t my-registry/my-app:v1.0 /tmp/sne-build/
docker push my-registry/my-app:v1.0
```

## Summary of the Build Logic

1. **Source**: The custom app's repository.
2. **Base**: `vyogo/erpnext:sne-version-16` (S2I-enabled base).
3. **Builder**: `s2i` handles the heavy lifting of installing dependencies.
4. **Enabler**: `frappista` scripts handle the runtime site initialization and app installation.
