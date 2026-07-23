# 5. OffGridOS Media Server Specification

## Product

**OffGridOS Media Server (OMS) Version 1.0 Alpha** is an offline-capable digital hub for media, documentation, local AI assistance, local communications, maps, knowledge preservation, and network services.

## Target hardware

Raspberry Pi 5, Intel N100/N305 systems, efficient mini PCs, repurposed laptops, and small home servers. Storage may use SSDs, HDDs, mirrored devices, or removable backup media.

## MVP services

- Local media library with hardware-appropriate transcoding
- Private file storage and shared folders
- Offline knowledge vault and searchable documentation
- Offline maps and location notes
- Local dashboard for service health, storage, temperature, and power data
- Backup and restore with clear status
- Optional local AI assistant with explicit data boundaries
- Local account and household access controls

## Non-functional requirements

The MVP must continue serving local clients without internet, recover after power loss, avoid unnecessary background work, support low-bandwidth administration, and provide logs understandable to a non-specialist operator.

## Acceptance criteria

An operator can install OMS, connect from a phone or laptop, add media and documents, use them offline, create a backup, restore it on replacement hardware, and identify service or storage failures from the dashboard.
