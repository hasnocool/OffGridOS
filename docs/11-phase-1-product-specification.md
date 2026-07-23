# 11. Phase 1 Product Specification

## Objective

Produce a dependable OMS Alpha that can be installed and operated by a household with basic computer skills.

## Scope

Included: installer, supported hardware profiles, local dashboard, media library, file shares, knowledge vault, offline maps, user access, backup/restore, health checks, update/rollback guidance, and operator documentation.

Deferred: public Atlas marketplace, transferable token settlement, autonomous safety-critical controls, multi-region identity, and mandatory cloud services.

## Technical deliverables

1. Reproducible Ubuntu image or installer.
2. Arch installation profile and validation checklist.
3. Service definitions with health checks and resource limits.
4. Local-first data schema and export format.
5. Backup, restore, and replacement-device procedure.
6. Test fixture covering power loss, no internet, full storage, failed service, and upgrade rollback.

## Definition of done

The release is complete when a fresh operator can install it, access every included feature without internet, recover from a simulated failure, restore data to replacement hardware, and follow the documentation without undocumented administrator steps.
