#!/usr/bin/env bash
# =====================================================================
# Script: clone-if-missing.sh
# Purpose: Clone repos with forced progress bars and improved error handling.
# =====================================================================
set -euo pipefail

# List of "repo_url destination_path" pairs
REPOS=(
    "git@github.com:curelesss/.password-store.git    $HOME/.password-store"
    "git@github.com:curelesss/.dotfiles.git         $HOME/.dotfiles"
    "git@github.com:curelesss/dotfiles.git           $HOME/dotfiles"
)

echo "🚀 Starting clone-if-missing operation..."
echo

for entry in "${REPOS[@]}"; do
    # Use read to split the string correctly
    read -r repo_url dest <<< "$entry"

    # Clean up the name for the UI
    repo_name=$(basename "$repo_url" .git)

    echo "📦 Checking: $repo_name"
    
    if [ -d "$dest" ]; then
        echo "   ✅ Already exists at $dest. Skipping."
    else
        echo "   📥 Cloning to $dest..."
        
        # --progress: Forces progress status even if the standard error stream 
        #             is not directed to a terminal.
        # --verbose:  Provides extra details about the connection.
        if git clone --progress --verbose "$repo_url" "$dest"; then
            echo "   ✨ Successfully cloned $repo_name"
        else
            # Note: set -e is active, but the 'if' condition prevents immediate exit
            echo "   ❌ Error: Failed to clone $repo_name" >&2
            echo "      Check your SSH keys or network connection."
        fi
    fi
    echo "----------------------------------------------------"
done

echo "All operations completed."
