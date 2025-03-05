#!/bin/bash

# This script backs up all the configuration files to a git repository
#
# Author: Sourav Sharan

# Define machine-specific directory name
MACHINE_NAME=$(hostname)  # Change this if you want a custom name
MACHINE_DIR="$CONFIG_BACKUP_REPO/$MACHINE_NAME"

# Git repository URL (Update this with your actual repo URL)
GIT_REPO_URL="git@github.com:SouravSharan/linux_configs.git"

# Clone the repo if it doesn't exist
if [[ ! -d "$CONFIG_BACKUP_REPO/.git" ]]; then
    echo "Cloning backup repository..."
    git clone "$GIT_REPO_URL" "$CONFIG_BACKUP_REPO"
else
    # Pull latest changes to keep the repo updated
    echo "Updating repository..."
    cd "$CONFIG_BACKUP_REPO" || { echo "Failed to enter $CONFIG_BACKUP_REPO"; exit 1; }
    git pull origin main
fi

# Ensure the machine-specific directory exists
mkdir -p "$MACHINE_DIR"

# Check if config file exists
if [[ ! -f "$CONFIG_PATHS_FILE" ]]; then
    echo "Error: $CONFIG_PATHS_FILE not found!"
    exit 1
fi

# Read each line from config_paths_map.txt
while IFS= read -r line || [[ -n "$line" ]]; do
    # Replace $USER with actual username in the source path
    expanded_line=$(echo "$line" | sed "s|\$USER|$USER|g")

    # Extract source and destination
    source=$(echo "$expanded_line" | cut -d " " -f 1)
    destination="$MACHINE_DIR$(echo "$expanded_line" | cut -d " " -f 2)"

    # Check if source file exists
    if [[ -f "$source" || -d "$source" ]]; then
        # Ensure destination directory exists
        mkdir -p "$(dirname "$destination")"

        # Use rsync to exclude .git directories
        rsync -a --exclude='.git' "$source" "$destination"
        echo "Copied $source → $destination (excluding .git)"
    else
        echo "Warning: Source file $source not found!"
    fi
done < "$CONFIG_PATHS_FILE"

# Change directory to the backup repo
cd "$CONFIG_BACKUP_REPO" || { echo "Failed to enter $CONFIG_BACKUP_REPO"; exit 1; }

# Check for changes
if [[ -n $(git status --porcelain) ]]; then
    git add .
    git commit -m "Backup for $MACHINE_NAME: $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main  # Ensure your branch is 'main' or update this line accordingly
    echo "Backup successfully committed and pushed to GitHub!"
else
    echo "No changes to commit. Backup is up to date."
fi

