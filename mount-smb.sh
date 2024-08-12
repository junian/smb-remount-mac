#!/bin/bash

# Define the SMB server details, credentials, and mount options
CONFIG_FILE="/Users/$USER/.smb-remount"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Create the mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

# Unmount if already mounted (to remount with options)
if mount | grep -q "$MOUNT_POINT"; then
    umount "$MOUNT_POINT"
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

# Ensure the mount point is visible in Finder Locations
# This step uses the `open` command to open the mounted directory in Finder,
# which should trigger Finder to add it to the Locations toolbar.
open "$MOUNT_POINT"

# Instructions for the user to pin the mount in Locations
echo "Please pin the mount to the Locations toolbar in Finder by dragging it from the sidebar."
