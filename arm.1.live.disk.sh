#!/bin/bash

sed -i 's/^SigLevel.*/SigLevel = Never/' /etc/pacman.conf

# Show available disks
echo "Available disks:"
lsblk
echo ""

read -p "Enter disk (e.g. /dev/sda or /dev/nvme0n1): " DISK

echo ""
echo "WARNING: This will erase all data on $DISK"
read -p "Are you sure? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborted."
  exit 1
fi

# Install parted if not available
if ! command -v parted &> /dev/null; then
  echo "Installing parted..."
  pacman -Sy --noconfirm parted
fi

# Detect partition naming (sda1 vs nvme0n1p1)
if [[ $DISK == *"nvme"* ]]; then
  PART1="${DISK}p1"
  PART2="${DISK}p2"
else
  PART1="${DISK}1"
  PART2="${DISK}2"
fi

# Reset — unmount and wipe disk to clean state
echo ""
echo "Resetting $DISK to clean state..."

umount $PART1 2>/dev/null || true
umount $PART2 2>/dev/null || true
umount -R /mnt 2>/dev/null || true

wipefs -a $DISK

# Step 6 — Partition the disk
echo ""
echo "Partitioning $DISK..."

parted -s $DISK mklabel gpt
parted -s $DISK mkpart EFI fat32 1MiB 513MiB
parted -s $DISK set 1 esp on
parted -s $DISK mkpart ROOT ext4 513MiB 100%

echo "Partition table created:"
parted -s $DISK print

# Step 7 — Format the partitions
echo ""
echo "Formatting partitions..."

mkfs.fat -F32 $PART1
mkfs.ext4 -F $PART2

# Step 8 — Mount the partitions
echo ""
echo "Mounting partitions..."

mount $PART2 /mnt
mkdir -p /mnt/boot
mount $PART1 /mnt/boot

# Verify
echo ""
echo "Mounted partitions:"
df -h | grep /mnt
