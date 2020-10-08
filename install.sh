#Check if script has root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#Set system time
timedatectl set-ntp true

#Partition disk
pacman -S dmidecode --noconfirm
DISKNAME=$(lsblk | grep disk | awk '{print $1;}')
DISKSIZE=$(lsblk --output SIZE -n -d /dev/$DISKNAME | sed 's/.$//')
MEMSIZE=$(dmidecode -t 17 | grep "Size.*MB" | awk '{s+=$2} END {print s / 1024}')
parted --script /dev/$DISKNAME \
   mklabel gpt \
   mkpart P1 fat32 1MB 261MB \
   set 1 esp on \
   mkpart P2 btrfs 261MB $(expr $DISKSIZE - $MEMSIZE)GB \
   mkpart P3 linux-swap $(expr $DISKSIZE - $MEMSIZE)GB $(echo $DISKSIZE)GB
if [ $(echo $DISKNAME | head -c 2 ) = "sd" ]; then
   DISKNAME=$DISKNAME
else
   DISKNAME=$(echo $DISKNAME)p
fi

#Format partitions
mkfs.fat -F32 /dev/$(echo $DISKNAME)1
mkfs.btrfs -L arch /dev/$(echo $DISKNAME)2
mkswap /dev/$(echo $DISKNAME)3
swapon /dev/$(echo $DISKNAME)3
mount /dev/$(echo $DISKNAME)2 /mnt

#BTRFS subvolumes
cd /mnt
btrfs subvolume create _active
btrfs subvolume create _active/rootvol
btrfs subvolume create _active/homevol
btrfs subvolume create _active/tmp
btrfs subvolume create _snapshots
cd /root/LinuxConfigs

#Mount subvolumes for install
umount /mnt
mount -o subvol=_active/rootvol /dev/$(echo $DISKNAME)2 /mnt
mkdir /mnt/{home,tmp,boot}
mkdir /mnt/boot/EFI
mount -o subvol=_active/tmp /dev/$(echo $DISKNAME)2 /mnt/tmp
mount /dev/$(echo $DISKNAME)1 /mnt/boot/EFI
mount -o subvol=_active/homevol /dev/$(echo $DISKNAME)2 /mnt/home

#Configure mirrors
pacman -S reflector --noconfirm
reflector --country Canada --protocol https --sort rate --save /etc/pacman.d/mirrorlist

#Install packages
pacman -Sy
pacstrap /mnt base linux linux-firmware linux-headers sudo vim grub grub-btrfs efibootmgr dosfstools os-prober mtools parted reflector btrfs-progs amd-ucode intel-ucode dmidecode networkmanager git

#Generate FSTAB
UUID1=$(blkid -s UUID -o value /dev/$(echo $DISKNAME)1)
UUID2=$(blkid -s UUID -o value /dev/$(echo $DISKNAME)2)
UUID3=$(blkid -s UUID -o value /dev/$(echo $DISKNAME)3)
echo UUID=$UUID2 /  btrfs rw,relatime,compress=lzo,ssd,discard,autodefrag,space_cache,subvol=/_active/rootvol   0  0 >> /mnt/etc/fstab
echo UUID=$UUID1 /boot/EFI   vfat  rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro   0  2 >> /mnt/etc/fstab
echo UUID=$UUID2 /tmp  btrfs rw,relatime,compress=lzo,ssd,discard,autodefrag,space_cache,subvol=_active/tmp  0  0 >> /mnt/etc/fstab
echo UUID=$UUID2 /home btrfs rw,relatime,compress=lzo,ssd,discard,autodefrag,space_cache,subvol=_active/homevol   0  0 >> /mnt/etc/fstab
echo UUID=$UUID3 none  swap  defaults 0  0 >> /mnt/etc/fstab
echo UUID=$UUID2 /home/sebastien/.snapshots btrfs rw,relatime,compress=lzo,ssd,discard,autodefrag,space_cache,subvol=_snapshots 0  0 >> /mnt/etc/fstab

#Chroot into system
chmod +x install-chroot.sh
cp install-chroot.sh /mnt/install-chroot.sh
echo ""
echo "Run install-chroot.sh now"
arch-chroot /mnt

#Done
rm /mnt/install-chroot.sh
reboot
#*Encrypted disk*
