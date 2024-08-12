#!/bin/bash

# Define the SMB server details, credentials, and mount options
SMB_USERNAME=""
SMB_PASSWORD=""
SMB_SERVER="//${SMB_USERNAME}:${SMB_PASSWORD}@example.com/MEDIA"
SMB_SERVER_MOUNT="//${SMB_USERNAME}@example.com/MEDIA"
MOUNT_POINT="/Users/$USER/mounts.noindex/MEDIA"
MOUNT_OPTIONS="nodatacache,noatime"

# Function to remount the SMB share with the correct options
remount_smb() {
    # Unmount the share if it's already mounted
    if mount | grep -q "$SMB_SERVER_MOUNT"; then
        umount "$SMB_SERVER_MOUNT"
    fi

    # Remount the share with the correct options
    mount -t smbfs -o "$MOUNT_OPTIONS" "$SMB_SERVER" "$MOUNT_POINT"
}

# Monitor the mount point
while true; do
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