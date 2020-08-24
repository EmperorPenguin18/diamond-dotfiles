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
