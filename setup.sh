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
pacman -S xorg xorg-drivers lib32-mesa lib32-vulkan-icd-loader vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau vulkan-radeon lib32-vulkan-radeon amdvlk lib32-amdvlk --noconfirm
#*Enable vsync, freesync/gsync, hardware acceleration, vulkan etc
mv 10-monitor.conf /etc/X11/xorg.conf.d/10-monitor.conf
#*Multi-monitor*

#Setup nvidia drivers
pacman -S nvidia-prime --noconfirm
#*prime-run*

#Setup login manager
yay -S lightdm lightdm-webkit2-greeter lightdm-webkit2-theme-glorious --noconfirm
mv lightdm.conf /etc/lightdm/lightdm.conf
mv lightdm-webkit2-greeter.conf /etc/lightdm/lightdm-webkit2-greeter.conf
mv index.html /usr/share/lightdm-webkit/themes/glorious/
rm /usr/share/backgrounds/*
mv background.png /usr/share/backgrounds/
mv steam-big-picture.desktop /usr/share/xsessions/
mv jellyfin.desktop /usr/share/xsessions/
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
pacman -S awesome picom all-repository-fonts rofi unclutter --noconfirm --needed
mkdir -p /home/sebastien/.config/awesome
mv rc.lua /home/sebastien/.config/awesome/rc.lua
mkdir -p /home/sebastien/.config/awesome/themes
mv theme.lua /home/sebastien/.config/awesome/themes/theme.lua
mv wallpaper.jpg /home/sebastien/.config/awesome/themes/wallpaper.jpg
mv picom.conf /home/sebastien/.config/picom.conf
cd ../
git clone https://github.com/EmperorPenguin18/SkyrimCursor
mkdir /home/sebastien/.local/share/icons/skyrim/cursor
cp SkyrimCursor/Small/Linux/x11/* /home/sebastien/.local/share/icons/skyrim/cursor/
rm -r SkyrimCursor
cd LinuxConfigs
unzip DTM.ZIP
rm DTM.ZIP
mv *.otf /usr/share/fonts/
chmod 0444 /usr/share/fonts/DTM-Mono.otf
chmod 0444 /usr/share/fonts/DTM-Sans.otf
fc-cache
mkdir /home/sebastien/.config/rofi
mv config.rasi /home/sebastien/.config/rofi/
mv *.rasi /usr/share/rofi/themes/
mv rofi-*.sh /home/sebastien/
#*Help/shortcuts*

#Setup terminal emulator
pacman -S alacritty --noconfirm
mkdir -p /home/sebastien/.config/alacritty
#mv alacritty.yml /home/sebastien/.config/alacritty/alacritty.yml
#*Shell*
#*Vim*
#*Help command (for terminal utilities)*

#Setup file manager


#Setup web browser
pacman -S firefox --noconfirm
#*Read arch wiki page*

#Setup gaming
#*Lutris wiki*
#*CTT ultimate gaming guide*
#*Input drivers*
#*vkBasalt*

#Other
yay -S openssh freetube --noconfirm
#*Improving performance*
#*Manjaro settings*
#*Security*
#*Optional dependencies*
#*Power management*
#*Audio*

#Finish
cd ../
rm -r LinuxConfigs
reboot
