#!/usr/bin/env bash
# Replace /etc/pacman.d/mirrorlist with our custom Weimar mirrorlist
# Idempotent version — only changes file when actually different

set -euo pipefail

# ────────────────────────────────────────────────
#  Configuration
# ────────────────────────────────────────────────

TARGET="/etc/pacman.d/mirrorlist"
SOURCE="./mirrorlist/arch/weimar/mirrorlist"           # adjust if filename is different
BACKUP_SUFFIX=".bak-$(date +%Y%m%d-%H%M%S)"

# ────────────────────────────────────────────────
#  Checks
# ────────────────────────────────────────────────

if [[ ! -f "$SOURCE" ]]; then
    echo "Error: Source file not found: $SOURCE" >&2
    exit 1
fi

# Try to get effective write access (works even when already root)
if [[ ! -w "$TARGET" && ! -w "$(dirname "$TARGET")" ]]; then
    echo "No write permission to $(dirname "$TARGET")"
    echo "Re-running script with sudo ..."
    exec sudo "$0" "$@"
fi

# ────────────────────────────────────────────────
#  Compare (fast path — content same → do nothing)
# ────────────────────────────────────────────────

if [[ -f "$TARGET" ]] && cmp --silent "$TARGET" "$SOURCE"; then
    echo "mirrorlist is already up-to-date → no change needed"
    exit 0
fi

# ────────────────────────────────────────────────
#  Actually replace + backup
# ────────────────────────────────────────────────

echo "Updating mirrorlist ..."

if [[ -f "$TARGET" ]]; then
    backup="${TARGET}${BACKUP_SUFFIX}"
    echo "  → creating backup: ${backup##*/}"
    cp -a -- "$TARGET" "$backup"
fi

echo "  → installing new mirrorlist"
install -m 0644 -- "$SOURCE" "$TARGET"

echo "Done."
echo "New mirrorlist active (source: $SOURCE)"
