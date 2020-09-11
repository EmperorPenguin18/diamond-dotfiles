#Check if script has root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#Setup pacman
echo "[multilib]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
echo "" >> /etc/pacman.conf
echo "Color" >> /etc/pacman.conf
echo "ILoveCandy" >> /etc/pacman.conf
pacman -Sy --needed base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ../
rm -r yay
#*Optimize compiling*

#Setup rclone mounts
pacman -S rclone
echo "user_allow_other" >> /etc/fuse.conf
mv rclone.conf /home/sebastien/.config/rclone/rclone.conf
chown sebastien:sebastien /home/sebastien/.config/rclone/rclone.conf
mv rclone1.service /etc/systemd/system/rclone1.service
mv rclone2.service /etc/systemd/system/rclone2.service
mv rclone3.service /etc/systemd/system/rclone3.service
mkdir /mnt/Personal
mkdir /mnt/School
mkdir /mnt/Media
systemctl enable rclone1
systemctl enable rclone2
systemctl enable rclone3

#Setup updates + backups
pacman -S cron
echo '%wheel ALL=(ALL) NOPASSWD: /usr/bin/pacman' >> /etc/sudoers
echo '%wheel ALL=(ALL) NOPASSWD: /usr/bin/yay' >> /etc/sudoers
chmod +x update.sh
mv update.sh ../update.sh
echo "0 4 * * 1 sebastien /home/sebastien/update.sh" >> /etc/crontab

#Setup X Server
pacman -S xorg
#*Compositor*

#Setup login manager


#Setup Plymouth
yay -S plymouth
echo "MODULES()" > /etc/mkinitcpio.conf
echo "BINARIES()" >> /etc/mkinitcpio.conf
echo "FILES()" >> /etc/mkinitcpio.conf
echo "HOOKS=(base udev plymouth autodetect modconf block btrfs filesystems keyboard fsck)" >> /etc/mkinitcpio.conf
sed '6d' /etc/default/grub
sed '5 a GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0"' /etc/default/grub
#*Silent boot*
grub-mkconfig -o /boot/grub/grub.cfg
systemctl disable lightdm
systemctl enable lightdm-plymouth
git clone https://github.com/garak92/powered-plymouth-theme/
cd powered-plymouth-theme/
mv powered-plymouth-theme/ /usr/share/plymouth/themes/
cd ../
rm -r powered-plymouth-theme
sed "s/Theme=.*/Theme=powered-plymouth-theme/g" /etc/plymouth/plymouthd.conf
mkinitcpio -P

#Setup awesomewm
#*Wallpaper*

#Setup terminal emulator
pacman -S alacritty
mv alacritty.yml /home/sebastien/.config/alacritty/alacritty.yml
#*Shell*
#*Vim*

#Setup file manager


#Setup web browser
pacman -S firefox
#*Read arch wiki page*

#Setup nvidia drivers


#Setup gaming


#Other
pacman -S openssh
#*Improving performance*
#*Manjaro settings*
