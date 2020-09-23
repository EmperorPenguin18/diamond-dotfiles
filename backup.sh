#Backup system
DISKNAME=$(lsblk | grep disk | awk '{print $1;}')
mkdir /mnt/_active
mount -o subvol=_active/rootvol /dev/$(echo $DISKNAME)2 /mnt/_active/
btrfs subvolume snapshot -r /mnt/_active /home/sebastien/.snapshots/"$(date "+%F")"
rclone sync --config=/home/sebastien/.config/rclone/rclone.conf /home/sebastien/.snapshots onedriveschool:/Backups/
umount /mnt/_active
rmdir /mnt/_active
grub-mkconfig -o /boot/grub/grub.cfg

#Update mirrors
reflector --country Canada --protocol https --sort rate --save /etc/pacman.d/mirrorlist
