#!/usr/bin/env bash
set -euo pipefail

echo "This script is a placeholder to build a minimal base image for OffGridOS."

echo "On Debian/Ubuntu hosts you can use debootstrap to create a minimal filesystem."

echo "Example: sudo debootstrap --arch=amd64 jammy ./chroot http://archive.ubuntu.com/ubuntu/"

echo "Then package the filesystem into a tarball or convert to a QCOW2 image using qemu-img."

exit 0
