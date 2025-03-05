#!/bin/bash

# This script backs up all the configuration files to a git repository
#
# Author: Sourav Sharan

# Define machine-specific directory name
MACHINE_NAME=$(hostname)
MACHINE_DIR="$CONFIG_BACKUP_REPO/$MACHINE_NAME"

# Git repository URL
GIT_REPO_URL="git@github.com:SouravSharan/linux_configs.git"

# Clone the repo if it doesn't exist
if [[ ! -d "$CONFIG_BACKUP_REPO/.git" ]]; then
    echo "Cloning backup repository..."
    git clone "$GIT_REPO_URL" "$CONFIG_BACKUP_REPO"
else
    echo "Updating repository..."
    cd "$CONFIG_BACKUP_REPO" || { echo "Failed to enter $CONFIG_BACKUP_REPO"; exit 1; }
    git pull origin main
fi

# Ensure machine-specific directory exists
mkdir -p "$MACHINE_DIR"

# Use the config file from the environment variable or default to $MACHINE_DIR/.config/scripts/backup_config_paths
BACKUP_CONFIG_PATHS="${BACKUP_CONFIG_PATHS:-$MACHINE_DIR/.config/scripts/backup_config_paths.txt}"

# Check if config file exists
if [[ ! -f "$BACKUP_CONFIG_PATHS" ]]; then
    echo "Error: $BACKUP_CONFIG_PATHS not found!"
    exit 1
fi

# Read each line from the config file
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Expand $USER in paths
    expanded_line=$(echo "$line" | sed "s|\$USER|$USER|g")

    # Extract source and optional destination
    source=$(echo "$expanded_line" | awk '{print $1}')
    custom_dest=$(echo "$expanded_line" | awk '{print $2}')

    # Determine destination
    if [[ -n "$custom_dest" ]]; then
        # Use the custom destination path (Option 2)
        destination="$MACHINE_DIR/$custom_dest"
    else
        # Preserve full absolute path (Option 1)
        rel_path="${source#/}"  # Remove leading '/'
        destination="$MACHINE_DIR/$rel_path"
    fi

    # Check if source exists
    if [[ -f "$source" || -d "$source" ]]; then
        mkdir -p "$(dirname "$destination")"
        rsync -a --exclude='.git' "$source" "$destination"
        echo "Copied $source → $destination (excluding .git)"
    else
        echo "Warning: Source file $source not found!"
    fi
done < "$BACKUP_CONFIG_PATHS"

# Commit and push changes if any
cd "$CONFIG_BACKUP_REPO" || { echo "Failed to enter $CONFIG_BACKUP_REPO"; exit 1; }

if [[ -n $(git status --porcelain) ]]; then
    git add .
    git commit -m "Backup for $MACHINE_NAME: $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
    echo "Backup successfully committed and pushed to GitHub!"
else
    echo "No changes to commit. Backup is up to date."
fi

