#!/usr/bin/env bash
# =====================================================================
# Script: setup-github-ssh-and-repo.sh
# Purpose: Run Ansible playbook (github-tagged tasks), ensure GitHub
#          SSH host key is known (idempotent, no prompt), update git
#          remote URL, and test SSH authentication to GitHub.
# Date: February 2026
# =====================================================================

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

echo "Starting GitHub setup sequence..."

# 1. Run the Ansible playbook with only github-tagged tasks
#    (will prompt for vault password and become/sudo password)
ansible-playbook book.yml --ask-become-pass --ask-vault-pass --tags=github

# 2. Ensure GitHub host key is in ~/.ssh/known_hosts (idempotent)
echo -n "Checking GitHub known_hosts entry... "
if grep -q "^github.com" ~/.ssh/known_hosts 2>/dev/null; then
    echo "already present → skipping"
else
    echo "adding now..."
    ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null || true
    echo "GitHub host key added."
fi

# 3. Update the git remote URL to SSH (github.com)
echo "Setting git remote URL to SSH..."
git remote set-url origin git@github.com:curelesss/.ini.git || {
    echo "Warning: 'git remote set-url' failed (maybe already set or no repo?)"
}

# 4. Test SSH connection to GitHub (should now be silent/no prompt)
echo "Testing SSH authentication to GitHub..."
ssh -T git@github.com

echo
echo "Done!"
echo "If you see 'Hi curelesss! ...' → everything is working."
echo "If you see permission denied (publickey) → check your SSH key is added to GitHub."
