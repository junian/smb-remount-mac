# smb-remount-mac

## Installation

1. Put this project to your `$HOME` directory, e.g. `/Users/username/smb-remount-mac`
2. Go to directory of this project. `cd /Users/username/smb-remount-mac`.
3. Edit variable in `.smb-remount` file
4. Run `./smb-mount.sh`. This will also install a `LaunchAgent` that will run in background to check the Mounted smb permission.
5. That's it.


## Uninstallation

To uninstall the `LaunchAgent`, you can just execute `./uninstall.sh`
