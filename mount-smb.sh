#!/bin/bash

# Constants
readonly SMB_APP_VERSION=1.0.4
readonly SMB_APP_NAME="smb-remount"
readonly SMB_OLD_NAME="monitor-smb.plist"

CURRENT_DIR="$(pwd)"
readonly CURRENT_DIR

readonly CONFIG_FILE="$CURRENT_DIR/.smb-remount"
readonly LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
readonly SMB_PLIST_FILE="monitor-smb.plist"
readonly SMB_LAUNCH_AGENT_PATH="$LAUNCH_AGENTS_DIR/$SMB_PLIST_FILE"

# Variables Init
SMB_HOST=""
SMB_PORT=""
SMB_PATH=""
SMB_USERNAME=""
SMB_PASSWORD=""
SMB_MOUNT_POINT=""
SMB_MOUNT_OPTIONS=""
SMB_SERVER_MOUNT=""
SMB_SERVER=""

# GetOpts flag
FLAG_SMB_MOUNT=0
FLAG_SMB_UNINSTALL_LAUNCH_AGENT=0
FLAG_SMB_DAEMON=0
#FLAG_SMB_HELP=0
FLAG_SMB_VERSION=0

while getopts mudhv flag
do
    case "${flag}" in
        m) FLAG_SMB_MOUNT=1;;
        u) FLAG_SMB_UNINSTALL_LAUNCH_AGENT=1;;
        d) FLAG_SMB_DAEMON=1;;
        h) ;;
        v) FLAG_SMB_VERSION=1;;
        *) ;;
    esac
done

function currentTime() {
    date +'%F %H:%M:%S'
}

function echolog() {
    echo "[$(currentTime) LOG] $*"
}

function echoerr() {
    echo "[$(currentTime) ERR] $*" 1>&2; 
}

function loadConfig() {
    if [ -f "$CONFIG_FILE" ]; then
        set -a
        # shellcheck source=.smb-remount
        source "$CONFIG_FILE"
        set +a

        SMB_SERVER_MOUNT="$SMB_HOST:$SMB_PORT/$SMB_PATH"
        SMB_SERVER="//$SMB_USERNAME:$SMB_PASSWORD@$SMB_SERVER_MOUNT"
    else
        echoerr "Configuration file not found: $CONFIG_FILE"
    fi
}

function installLaunchAgent() {
    echolog "Installing Launch Agent ..."

    # Create Launch Agent dir if it doesn't exist
    if [ ! -d "$LAUNCH_AGENTS_DIR" ]; then
        mkdir -p "$LAUNCH_AGENTS_DIR"
    fi

    export SMB_PLIST_APP_PATH="$CURRENT_DIR"
    export SMB_PLIST_APP_NAME="$SMB_APP_NAME"
    eval "echo \"$(cat $SMB_PLIST_FILE)\"" > "$SMB_LAUNCH_AGENT_PATH"

    launchctl load "$SMB_LAUNCH_AGENT_PATH"

    echolog "Finished installing Launch Agent"
}

function uninstallLaunchAgent() {
    echolog "Uninstalling existing Launch Agent ..."

    if [ -f "$SMB_LAUNCH_AGENT_PATH" ]
    then
        launchctl unload "$SMB_LAUNCH_AGENT_PATH"
        if command -v trash >/dev/null 2>&1; then
            trash "$SMB_LAUNCH_AGENT_PATH"
        else
            rm "$SMB_LAUNCH_AGENT_PATH"
        fi
    fi

    echolog "Finished uninstall Launch Agent"
}

function mountSMB() {
    # Create the mount point if it doesn't exist
    if [ ! -d "$SMB_MOUNT_POINT" ]; then
        mkdir -p "$SMB_MOUNT_POINT"
    fi

    # Unmount if already mounted (to remount with options)
    if mount | grep -q "@$SMB_SERVER_MOUNT" | grep -q "//$SMB_USERNAME"; then
        echolog "Unmounting \"@$SMB_SERVER_MOUNT\""
        SMB_UNMOUNT_PATH=$(df | grep "@$SMB_SERVER_MOUNT" | grep "//$SMB_USERNAME" | awk '{print $9}')
        diskutil unmount "$SMB_UNMOUNT_PATH"
    fi

    # Mount the SMB share with the specified options
    mount -t smbfs -o "$SMB_MOUNT_OPTIONS" "$SMB_SERVER" "$SMB_MOUNT_POINT"
}

function checkMount() {
    # Check if the mount was successful
    if mount | grep -q "$SMB_MOUNT_POINT"; then
        echolog "SMB share mounted successfully at $SMB_MOUNT_POINT with options: $SMB_MOUNT_OPTIONS"
    else
        echoerr "Failed to mount SMB share"
        exit 1
    fi
}

function openMountLocation() {
    # Ensure the mount point is visible in Finder Locations
    # This step uses the `open` command to open the mounted directory in Finder,
    # which should trigger Finder to add it to the Locations toolbar.
    open "$SMB_MOUNT_POINT"
}

function bookmarkMountLocation() {
    # AppleScript to add the SMB share to the Finder sidebar under Locations
    osascript <<EOF
tell application "Finder"
    tell application "System Events" to tell process "Finder" to keystroke "t" using {command down, control down} --puts folder in sidebar, at the bottom
end tell
EOF

    # Instructions for the user to pin the mount in Locations
    echolog "Please pin the mount to the Locations toolbar in Finder by dragging it from the sidebar."
}

function usage() { 
    printf "%s" "\
Usage: smb-remount -option

smb-remount is a CLI tool to remount a SMB Volume with the correct options.

Options:

    -m                          Mount a SMB volume based on '.smb-remount' config file and install a Launch Agent
                                to monitor the volume.

    -d                          Run a SMB monitor to check SMB Volume. If user mount it using Finder, it'll detect
                                and remount the Volume with correct options.
                                This usage is meant for Launch Agent.

    -u                          Uninstall SMB Remount Launch Agent.

    -h                          Show this usage help.

    -v                          Show Version.

"
}

function smbMonitorDaemon() {
    # Monitor the mount point
    while true; do
        loadConfig

        # Check if the mount point is mounted with the correct options
        if mount | grep -q "$SMB_SERVER_MOUNT"; then
            MOUNT_INFO=$(mount | grep "$SMB_SERVER_MOUNT")
            if [[ "$MOUNT_INFO" != *"$SMB_MOUNT_POINT"* ]]; then
                echolog "Mount options missing, remounting..."
                mountSMB
            fi
        fi
        sleep 1  # Check every 1 second
    done
}

function main() {
    loadConfig

    if ((FLAG_SMB_MOUNT > 0)); then
        echolog "FLAG_SMB_MOUNT"
        mountSMB
        checkMount
        uninstallLaunchAgent
        installLaunchAgent
        openMountLocation
        bookmarkMountLocation
        exit 0;
    fi

    if ((FLAG_SMB_UNINSTALL_LAUNCH_AGENT > 0)); then
        echolog "FLAG_SMB_UNINSTALL_LAUNCH_AGENT"
        uninstallLaunchAgent
        exit 0;
    fi

    if ((FLAG_SMB_DAEMON > 0)); then
        echolog "FLAG_SMB_DAEMON"
        
        exit 0;
    fi

    if ((FLAG_SMB_VERSION > 0)); then
        echo "$SMB_APP_NAME v$SMB_APP_VERSION"
        exit 0;
    fi

    usage
}

main
