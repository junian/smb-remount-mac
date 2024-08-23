# smb-remount-mac

## Installation

1. Put this project to your `$HOME` directory, e.g. `/Users/username/smb-remount-mac`
2. Go to directory of this project. `cd /Users/username/smb-remount-mac`.
3. Edit variable in `.smb-remount` file
4. Run `./smb-remount -m`. This will also install a `LaunchAgent` that will run in background to check the Mounted smb permission.
5. That's it.


## Uninstallation

To uninstall the `LaunchAgent`, you can just execute `./smb-remount -u` or `./uninstall.sh`.

## Usage

```shell
$ ./smb-remount  
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
```

