#!/bin/bash
# OffGridOS Ubuntu Build Script
# Creates a customized Ubuntu 24.04 LTS respin

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/work"
OUTPUT_DIR="${SCRIPT_DIR}/output"
PACKAGES_ROOT="${SCRIPT_DIR}/../packages"
CORE_DIR="${PACKAGES_ROOT}/offgridos-core/rootfs"
API_DIR="${PACKAGES_ROOT}/offgridos-api/rootfs"
DASHBOARD_DIR="${PACKAGES_ROOT}/offgridos-dashboard/rootfs"
CONFIG_DIR="${PACKAGES_ROOT}/offgridos-settings/rootfs/etc/offgridos"
BRANDING_DIR="${PACKAGES_ROOT}/offgridos-branding/rootfs"
THEME_DIR="${PACKAGES_ROOT}/offgridos-theme/rootfs"
WELCOME_DIR="${PACKAGES_ROOT}/offgridos-welcome/rootfs"
INSTALLER_DIR="${PACKAGES_ROOT}/offgridos-installer/rootfs"
ICONS_DIR="${PACKAGES_ROOT}/offgridos-icons/rootfs"
WALLPAPERS_DIR="${PACKAGES_ROOT}/offgridos-wallpapers/rootfs"
UPDATE_DIR="${PACKAGES_ROOT}/offgridos-update/rootfs"
AI_DIR="${PACKAGES_ROOT}/offgridos-ai/rootfs"
NETWORK_DIR="${PACKAGES_ROOT}/offgridos-network/rootfs"
RECOVERY_DIR="${PACKAGES_ROOT}/offgridos-recovery/rootfs"

# Configuration
UBUNTU_CODENAME="noble"
UBUNTU_VERSION="24.04"
ARCH="amd64"
IMAGE_NAME="OffGridOS-1.0-Alpha"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[OffGridOS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        # Try with sudo if available
        if command -v sudo &> /dev/null; then
            exec sudo "$0" "$@"
        fi
        error "This script must be run as root"
    fi
}

check_dependencies() {
    local deps=("debootstrap" "mksquashfs" "xorriso" "grub-mkrescue" "curl" "jq")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error "Missing dependency: $dep"
        fi
    done
}

copy_package_rootfs() {
    local package_root="$1"
    local source_dir="${package_root}"

    if [ ! -d "${source_dir}" ]; then
        warn "Package rootfs not found: ${source_dir}"
        return 0
    fi

    cp -a "${source_dir}/." "${WORK_DIR}/chroot/"
}

setup_workdir() {
    log "Setting up working directory..."
    rm -rf "${WORK_DIR}"
    mkdir -p "${WORK_DIR}"/{chroot,image/{casper,boot/grub,EFI/boot},extracted}
}

bootstrap_ubuntu() {
    log "Bootstrapping Ubuntu ${UBUNTU_VERSION}..."
    debootstrap \
        --arch="${ARCH}" \
        --variant=minbase \
        --include=systemd-sysv \
        "${UBUNTU_CODENAME}" \
        "${WORK_DIR}/chroot" \
        http://archive.ubuntu.com/ubuntu
}

configure_system() {
    log "Configuring system..."
    
    # Copy OffGridOS configuration
    mkdir -p "${WORK_DIR}/chroot/etc/offgridos"
    cp -r "${CONFIG_DIR}/"* "${WORK_DIR}/chroot/etc/offgridos/" 2>/dev/null || true
    
    # Set hostname
    echo "offgridos" > "${WORK_DIR}/chroot/etc/hostname"
    
    # Configure hosts file
    cat > "${WORK_DIR}/chroot/etc/hosts" << 'EOF'
127.0.0.1       localhost
127.0.1.1       offgridos
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

    # Set timezone to UTC (adjustable later)
    chroot "${WORK_DIR}/chroot" ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    
    # Create OffGridOS user
    chroot "${WORK_DIR}/chroot" useradd -m -s /bin/bash -G sudo offgrid

    # Set default password (should be changed on first boot)
    chroot "${WORK_DIR}/chroot" bash -c "echo 'offgrid:offgrid' | chpasswd"
}

