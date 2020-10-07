#Check if script has root privileges
if [ "$(whoami)" != "root" ]; then
        echo "Script must be run as user: root"
        exit 255
fi

#Setup pacman
mv pacman.conf /etc/pacman.conf
echo '%wheel ALL=(ALL) NOPASSWD: /usr/bin/pacman' >> /etc/sudoers
echo '%wheel ALL=(ALL) NOPASSWD: /usr/bin/yay' >> /etc/sudoers
echo '%wheel ALL=(ALL) NOPASSWD: /usr/bin/makepkg' >> /etc/sudoers
pacman -Sy --needed base-devel --noconfirm
#*Optimize compiling*
cd ../
su sebastien -c "git clone https://aur.archlinux.org/yay.git"
cd yay
su sebastien -c "makepkg -si --noconfirm"
cd ../
rm -r yay
cd LinuxConfigs

#Setup rclone mounts
pacman -S fuse rclone --noconfirm
echo "user_allow_other" >> /etc/fuse.conf
mkdir -p /home/sebastien/.config/rclone
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
pacman -S cron --noconfirm
chmod +x update.sh
mv update.sh ../update.sh
chmod +x backup.sh
mv backup.sh ../backup.sh
echo "0 3 * * 1 root /home/sebastien/backup.sh" >> /etc/crontab
echo "0 4 * * 1 sebastien /home/sebastien/update.sh" >> /etc/crontab

#Setup X Server
pacman -S xorg xorg-drivers lib32-mesa lib32-vulkan-icd-loader vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau vulkan-radeon lib32-vulkan-radeon amdvlk lib32-amdvlk picom --noconfirm
mv picom.conf /home/sebastien/.config/picom.conf
#*Enable vsync, freesync/gsync, hardware acceleration, vulkan etc
mv 10-monitor.conf /etc/X11/xorg.conf.d/10-monitor.conf
#*Multi-monitor*

#Setup login manager
pacman -S lightdm lightdm-webkit2-greeter --noconfirm
mv lightdm.conf /etc/lightdm/lightdm.conf
mv lightdm-webkit2-greeter.conf /etc/lightdm/lightdm-webkit2-greeter.conf
#*Theme*
#*Sessions*
#*On-screen keyboard*

#Setup Plymouth
su sebastien -c "yay -S plymouth --noconfirm"
echo "MODULES=()" > /etc/mkinitcpio.conf
echo "BINARIES=()" >> /etc/mkinitcpio.conf
echo "FILES=()" >> /etc/mkinitcpio.conf
echo "HOOKS=(base udev plymouth autodetect modconf block btrfs filesystems keyboard fsck)" >> /etc/mkinitcpio.conf
mv grub /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
systemctl disable lightdm
systemctl enable lightdm-plymouth
git clone https://github.com/garak92/powered-plymouth-theme/
cd powered-plymouth-theme/
mv powered-plymouth-theme/ /usr/share/plymouth/themes/
cd ../
rm -r powered-plymouth-theme
sed -i "s/Theme=.*/Theme=powered-plymouth-theme/g" /etc/plymouth/plymouthd.conf
mkinitcpio -P

#Setup awesomewm
pacman -S awesome --noconfirm
mkdir -p /home/sebastien/.config/awesome
mv rc.lua /home/sebastien/.config/awesome/rc.lua
mkdir -p /home/sebastien/.config/themes
#mv default /home/sebastien/.config/awesome/themes/default
#*Wallpaper*
#*Fonts*

#Setup terminal emulator
pacman -S alacritty --noconfirm
mkdir -p /home/sebastien/.config/alacritty
#mv alacritty.yml /home/sebastien/.config/alacritty/alacritty.yml
#*Shell*
#*Vim*

#Setup file manager


#Setup web browser
pacman -S firefox --noconfirm
#*Read arch wiki page*

#Setup nvidia drivers
pacman -S nvidia-prime --noconfirm
#*prime-run*

#Setup gaming


#Other
yay -S openssh freetube --noconfirm
#*Improving performance*
#*Manjaro settings*
#*Security*
#*Optional dependencies*
#*Power management*
