#!/bin/bash

# Show available disks
echo "Available disks:"
lsblk
echo ""

# Step 18 — Install and configure systemd-boot

# Detect partition naming (sda1 vs nvme0n1p1)
read -p "Enter disk (e.g. /dev/sda or /dev/nvme0n1): " DISK

if [[ $DISK == *"nvme"* ]]; then
  PART1="${DISK}p1"
  PART2="${DISK}p2"
else
  PART1="${DISK}1"
  PART2="${DISK}2"
fi

# Install systemd-boot (idempotent — bootctl handles reinstall safely)
echo "Installing systemd-boot..."
bootctl install

# Get UUID of root partition
UUID=$(blkid -s UUID -o value $PART2)
echo ""
echo "Root partition UUID: $UUID"

# Auto-detect kernel and initramfs filenames from /boot
echo ""
echo "Detecting kernel and initramfs from /boot..."
ls /boot

KERNEL=$(ls /boot | grep -E '^Image$|^vmlinuz' | head -1)
INITRD=$(ls /boot | grep -E '^initramfs-linux\.img$' | head -1)

echo "Kernel  : $KERNEL"
echo "Initrd  : $INITRD"

if [ -z "$KERNEL" ] || [ -z "$INITRD" ]; then
  echo "ERROR: Could not detect kernel or initramfs in /boot"
  exit 1
fi

# Create loader directory
mkdir -p /boot/loader/entries

# Create boot entry (overwrite for idempotency)
echo ""
echo "Creating boot entry..."
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux   /$KERNEL
initrd  /$INITRD
options root=UUID=$UUID rw
EOF

echo "Boot entry:"
cat /boot/loader/entries/arch.conf

# Configure loader (overwrite for idempotency)
echo ""
echo "Configuring loader..."
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor  no
EOF

echo "Loader config:"
cat /boot/loader/loader.conf

# Verify
echo ""
echo "Verifying bootctl status..."
bootctl status