rebrand_system() {
    log "Rebranding system to OffGridOS..."
    copy_package_rootfs "${BRANDING_DIR}"
    copy_package_rootfs "${UPDATE_DIR}"
    chmod 755 "${WORK_DIR}/chroot/etc/update-motd.d/00-offgridos-header" 2>/dev/null || true
    
    chmod -x "${WORK_DIR}/chroot/etc/update-motd.d/10-help-text" 2>/dev/null || true
    chmod -x "${WORK_DIR}/chroot/etc/update-motd.d/50-motd-news" 2>/dev/null || true
    chmod -x "${WORK_DIR}/chroot/etc/update-motd.d/60-shutdown-time" 2>/dev/null || true
    
    # Update bash.bashrc to show OffGridOS
    echo '
if [ -x /usr/bin/neofetch ]; then
    neofetch
elif [ -f /etc/offgridos/banner.txt ]; then
    cat /etc/offgridos/banner.txt
fi' >> "${WORK_DIR}/chroot/etc/bash.bashrc"
    
    log "Rebrand complete"
}

install_offgridos_packages() {
    log "Installing OffGridOS packages..."
    
    # Enable universe repository
    echo "deb http://archive.ubuntu.com/ubuntu noble universe" >> "${WORK_DIR}/chroot/etc/apt/sources.list"
    echo "deb http://archive.ubuntu.com/ubuntu noble-updates universe" >> "${WORK_DIR}/chroot/etc/apt/sources.list"
    
    # Upgrade all packages first to fix version mismatches
    chroot "${WORK_DIR}/chroot" bash -c "apt-get update && apt-get upgrade -y"

    # Install the kernel explicitly so bootloader setup always has a vmlinuz to copy
    chroot "${WORK_DIR}/chroot" bash -c "apt-get install -y linux-image-generic"
    
    # Create package list
    cat > "${WORK_DIR}/chroot/tmp/packages.txt" << 'EOF'
sudo
curl
wget
git
vim
nano
htop
tmux
ubuntu-desktop
snapd
gnome-initial-setup
network-manager
openssh-server
avahi-daemon
python3
python3-dev
python3-pip
python3-yaml
python3-venv
build-essential
cmake
pkg-config
postgresql
postgresql-client
EOF

    # Install packages
    chroot "${WORK_DIR}/chroot" bash -c "apt-get update"
    grep -v '^$' "${WORK_DIR}/chroot/tmp/packages.txt" | chroot "${WORK_DIR}/chroot" xargs apt-get install -y || true
    
    # Install initramfs-tools and live-boot for ISO boot support
    chroot "${WORK_DIR}/chroot" bash -c "apt-get install -y initramfs-tools casper live-boot 2>/dev/null || apt-get install -y initramfs-tools casper 2>/dev/null || true"
    
    # Install optional packages (may not be available)
    log "Installing optional SDR/energy packages..."
    chroot "${WORK_DIR}/chroot" bash -c "apt-get install -y libmodbus-dev rtl-sdr hackrf soapysdr-tools python3-serial libusb-1.0-0-dev 2>/dev/null || echo 'Some optional packages not available'"
}

download_snap() {
    local snap_name="$1"
    local out_file="$2"
    local snap_info snap_url

    snap_info="$(curl -fsSL \
        -H 'Snap-Device-Series: 16' \
        -H 'User-Agent: snapcraft' \
        "https://api.snapcraft.io/v2/snaps/info/${snap_name}?fields=download,channel-map,name,snap-id,revision,version")"

    snap_url="$(printf '%s' "${snap_info}" | jq -r '."channel-map"[] | select(.channel.track=="latest" and .channel.risk=="stable" and .channel.architecture=="amd64") | .download.url' | head -1)"

    if [ -z "${snap_url}" ] || [ "${snap_url}" = "null" ]; then
        error "Could not resolve snap download URL for ${snap_name}"
    fi

    curl -fsSL "${snap_url}" -o "${out_file}"
}

