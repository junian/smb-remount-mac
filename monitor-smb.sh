#!/bin/bash

CURRENT_DIR="$(pwd)"

# Define the SMB server details, credentials, and mount options
CONFIG_FILE="$CURRENT_DIR/.smb-remount"

# Function to remount the SMB share with the correct options
remount_smb() {
    # Create the mount point if it doesn't exist
    if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p "$MOUNT_POINT"
    fi

    # Unmount the share if it's already mounted
    if mount | grep -q "$SMB_SERVER_MOUNT"; then
        echo "Unmounting $SMB_SERVER_MOUNT"
        UNMOUNT_PATH=$(df | grep "$SMB_SERVER_MOUNT" | awk '{print $9}')
        # umount -v "$SMB_SERVER_MOUNT"
        diskutil unmount "$UNMOUNT_PATH"
    fi

    # Remount the share with the correct options
    mount -t smbfs -o "$MOUNT_OPTIONS" "$SMB_SERVER" "$MOUNT_POINT"

    # Reopen the mount point in Finder to avoid disruption
    open "$MOUNT_POINT"
}

# Monitor the mount point
while true; do
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "Configuration file not found: $CONFIG_FILE"
    fi

    # Check if the mount point is mounted with the correct options
    if mount | grep -q "$SMB_SERVER_MOUNT"; then
        MOUNT_INFO=$(mount | grep "$SMB_SERVER_MOUNT")
        if [[ "$MOUNT_INFO" != *"$MOUNT_POINT"* ]]; then
            echo "Mount options missing, remounting..."
            remount_smb
        fi
    fi
    sleep 1  # Check every 10 seconds
done
