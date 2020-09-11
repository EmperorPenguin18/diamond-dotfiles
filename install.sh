#Check if script has root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#Set system time
timedatectl set-ntp true

#Partition disk
pacman -S dmidecode
DISKNAME=$(lsblk | grep disk | awk '{print $1;}')
DISKSIZE=$(lsblk --output SIZE -n -d /dev/$DISKNAME | sed 's/.$//')
MEMSIZE=$(dmidecode -t 17 | grep "Size.*MB" | awk '{s+=$2} END {print s / 1024}')
parted --script /dev/$DISKNAME \
   mklabel gpt \
   mkpart P1 fat32 1MB 261MB \
   set 1 esp on \
   mkpart P2 btrfs 261MB $(expr $DISKSIZE - $MEMSIZE)GB \
   mkpart P3 linux-swap $(expr $DISKSIZE - $MEMSIZE)GB $(echo $DISKSIZE)GB

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
cd ../

#Mount subvolumes for install
umount /mnt
mount -o subvol=_active/rootvol /dev/$(echo $DISKNAME)2 /mnt
mkdir /mnt/{home,tmp,boot}
mkdir /mnt/boot/EFI
mount -o subvol=_active/tmp /dev/$(echo $DISKNAME)2 /mnt/tmp
mount /dev/$(echo $DISKNAME)1 /mnt/boot/EFI
mount -o subvol=_active/homevol /dev/$(echo $DISKNAME)2 /mnt/home

#Configure mirrors
pacman -S reflector
reflector --country Canada --protocol https --sort rate --save /etc/pacman.d/mirrorlist

#Install packages
pacman -Sy
pacstrap /mnt base linux linux-firmware sudo vim grub grub-btrfs efibootmgr dosfstools os-prober mtools parted reflector btrfs-progs amd-ucode intel-ucode dmidecode networkmanager git

#Generate FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

#Chroot into system
chmod +x install-chroot.sh
cp install-chroot.sh /mnt/install-chroot.sh
echo ""
echo "Run install-chroot.sh now"
arch-chroot /mnt

#Done
rm /mnt/install-chroot.sh
reboot