seed_installer_snaps() {
    log "Downloading installer snaps..."

    mkdir -p "${WORK_DIR}/chroot/var/lib/offgridos/snaps"
    download_snap "ubuntu-desktop-installer" "${WORK_DIR}/chroot/var/lib/offgridos/snaps/ubuntu-desktop-installer.snap"
    download_snap "subiquity" "${WORK_DIR}/chroot/var/lib/offgridos/snaps/subiquity.snap"
}

apply_rootfs_overlay() {
    log "Applying rootfs overlay..."

    copy_package_rootfs "${THEME_DIR}"
    copy_package_rootfs "${WELCOME_DIR}"
    copy_package_rootfs "${INSTALLER_DIR}"
    copy_package_rootfs "${ICONS_DIR}"
    copy_package_rootfs "${WALLPAPERS_DIR}"
    copy_package_rootfs "${AI_DIR}"
    copy_package_rootfs "${NETWORK_DIR}"
    copy_package_rootfs "${RECOVERY_DIR}"

    chmod 755 "${WORK_DIR}/chroot/usr/local/bin/offgridos-desktop-installer" 2>/dev/null || true
    chmod 755 "${WORK_DIR}/chroot/usr/local/bin/offgridos-console-installer" 2>/dev/null || true
    chmod 755 "${WORK_DIR}/chroot/usr/local/bin/offgridos-seed-installer-snaps" 2>/dev/null || true
    chmod 755 "${WORK_DIR}/chroot/etc/update-motd.d/00-offgridos-header" 2>/dev/null || true

    mkdir -p "${WORK_DIR}/chroot/etc/gdm3"
    cat > "${WORK_DIR}/chroot/etc/gdm3/custom.conf" << 'EOF'
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=offgrid
WaylandEnable=true

[security]

[greeter]

[chooser]

[debug]
EOF

    mkdir -p "${WORK_DIR}/chroot/etc/sudoers.d"
    cat > "${WORK_DIR}/chroot/etc/sudoers.d/offgrid" << 'EOF'
offgrid ALL=(ALL) NOPASSWD:ALL
EOF
    chmod 440 "${WORK_DIR}/chroot/etc/sudoers.d/offgrid"

    mkdir -p "${WORK_DIR}/chroot/home/offgrid/Desktop"
    cp "${WORK_DIR}/chroot/usr/share/applications/offgridos-installer.desktop" "${WORK_DIR}/chroot/home/offgrid/Desktop/Install OffGridOS.desktop" 2>/dev/null || true
    cp "${WORK_DIR}/chroot/usr/share/applications/offgridos-console-installer.desktop" "${WORK_DIR}/chroot/home/offgrid/Desktop/Install OffGridOS (Text).desktop" 2>/dev/null || true
    chmod 755 "${WORK_DIR}/chroot/home/offgrid/Desktop/Install OffGridOS.desktop" 2>/dev/null || true
    chmod 755 "${WORK_DIR}/chroot/home/offgrid/Desktop/Install OffGridOS (Text).desktop" 2>/dev/null || true
    chown -R offgrid:offgrid "${WORK_DIR}/chroot/home/offgrid/Desktop" 2>/dev/null || true

    mkdir -p "${WORK_DIR}/chroot/etc/dconf/profile"
    cat > "${WORK_DIR}/chroot/etc/dconf/profile/user" << 'EOF'
user-db:user
system-db:local
EOF

    mkdir -p "${WORK_DIR}/chroot/etc/dconf/db/local.d"
    cat > "${WORK_DIR}/chroot/etc/dconf/db/local.d/00-offgridos" << 'EOF'
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/offgridos-wallpaper.svg'
picture-uri-dark='file:///usr/share/backgrounds/offgridos-wallpaper.svg'

[org/gnome/desktop/screensaver]
picture-uri='file:///usr/share/backgrounds/offgridos-wallpaper.svg'

[org/gnome/desktop/interface]
color-scheme='prefer-dark'

[org/gnome/shell]
favorite-apps=['offgridos-installer.desktop','org.gnome.Nautilus.desktop','org.gnome.Terminal.desktop','firefox.desktop']
EOF

    chroot "${WORK_DIR}/chroot" dconf update 2>/dev/null || true

    ln -sf /lib/systemd/system/graphical.target "${WORK_DIR}/chroot/etc/systemd/system/default.target"
    chroot "${WORK_DIR}/chroot" systemctl enable gdm 2>/dev/null || chroot "${WORK_DIR}/chroot" systemctl enable gdm3 2>/dev/null || true
}

