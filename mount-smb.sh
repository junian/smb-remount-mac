#!/bin/bash

CURRENT_DIR="$(pwd)"

# Define the SMB server details, credentials, and mount options
CONFIG_FILE="$CURRENT_DIR/.smb-remount"

if [ -f "$CONFIG_FILE" ]; then
    set -a
    source "$CONFIG_FILE"
    set +a
else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Create the mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

# Unmount if already mounted (to remount with options)
if mount | grep -q "$SMB_SERVER_MOUNT"; then
    echo "Unmounting $SMB_SERVER_MOUNT"
    UNMOUNT_PATH=$(df | grep "$SMB_SERVER_MOUNT" | awk '{print $9}')
    # umount -v "$SMB_SERVER_MOUNT"
    diskutil unmount "$UNMOUNT_PATH"
fi

# Mount the SMB share with the specified options
mount -t smbfs -o "$MOUNT_OPTIONS" "$SMB_SERVER" "$MOUNT_POINT"

# Check if the mount was successful
if mount | grep -q "$MOUNT_POINT"; then
    echo "SMB share mounted successfully at $MOUNT_POINT with options: $MOUNT_OPTIONS"
else
    echo "Failed to mount SMB share"
    exit 1
fi

launchctl unload ~/Library/LaunchAgents/monitor-smb.plist
export MONITOR_SMB_PATH="$CURRENT_DIR"
eval "echo \"$(cat monitor-smb.plist)\"" > ~/Library/LaunchAgents/monitor-smb.plist
launchctl load ~/Library/LaunchAgents/monitor-smb.plist

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
echo "Please pin the mount to the Locations toolbar in Finder by dragging it from the sidebar."
