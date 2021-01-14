#!/bin/sh

NUM="$(lsblk | grep -n /boot | cut -f 1 -d ':')"
NUM="$(expr $NUM - 1)"
DISKNAME="$(lsblk | sed -n "$NUM p" | cut -f 1 -d ' ')"
USER="$(ls /home)"
TIME="$(ls -l /etc/localtime | sed 's|.*zoneinfo/||')"

#Backup system
mkdir /mnt/_active
mount -o subvol=_active/rootvol /dev/$(echo $DISKNAME)2 /mnt/_active/
btrfs subvolume snapshot -r /mnt/_active /home/$USER/.snapshots/"$(date "+%F")"
umount /mnt/_active
rmdir /mnt/_active
grub-mkconfig -o /boot/grub/grub.cfg

#Update mirrors
reflector --country $(curl -sL https://raw.github.com/eggert/tz/master/zone1970.tab | grep $TIME | awk '{print $1}') --protocol https --sort rate --save /etc/pacman.d/mirrorlist