install_offgridd() {
    log "Installing OffGridOS Core Daemon..."
    copy_package_rootfs "${CORE_DIR}"
    chroot "${WORK_DIR}/chroot" systemctl enable offgridd
}

install_api() {
    log "Installing OffGridOS API..."
    copy_package_rootfs "${API_DIR}"
    chroot "${WORK_DIR}/chroot" systemctl enable offgridos-api
}

setup_dashboard() {
    log "Setting up dashboard..."
    copy_package_rootfs "${DASHBOARD_DIR}"
    chroot "${WORK_DIR}/chroot" systemctl enable offgridos-dashboard
}

cleanup_chroot() {
    log "Cleaning up chroot..."
    
    # Clean package cache
    chroot "${WORK_DIR}/chroot" bash -c "apt-get clean && rm -rf /var/lib/apt/lists/*"
    
    # Remove temporary files
    chroot "${WORK_DIR}/chroot" bash -c "rm -rf /tmp/* /var/tmp/*"
    
    # Clear machine ID
    chroot "${WORK_DIR}/chroot" bash -c "truncate -s 0 /etc/machine-id"
}

create_squashfs() {
    log "Creating squashfs filesystem..."
    
    # Unmount any existing filesystems
    umount -lf "${WORK_DIR}/chroot"/dev/pts 2>/dev/null || true
    umount -lf "${WORK_DIR}/chroot"/dev 2>/dev/null || true
    umount -lf "${WORK_DIR}/chroot"/proc 2>/dev/null || true
    umount -lf "${WORK_DIR}/chroot"/sys 2>/dev/null || true
    
    # Create squashfs
    mksquashfs "${WORK_DIR}/chroot" "${WORK_DIR}/image/casper/filesystem.squashfs" \
        -comp xz \
        -b 1M \
        -Xbcj x86
    
    # Get filesystem size
    du -sx --block-size=1 "${WORK_DIR}/chroot" | cut -f1 > "${WORK_DIR}/image/casper/filesystem.size"
}

