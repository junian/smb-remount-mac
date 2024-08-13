# smb-remount-mac

## Installation

1. Edit variable in `.smb-remount` file
2. Go to directory of this project. `cd /path/to/smb-remount-mac/`.
3. Run `./smb-mount.sh`. This will also install a `LaunchAgent` that will run in background to check the Mounted smb permission.
4. That's it.


## Uninstallation

To uninstall the `LaunchAgent`, you can just execute `./uninstall.sh`
