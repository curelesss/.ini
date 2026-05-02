#!/bin/bash

# Step 12 — Disable package signing
echo "Disabling package signing..."
sed -i 's/^SigLevel.*/SigLevel = Never/' /etc/pacman.conf

# Step 13 — Set timezone
echo ""
echo "Setting timezone..."
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

# Step 14 — Set locale
echo ""
echo "Setting locale..."
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# Step 15 — Set hostname
echo ""
echo "Setting hostname..."
echo 'archlinux' > /etc/hostname

cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
EOF

# Step 16 — Set root password
echo ""
echo "Setting root password..."
passwd

# Step 17 — Create user with sudo access
echo ""
read -p "Enter username to create: " USERNAME

# Create user if not exists, or modify if exists
if id "$USERNAME" &> /dev/null; then
  echo "User $USERNAME already exists, updating groups and shell..."
  usermod -aG wheel -s /bin/bash $USERNAME
else
  echo "Creating user $USERNAME..."
  useradd -m -G wheel -s /bin/bash $USERNAME
fi

echo "Setting password for $USERNAME..."
passwd $USERNAME

# Enable wheel group in sudoers (idempotent)
echo ""
echo "Configuring sudo..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Verify
echo ""
echo "Verifying..."
echo "User groups:"
groups $USERNAME
echo ""
echo "Sudoers wheel entry:"
grep wheel /etc/sudoers
