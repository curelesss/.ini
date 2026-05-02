#!/bin/bash

# Step 9 — Install base system
echo "Installing base system..."

pacstrap /mnt \
  base \
  base-devel \
  linux-aarch64 \
  linux-firmware \
  mkinitcpio \
  efibootmgr \
  sudo \
  vim \
  git \
  networkmanager \
  terminus-font

# Step 10 — Generate fstab (idempotent: overwrite instead of append)
echo ""
echo "Generating fstab..."

genfstab -U /mnt > /mnt/etc/fstab

echo ""
echo "fstab contents:"
cat /mnt/etc/fstab
