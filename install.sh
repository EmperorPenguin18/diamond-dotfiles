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
mkfs.btrfs /dev/$(echo $DISKNAME)2
mkswap /dev/$(echo $DISKNAME)3
swapon /dev/$(echo $DISKNAME)3
mount /dev/$(echo $DISKNAME)2 /mnt
mkdir /mnt/efi
mount /dev/$(echo $DISKNAME)1 /mnt/efi

#Configure mirrors
pacman -S pacman-contrib
curl 'https://www.archlinux.org/mirrorlist/?country=CA&protocol=http&protocol=https&ip_version=4' > /etc/pacman.d/mirrorlist
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
rankmirrors /etc/pacman.d/mirrorlist >> /etc/pacman.d/mirrorlist

#Install packages
pacman -Sy
pacstrap /mnt base sudo vim grub efibootmgr parted pacman-contrib btrfs-progs amd-ucode intel-ucode dmidecode

#Generate FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

#Chroot into system
chmod +x install-chroot.sh
cp install-chroot.sh /mnt/install-chroot.sh
arch-chroot /mnt

#Done
rm /mnt/install-chroot.sh
reboot
