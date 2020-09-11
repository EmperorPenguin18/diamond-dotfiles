#Get the diskname
ls /dev
echo "Enter the name of the install disk (e.g. sda)"
read DISKNAME

#Set localization stuff
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
hwclock --systohc
echo "en_CA.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_CA.UTF-8" > /etc/locale.conf

#Network stuff
echo "Sebs-PC" > /etc/hostname
echo "127.0.0.1   localhost" > /etc/hosts
echo "::1   localhost" >> /etc/hosts
echo "127.0.1.1   Sebs-PC.localdomain  Sebs-PC" >> /etc/hosts
systemctl enable NetworkManager

#Create root password
passwd

#Create user
useradd -m sebastien
passwd sebastien
usermod -aG wheel,audio,video,optical,storage sebastien
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

#Create bootloader
mkdir /boot/EFI
mount /dev/$(echo $DISKNAME)1 /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg
