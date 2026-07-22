# OffGridOS

OffGridOS — a lightweight base OS fork and toolkit for off-grid deployments.

Quick start

- Build a Docker base image:

```bash
make docker-build
```

- Build the native base artifact (placeholder):

```bash
./scripts/build-base-image.sh
```

Purpose

This repository provides scaffolding and tooling to fork a minimal Linux distribution, produce images (Docker/QEMU), and layer customizations for offline/off-grid usage.

See the docs folder for forking and build instructions.
