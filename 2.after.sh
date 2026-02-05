#!/usr/bin/env bash
# =====================================================================
# Script: clone-if-missing.sh
# Purpose: Clone repos ONLY if the target directory does NOT exist yet.
#          Completely skips if the folder is already there (any content).
# =====================================================================

set -euo pipefail

# List of "repo_url  destination_path" pairs
REPOS=(
    "git@github.com:curelesss/.init.git     $HOME/.init"
    "git@github.com:curelesss/.dotfiles.git  $HOME/.dotfiles"
    "git@github.com:curelesss/dotfiles.git   $HOME/dotfiles"
)

echo "Starting clone-if-missing operation..."
echo

for entry in "${REPOS[@]}"; do
    # Split the line into url and path
    read -r repo_url dest <<< "$entry"
    repo_name="${repo_url##*/}"           # e.g. .init.git

    echo "Checking $repo_name → $dest"

    if [ -d "$dest" ]; then
        echo "  → directory already exists → skipping"
    else
        echo "  → cloning..."
        if git clone --quiet "$repo_url" "$dest"; then
            echo "  → cloned successfully"
        else
            echo "  → clone failed (check SSH key, network, repo existence)"
        fi
    fi
    echo
done

echo "Done."