setup_bootloader() {
    log "Setting up bootloader..."
    
    # Find the kernel version
    KERNEL_VERSION=$(ls "${WORK_DIR}/chroot/boot/vmlinuz-"* 2>/dev/null | head -1 | sed 's|.*vmlinuz-||')
    
    if [ -z "$KERNEL_VERSION" ]; then
        error "No kernel found in chroot"
    fi
    
    log "Found kernel: ${KERNEL_VERSION}"
    
    # Regenerate initrd AFTER casper is installed to include live-boot scripts
    log "Regenerating initrd with casper support..."
    chroot "${WORK_DIR}/chroot" bash -c "mount -t proc proc /proc 2>/dev/null; mount -t sysfs sysfs /sys 2>/dev/null; mount -t devtmpfs devtmpfs /dev 2>/dev/null; mkinitramfs -o /boot/initrd.img-${KERNEL_VERSION} ${KERNEL_VERSION}; umount /dev 2>/dev/null; umount /sys 2>/dev/null; umount /proc 2>/dev/null" || \
    chroot "${WORK_DIR}/chroot" bash -c "mkinitramfs -o /boot/initrd.img-${KERNEL_VERSION} ${KERNEL_VERSION}" || \
    warn "Could not regenerate initrd"
    
    # Copy kernel and fix permissions
    cp "${WORK_DIR}/chroot/boot/vmlinuz-${KERNEL_VERSION}" "${WORK_DIR}/image/casper/vmlinuz"
    chmod 644 "${WORK_DIR}/image/casper/vmlinuz"
    
    # Copy initrd
    if [ -f "${WORK_DIR}/chroot/boot/initrd.img-${KERNEL_VERSION}" ]; then
        cp "${WORK_DIR}/chroot/boot/initrd.img-${KERNEL_VERSION}" "${WORK_DIR}/image/casper/initrd"
        chmod 644 "${WORK_DIR}/image/casper/initrd"
    else
        error "initrd not found after regeneration"
    fi
    
    # Create GRUB config for BIOS
    mkdir -p "${WORK_DIR}/image/boot/grub"
    if [ -f "${RECOVERY_DIR}/boot/grub/grub.cfg" ]; then
        cp "${RECOVERY_DIR}/boot/grub/grub.cfg" "${WORK_DIR}/image/boot/grub/grub.cfg"
    else
        cat > "${WORK_DIR}/image/boot/grub/grub.cfg" << 'EOF'
set default=0
set timeout=10

menuentry "OffGridOS 1.0 (Frontier)" {
    linux /casper/vmlinuz boot=casper console=tty0 console=ttyS0,115200n8 ---
    initrd /casper/initrd
}

menuentry "OffGridOS (Safe Mode)" {
    linux /casper/vmlinuz boot=casper quiet splash nomodeset ---
    initrd /casper/initrd
}

menuentry "OffGridOS (RAM Disk)" {
    linux /casper/vmlinuz boot=casper toram quiet splash ---
    initrd /casper/initrd
}
EOF
    fi

    # Create GRUB config for UEFI
    mkdir -p "${WORK_DIR}/image/EFI/boot"
    if [ -f "${RECOVERY_DIR}/EFI/boot/grub.cfg" ]; then
        cp "${RECOVERY_DIR}/EFI/boot/grub.cfg" "${WORK_DIR}/image/EFI/boot/grub.cfg"
    else
        cat > "${WORK_DIR}/image/EFI/boot/grub.cfg" << 'EOF'
set default=0
set timeout=10

menuentry "OffGridOS 1.0 (Frontier)" {
    linux /casper/vmlinuz boot=casper console=tty0 console=ttyS0,115200n8 ---
    initrd /casper/initrd
}
EOF
    fi
}

create_iso() {
    log "Creating ISO image..."
    
    mkdir -p "${OUTPUT_DIR}"

    # Let GRUB and xorriso create the complete BIOS/UEFI El Torito layout.
    # Hand-building cdboot.img and an EFI image produces an ISO that can be
    # detected by firmware but hangs at "Booting from CD/DVD..." in BIOS VMs.
    log "Generating BIOS and UEFI boot images with grub-mkrescue..."
    grub-mkrescue \
        -o "${OUTPUT_DIR}/${IMAGE_NAME}.iso" \
        "${WORK_DIR}/image" 2>&1
    
    if [ -f "${OUTPUT_DIR}/${IMAGE_NAME}.iso" ]; then
        log "ISO created: ${OUTPUT_DIR}/${IMAGE_NAME}.iso"
        ls -lh "${OUTPUT_DIR}/${IMAGE_NAME}.iso"
    else
        error "ISO creation failed"
    fi
}

cleanup() {
    log "Cleaning up..."
    rm -rf "${WORK_DIR}"
}

main() {
    log "OffGridOS Build Script"
    log "======================"
    
    check_root
    check_dependencies
    
    setup_workdir
    bootstrap_ubuntu
    configure_system
    install_offgridos_packages
    rebrand_system
    seed_installer_snaps
    apply_rootfs_overlay
    install_offgridd
    install_api
    setup_dashboard
    chroot "${WORK_DIR}/chroot" systemctl enable offgridos-seed-installer-snaps 2>/dev/null || true
    cleanup_chroot
    create_squashfs
    setup_bootloader
    create_iso
    cleanup
    
    log "Build complete!"
    log "ISO location: ${OUTPUT_DIR}/${IMAGE_NAME}.iso"
}

main "$@"
