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

echo ""
echo "Done. Verify:"
echo "  cat /etc/pacman.conf | grep SigLevel"
echo "  cat /etc/localtime"
echo "  cat /etc/locale.conf"
echo "  cat /etc/hostname"
echo "  cat /etc/hosts"
