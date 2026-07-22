# Forking a Base OS for OffGridOS

This document outlines steps to fork a Linux distribution as a base for OffGridOS.

1. Choose upstream base
   - Debian/Ubuntu for broad hardware support and debootstrap
   - Alpine for small footprint

2. Create a minimal filesystem
   - Use `debootstrap` (Debian/Ubuntu) or `apk` (Alpine) to bootstrap a minimal rootfs.

3. Customize kernel and packages
   - Decide whether to use upstream kernels or build custom kernels.
   - Add only necessary packages for offline operation (ssh, small init, network tools).

4. Image formats
   - Docker image for containerized workloads
   - QCOW2/RAW for virtual machines with QEMU

5. Licensing and compliance
   - Keep track of licenses of packages you include.

6. Tips for off-grid
   - Minimize runtime dependencies and avoid automatic updates.
   - Include a curated package repository snapshot for offline package installs.
