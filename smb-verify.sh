#/bin/sh

mount | grep "$HOME/mounts.noindex" | grep noatime

smbutil statshares -m "$HOME/mounts.noindex/MEDIA" | grep DATA_CACHING_OFF
