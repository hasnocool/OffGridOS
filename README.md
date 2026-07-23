# OffGridOS

OffGridOS is an offline-first operating system and platform for resilient, self-sufficient communities.

It combines dependable local computing, renewable-energy-aware services, knowledge preservation, communications, maps, and community infrastructure. It is designed to remain useful when internet access is limited and to scale from a single household or vehicle to a connected regional network.

## Product direction

- OffGridOS Media Server (OMS) is the first consumer product: an offline-capable digital hub for media, documentation, local AI assistance, maps, communications, and network services.
- Ubuntu and Arch editions provide stable and flexible deployment paths.
- The wider platform adds energy monitoring, local AI, community Atlas services, resilient communications, trusted locations, and incentives for participating landowners and businesses.

## Repository structure

```text
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
├── atlas/          # Offline mapping
├── knowledge/      # Knowledge vault
├── installers/    # System installers
├── plugins/       # Plugin system
└── deployment/     # Deployment configurations
```

Core daemon, API, and dashboard code live in package repos under `packages/offgridos-core/`, `packages/offgridos-api/`, and `packages/offgridos-dashboard/`.

## Building

### Prerequisites

```bash
sudo apt install debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools
```

### Build Ubuntu edition

```bash
cd build
sudo ./build-ubuntu.sh
```

The ISO will be created in `build/output/`.

## Configuration

System configuration is sourced from `packages/offgridos-settings/` and installed into `/etc/offgridos/` during the ISO build:

```text
/etc/offgridos/
├── system.yaml
├── services.yaml
├── hardware.yaml
├── ai.yaml
├── energy.yaml
└── communications.yaml
```

## Documentation

1. [Vision and Business Plan](docs/01-vision-and-business-plan.md)
2. [Product Ecosystem](docs/02-product-ecosystem.md)
3. [Technical Architecture](docs/03-technical-architecture.md)
4. [Development Roadmap](docs/04-development-roadmap.md)
5. [Media Server Specification](docs/05-media-server-specification.md)
6. [Ubuntu and Arch Editions](docs/06-ubuntu-and-arch-editions.md)
7. [Community Atlas and Networking](docs/07-community-atlas-and-networking.md)
8. [Credits, Incentives, and Token Economics](docs/08-credits-incentives-and-token-economics.md)
9. [Security, Privacy, and Equipment Safety](docs/09-security-privacy-and-equipment-safety.md)
10. [Revenue and Go-to-Market](docs/10-revenue-and-go-to-market.md)
11. [Phase 1 Product Specification](docs/11-phase-1-product-specification.md)
12. [Governance and Contribution Standards](docs/12-governance-and-contribution-standards.md)

## License

See [LICENSE](LICENSE) for details.
