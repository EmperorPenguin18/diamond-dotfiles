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
mkdir /mnt/boot
mount /dev/$(echo $DISKNAME)1 /mnt/boot

#Configure mirrors
pacman -S pacman-contrib
curl 'https://www.archlinux.org/mirrorlist/?country=CA&protocol=http&protocol=https&ip_version=4' > /etc/pacman.d/mirrorlist
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
rankmirrors /etc/pacman.d/mirrorlist > /etc/pacman.d/mirrorlist

#Install packages
pacman -Sy
pacstrap /mnt base sudo vim grub parted pacman-contrib btrfs-progs amd-ucode intel-ucode dmidecode

#Generate FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

#Chroot into system
arch-chroot /mnt

#Set localization stuff
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc
locale-gen
echo "LANG=en_CA.UTF-8" > /etc/locale.conf

#Network stuff
echo "Sebs-PC" > /etc/hostname
echo "127.0.0.1   localhost" > /etc/hosts
echo "::1   localhost" >> /etc/hosts
echo "127.0.1.1   Sebs-PC.localdomain  Sebs-PC" >> /etc/hosts
systemctl enable dhcpcd

#Create root password
passwd

#Create user
useradd -m sebastien
passwd sebastien
usermod -aG wheel,audio,video,optical,storage sebastien
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

#Create bootloader
grub-install /dev/$DISKNAME
grub-mkconfig -o /boot/grub/grub.cfg

#Done
reboot
