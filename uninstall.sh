#!/bin/bash

LAUNCH_AGENTS_PATH="$HOME/Library/LaunchAgents/monitor-smb.plist"

launchctl unload "$LAUNCH_AGENTS_PATH"

if command -v trash >/dev/null 2>&1; then
    trash "$LAUNCH_AGENTS_PATH"
else
    rm "$LAUNCH_AGENTS_PATH"
fi
