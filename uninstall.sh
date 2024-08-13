#!/bin/bash

SMB_LAUNCH_AGENT_PATH="$HOME/Library/LaunchAgents/monitor-smb.plist"

if [ -f "$SMB_LAUNCH_AGENT_PATH" ]
then
    launchctl unload "$SMB_LAUNCH_AGENT_PATH"
    if command -v trash >/dev/null 2>&1; then
        trash "$SMB_LAUNCH_AGENT_PATH"
    else
        rm "$SMB_LAUNCH_AGENT_PATH"
    fi
fi

echo "Uninstall finished"
