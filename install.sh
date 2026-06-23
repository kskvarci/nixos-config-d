#!/usr/bin/env bash
# =============================================================================
# NixOS install script for "onix" (AMD Ryzen 3800X + RTX 2070 Super)
#
# Run as root from the NixOS 25.05 minimal live ISO.
# Expects: /root/nixos-config.tar.gz (embedded config tarball)
#
# Partition scheme: GPT — 512M EFI (FAT32) + rest ext4 — no encryption.
# =============================================================================
set -euo pipefail

DISK="/dev/nvme0n1"
HOSTNAME="onix"
TARBALL="/root/nixos-config.tar.gz"

# --- Preflight checks --------------------------------------------------------

echo "=== NixOS Install: $HOSTNAME ==="
echo "Target disk: $DISK"
echo ""

# Check we're running as root
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Must run as root (sudo -i first)." >&2
  exit 1
fi

# Check the tarball exists
if [[ ! -f "$TARBALL" ]]; then
  echo "ERROR: Config tarball not found at $TARBALL" >&2
  echo "Copy it from the USB: cp /mnt/usb/nixos-config.tar.gz /root/" >&2
  exit 1
fi

# Check network (needed for downloading packages)
echo ">>> Checking network..."
if ! ping -c1 -W3 cache.nixos.org &>/dev/null; then
  echo "WARNING: No network. Package downloads will fail."
  echo "Connect via: nmtui  OR  systemctl start wpa_supplicant && wpa_cli"
  read -p "Press Enter once connected (or Ctrl+C to abort)..."
  if ! ping -c1 -W3 cache.nixos.org &>/dev/null; then
    echo "ERROR: Still no network." >&2
    exit 1
  fi
fi
echo "    Network OK."

# Confirm before wiping
echo ""
echo "WARNING: This will WIPE ${DISK} entirely."
lsblk "$DISK"
echo ""
read -p "Type 'yes' to continue: " confirm
[[ "$confirm" == "yes" ]] || exit 1

# --- Enable flakes for this session ------------------------------------------

export NIX_CONFIG="experimental-features = nix-command flakes"

# --- Partitioning -------------------------------------------------------------

echo ""
echo ">>> Partitioning $DISK (GPT: 512M EFI + ext4 root)..."
wipefs -af "$DISK"
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary ext4 512MiB 100%

# Wait for kernel to pick up new partition table
sleep 2
partprobe "$DISK" 2>/dev/null || true

# --- Formatting ---------------------------------------------------------------

echo ">>> Formatting..."
mkfs.fat -F 32 -n BOOT "${DISK}p1"
mkfs.ext4 -L nixos "${DISK}p2"

# --- Mounting -----------------------------------------------------------------

echo ">>> Mounting..."
mount "${DISK}p2" /mnt
mkdir -p /mnt/boot
mount "${DISK}p1" /mnt/boot

# --- Generate hardware-configuration.nix --------------------------------------

echo ">>> Generating hardware-configuration.nix..."
nixos-generate-config --root /mnt
# This creates /mnt/etc/nixos/{configuration.nix,hardware-configuration.nix}
# We only need hardware-configuration.nix; save it aside.
cp /mnt/etc/nixos/hardware-configuration.nix /tmp/hardware-configuration.nix

# --- Unpack flake config ------------------------------------------------------

echo ">>> Unpacking nixos-config..."
rm -rf /mnt/etc/nixos
mkdir -p /mnt/etc/nixos
tar xzf "$TARBALL" -C /mnt/etc/nixos

# --- Place hardware-configuration.nix ----------------------------------------

echo ">>> Installing hardware-configuration.nix into hosts/onix/..."
cp /tmp/hardware-configuration.nix /mnt/etc/nixos/hosts/onix/hardware-configuration.nix

echo ""
echo "--- Generated hardware-configuration.nix ---"
cat /mnt/etc/nixos/hosts/onix/hardware-configuration.nix
echo "--- End ---"
echo ""
read -p "Review above. Press Enter to proceed with install (Ctrl+C to abort)..."

# --- Install NixOS ------------------------------------------------------------

echo ">>> Running nixos-install..."
nixos-install --flake /mnt/etc/nixos#onix

# nixos-install prompts for root password interactively ^

echo ""
echo "=== Installation complete! ==="
echo ""
echo "After reboot:"
echo "  - Log in as kskvarci (password: changeme)"
echo "  - Change passwords: passwd && sudo passwd root"
echo "  - Config lives at /etc/nixos"
echo "  - Rebuild: sudo nixos-rebuild switch --flake /etc/nixos#onix"
echo ""
read -p "Press Enter to reboot (or Ctrl+C to stay in live env)..."
umount -R /mnt
reboot
