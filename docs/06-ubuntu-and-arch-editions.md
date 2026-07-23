# 6. Ubuntu and Arch Editions

## Edition strategy

Both editions share the same application contracts, documentation, data formats, and test suite. The difference is the operating-system experience and maintenance model.

## Ubuntu edition

Ubuntu LTS is the recommended stable edition for first-time operators, appliance images, managed deployments, and long-lived installations. It prioritizes predictable updates, broad vendor support, and conservative defaults.

## Arch edition

The Arch edition is for advanced users, development systems, lean installations, and users who want current packages and deeper control. It must include stronger warnings around update timing, snapshots, and recovery.

## Shared requirements

Hardware detection, installation validation, service health checks, firewall defaults, encrypted backup guidance, update rollback, and power-loss recovery must behave consistently. Documentation must clearly state what is edition-specific.

## Packaging

Prefer reproducible packages, pinned application versions for stable releases, signed artifacts, checksums, and a documented offline installation path. The installer must not require telemetry or an online account.
