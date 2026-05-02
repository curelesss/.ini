#!/bin/bash

# Step 19 — Enable essential services
echo "Enabling NetworkManager..."
systemctl enable NetworkManager

# Step 20 — Install GNOME desktop
echo ""
echo "Installing GNOME desktop..."
pacman -Syy
pacman -S --noconfirm \
  gdm \
  gnome \
  gnome-keyring \
  nautilus \
  xdg-user-dirs

# Enable GDM
echo ""
echo "Enabling GDM..."
systemctl enable gdm

# Verify enabled services
echo ""
echo "Enabled services:"
systemctl is-enabled NetworkManager
systemctl is-enabled gdm

# Step 21 — Exit chroot and shutdown
echo ""
echo "Exiting chroot and shutting down..."
exit

umount -R /mnt
