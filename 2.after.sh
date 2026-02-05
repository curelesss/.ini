#!/usr/bin/env bash
# =====================================================================
# Script: clone-if-missing.sh
# Purpose: Clone repos ONLY if the target directory does NOT exist yet.
#          Shows full verbose output from git clone when cloning.
# =====================================================================
set -euo pipefail

# List of "repo_url destination_path" pairs
REPOS=(
    "git@github.com:curelesss/.init.git    $HOME/.init"
    "git@github.com:curelesss/.dotfiles.git $HOME/.dotfiles"
    "git@github.com:curelesss/dotfiles.git  $HOME/dotfiles"
)

echo "Starting clone-if-missing operation..."
echo

for entry in "${REPOS[@]}"; do
    # Split into url and path (handles multiple spaces/tabs)
    read -r repo_url dest _ <<< "$entry"   # the _ eats any trailing junk

    # Extract short name for nicer printing
    repo_name="${repo_url##*/}"           # .init.git
    repo_name="${repo_name%.git}"         # .init (cleaner look)

    echo "Checking → $repo_name"
    echo "       to → $dest"

    if [ -d "$dest" ]; then
        echo "  → directory already exists → skipping clone"
    else
        echo "  → cloning..."

        # ── No --quiet → full verbose output appears in terminal ──
        if git clone "$repo_url" "$dest"; then
            echo "  → cloned successfully"
        else
            echo "  → clone failed"
            echo "     (possible reasons: SSH key missing, repo doesn't exist, network issue, permission denied, ...)"
            # We continue with next repos even if one fails (remove '|| exit 1' if you want to stop on error)
        fi
    fi
    echo
done

echo "All operations completed."
echo
