#!/bin/sh

DISKNAME="$(lsblk | grep disk | awk '{print $1;}')"
USER="$(ls /home)"
TIME="$(ls -l /etc/localtime | sed 's|.*zoneinfo/||')"

#Backup system
mkdir /mnt/_active
mount -o subvol=_active/rootvol /dev/$(echo $DISKNAME)2 /mnt/_active/
btrfs subvolume snapshot -r /mnt/_active /home/$USER/.snapshots/"$(date "+%F")"
rclone sync --config=/home/$USER/.config/rclone/rclone.conf /home/$USER/.snapshots onedriveschool:/Backups/
umount /mnt/_active
rmdir /mnt/_active
grub-mkconfig -o /boot/grub/grub.cfg

#Update mirrors
reflector --country $(curl -sL https://raw.github.com/eggert/tz/master/zone1970.tab | grep $TIME | awk '{print $1}') --protocol https --sort rate --save /etc/pacman.d/mirrorlist
