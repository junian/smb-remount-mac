#!/bin/bash

CURRENT_DIR="$(pwd)"

# Define the SMB server details, credentials, and mount options
CONFIG_FILE="$CURRENT_DIR/.smb-remount"

function currentTime() {
    date +'%H:%M:%S'
}

function loadConfig() {
    if [ -f "$CONFIG_FILE" ]; then
        set -a
        source "$CONFIG_FILE"
        set +a
    else
        echo "[$(currentTime) WRN] Configuration file not found: $CONFIG_FILE"
    fi
}

loadConfig

# Create the mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

# Unmount if already mounted (to remount with options)
if mount | grep -q "$SMB_SERVER_MOUNT"; then
    echo "[$(currentTime) INF] Unmounting $SMB_SERVER_MOUNT"
    UNMOUNT_PATH=$(df | grep "$SMB_SERVER_MOUNT" | awk '{print $9}')
    # umount -v "$SMB_SERVER_MOUNT"
    diskutil unmount "$UNMOUNT_PATH"
fi

# Mount the SMB share with the specified options
mount -t smbfs -o "$MOUNT_OPTIONS" "$SMB_SERVER" "$MOUNT_POINT"

# Check if the mount was successful
if mount | grep -q "$MOUNT_POINT"; then
    echo "[$(currentTime) INF] SMB share mounted successfully at $MOUNT_POINT with options: $MOUNT_OPTIONS"
else
    echo "[$(currentTime) ERR] Failed to mount SMB share"
    exit 1
fi

SMB_LAUNCH_AGENT_PATH="$HOME/Library/LaunchAgents/monitor-smb.plist"

if [ -f "$SMB_LAUNCH_AGENT_PATH" ]
then
    launchctl unload "$SMB_LAUNCH_AGENT_PATH"
fi

export MONITOR_SMB_PATH="$CURRENT_DIR"
eval "echo \"$(cat monitor-smb.plist)\"" > "$SMB_LAUNCH_AGENT_PATH"

launchctl load "$SMB_LAUNCH_AGENT_PATH"

# Ensure the mount point is visible in Finder Locations
# This step uses the `open` command to open the mounted directory in Finder,
# which should trigger Finder to add it to the Locations toolbar.
open "$MOUNT_POINT"

# AppleScript to add the SMB share to the Finder sidebar under Locations
osascript <<EOF
tell application "Finder"
    tell application "System Events" to tell process "Finder" to keystroke "t" using {command down, control down} --puts folder in sidebar, at the bottom
end tell
EOF

# Instructions for the user to pin the mount in Locations
echo "[$(currentTime) INF] Please pin the mount to the Locations toolbar in Finder by dragging it from the sidebar."
