# 3. Technical Architecture

## Architecture goals

The system must be offline-first, modular, low-power, observable, recoverable, secure by default, and portable across supported Linux hardware.

## Layers

1. **Hardware:** Raspberry Pi 5, Intel N100/N305 mini PCs, laptops, small servers, storage, radio, sensors, and energy equipment.
2. **Operating system:** Ubuntu LTS and Arch-based editions with reproducible configuration.
3. **Runtime:** Containers or system services, local service registry, storage abstraction, and update manager.
4. **Applications:** OMS, knowledge vault, maps, AI, communications, monitoring, and Atlas modules.
5. **Synchronization:** Explicitly selected peer, removable-media, or cloud-assisted replication.

## Data model

Local data belongs to the operator. Services should use portable formats, stable identifiers, append-only event records where appropriate, and documented export paths. Sensitive data is encrypted at rest and in transit. Synchronization is opt-in and policy-controlled.

## Deployment profiles

- **Single node:** one server and local Wi-Fi/Ethernet network.
- **Household cluster:** primary node, backup node, and optional client devices.
- **Community network:** multiple trusted nodes with selective replication and local routing.
- **Store-and-forward:** removable media or intermittent links for disconnected locations.

## Reliability

Health checks, resource budgets, read-only recovery mode, versioned configuration, tested backups, and clear logs are required. No service may assume continuous internet access, public DNS, or unrestricted power.
