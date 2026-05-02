#!/bin/bash

read -p "Enter disk (e.g. /dev/sda or /dev/nvme0n1): " DISK

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

# Create GPT partition table
parted -s $DISK mklabel gpt

# Partition 1: 512M EFI System
parted -s $DISK mkpart EFI fat32 1MiB 513MiB
parted -s $DISK set 1 esp on

# Partition 2: remaining space Linux filesystem
parted -s $DISK mkpart ROOT ext4 513MiB 100%

# Verify
echo ""
echo "Partition table created:"
parted -s $DISK print
