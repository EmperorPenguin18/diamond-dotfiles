#!/bin/sh

## From gentoo wiki
NOW=$(date +"%Y-%m-%d_%H:%M:%S")
 
if [ ! -e /mnt/backup ]; then
mkdir -p /mnt/backup
fi
 
cd /
/sbin/btrfs subvolume snapshot / "/mnt/backup/backup_${NOW}"
##

grub-mkconfig -o /boot/grub/grub.cfg
