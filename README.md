# OffGridOS

An offline-first operating system for off-grid, adventure, and homestead users.

## Overview

OffGridOS provides long-range communications, entertainment, news, and essential services using free, distributed technologies — all working completely offline.

## Features

- **Offline-First Computing** — Full functionality without internet
- **Local AI Assistant** — RAG search, troubleshooting, planning
- **Energy Monitoring** — Solar, battery, power statistics
- **Knowledge Vault** — Offline documentation and manuals
- **Offline Maps** — Resource markers, campsites, water sources
- **Communications** — LoRa, Meshtastic, SDR support
- **Modular Plugins** — Extend functionality as needed

## Supported Hardware

### Tier 1
- Raspberry Pi 5 (8GB+ RAM, 256GB+ SSD)
- Intel N100 Mini PC (16GB+ RAM, 500GB+ NVMe)
- AMD Mini PC (Ryzen 5600U/7840HS)

## Distributions

| Edition | Base | Target Users |
|---------|------|--------------|
| OffGridOS Ubuntu | Ubuntu 24.04 LTS | Homestead, community deployments |
| OffGridOS Arch | Arch Linux | Developers, advanced users |

## Building

### Prerequisites

```bash
sudo apt install debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools
```

### Build Ubuntu Edition

```bash
cd build
sudo ./build-ubuntu.sh
```

The ISO will be created in `build/output/`.

## Repository Structure

```
offgridos/
├── docs/           # Documentation
├── build/          # Build system and scripts
├── packages/       # Package repos and package index
│   ├── offgridos-core/
│   ├── offgridos-api/
│   ├── offgridos-dashboard/
│   ├── offgridos-branding/
│   ├── offgridos-theme/
│   ├── offgridos-icons/
│   ├── offgridos-wallpapers/
│   ├── offgridos-welcome/
│   ├── offgridos-installer/
│   ├── offgridos-settings/
│   ├── offgridos-update/
│   ├── offgridos-media/
│   ├── offgridos-ai/
│   ├── offgridos-network/
│   └── offgridos-recovery/
├── core/           # OffGridOS Core Daemon (offgridd)
├── services/       # Backend services
├── plugins/        # Plugin system
├── dashboard/      # Web dashboard
├── api/            # FastAPI backend
├── atlas/          # Offline mapping
├── ai/             # Local AI assistant
├── knowledge/      # Knowledge vault
├── installers/     # System installers
└── deployment/     # Deployment configurations
```

## Configuration

System configuration is now sourced from `packages/offgridos-settings/` and installed into `/etc/offgridos/` during the ISO build:

```
/etc/offgridos/
├── system.yaml
├── services.yaml
├── hardware.yaml
├── ai.yaml
├── energy.yaml
└── communications.yaml

Core daemon, API, and dashboard code now live in package repos under `packages/offgridos-core/`, `packages/offgridos-api/`, and `packages/offgridos-dashboard/`.
```

## Documentation

- [Phase 1 Specification](SPEC.md)
- [Architecture](docs/architecture.md)
- [Contributing](docs/contributing.md)

## License

See [LICENSE](LICENSE) for details.
