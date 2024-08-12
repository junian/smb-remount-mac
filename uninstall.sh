#!/bin/bash

SMB_PLIST_PATH="$HOME/Library/LaunchAgents/monitor-smb.plist"
launchctl unload $SMB_PLIST_PATH
rm -rf $SMB_PLIST_PATH

