#!/bin/bash

#Check if script has root privileges
if [ "$(whoami)" != "root" ]; then
        echo "Script must be run as user: root"
        exit 255
fi

#Setup pacman
mv pacman/pacman.conf /etc/pacman.conf
echo "permit nopass /usr/bin/pacman" >> /etc/doas.conf
echo "permit nopass /usr/bin/yay" >> /etc/doas.conf
echo "permit nopass /usr/bin/makepkg" >> /etc/doas.conf
sed -i '/MAKEFLAGS/c\MAKEFLAGS="-j$(nproc)"' /etc/makepkg.conf
cd ../
su sebastien -c "git clone https://aur.archlinux.org/opendoas-sudo.git"
cd opendoas-sudo
su sebastien -c "makepkg -i --noconfirm"
cd ../
rm -r opendoas-sudo
pacman -Sy --needed base-devel --noconfirm
su sebastien -c "git clone https://aur.archlinux.org/yay.git"
cd yay
su sebastien -c "makepkg -si --noconfirm"
cd ../
rm -r yay
cd ArchConfigs

#Setup rclone mounts
pacman -S fuse rclone --noconfirm
echo "user_allow_other" >> /etc/fuse.conf
mkdir -p /home/sebastien/.config/rclone
mv rclone/rclone.conf /home/sebastien/.config/rclone/rclone.conf
chown sebastien:sebastien /home/sebastien/.config/rclone/rclone.conf
mv rclone/rclone1.service /etc/systemd/system/rclone1.service
mv rclone/rclone2.service /etc/systemd/system/rclone2.service
mv rclone/rclone3.service /etc/systemd/system/rclone3.service
mkdir /mnt/Personal
mkdir /mnt/School
mkdir /mnt/Media
systemctl enable rclone1
systemctl enable rclone2
systemctl enable rclone3

#Setup updates + backups
pacman -S cron reflector --noconfirm
chmod +x update.sh
mv update/update.sh /home/sebastien/update.sh
chmod +x backup.sh
mv update/backup.sh /home/sebastien/backup.sh
echo "0 3 * * 1 root /home/sebastien/backup.sh" >> /etc/crontab
echo "0 4 * * 1 sebastien /home/sebastien/update.sh" >> /etc/crontab
#*Other system maintenance?*

#Setup X Server
pacman -S xorg xorg-drivers lib32-mesa lib32-vulkan-icd-loader vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau vulkan-radeon lib32-vulkan-radeon amdvlk lib32-amdvlk --noconfirm
#*Enable vsync, freesync/gsync, hardware acceleration, vulkan etc
mv xorg/10-monitor.conf /etc/X11/xorg.conf.d/10-monitor.conf
#*Multi-monitor*

#Setup nvidia drivers
pacman -S nvidia-prime --noconfirm
#*prime-run*

#Setup login manager
yay -S lightdm lightdm-webkit2-greeter lightdm-webkit2-theme-glorious --noconfirm
mv login/lightdm.conf /etc/lightdm/lightdm.conf
mv login/lightdm-webkit2-greeter.conf /etc/lightdm/lightdm-webkit2-greeter.conf
mv login/index.html /usr/share/lightdm-webkit/themes/glorious/
rm /usr/share/backgrounds/*
mv login/background.png /usr/share/backgrounds/
mv login/steam-big-picture.desktop /usr/share/xsessions/
mv login/jellyfin.desktop /usr/share/xsessions/
#*Theme*
#*Sessions*
#*On-screen keyboard*

#Setup Plymouth
su sebastien -c "yay -S plymouth --noconfirm"
echo "MODULES=()" > /etc/mkinitcpio.conf
echo "BINARIES=()" >> /etc/mkinitcpio.conf
echo "FILES=()" >> /etc/mkinitcpio.conf
echo "HOOKS=(base udev plymouth autodetect modconf block btrfs filesystems keyboard fsck)" >> /etc/mkinitcpio.conf
mv plymouth/grub /etc/default/grub
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

#Setup window manager
yay -S spectrwm feh picom all-repository-fonts rofi unclutter --noconfirm --needed
mv windowmanager/spectrwm.conf /home/sebastien/.spectrwm.conf
mv windowmanager/wallpaper.jpg /home/sebastien/wallpaper.jpg
feh -bg-scale /home/sebastien/wallpaper.jpg
mv windowmanager/picom.conf /home/sebastien/.config/picom.conf
cd ../
git clone https://github.com/EmperorPenguin18/SkyrimCursor
mkdir /home/sebastien/.local/share/icons/skyrim/cursor
cp SkyrimCursor/Small/Linux/x11/* /home/sebastien/.local/share/icons/skyrim/cursor/
rm -r SkyrimCursor
cd LinuxConfigs
unzip windowmanager/DTM.ZIP -d ./
rm windowmanager/DTM.ZIP
mv *.otf /usr/share/fonts/
chmod 0444 /usr/share/fonts/DTM-Mono.otf
chmod 0444 /usr/share/fonts/DTM-Sans.otf
fc-cache
mkdir /home/sebastien/.config/rofi
mv windowmanager/config.rasi /home/sebastien/.config/rofi/
mv windowmanager/*.rasi /usr/share/rofi/themes/
chmod +x rofi-*.sh
mv windowmanager/rofi-*.sh /home/sebastien/
#https://github.com/seebye/ueberzug
#https://manpages.debian.org/testing/rofi/rofi-theme.5.en.html
#https://github.com/adi1090x/rofi

#Setup terminal emulator
pacman -S alacritty parted openssh --noconfirm
mkdir -p /home/sebastien/.config/alacritty
#mv terminal/alacritty.yml /home/sebastien/.config/alacritty/alacritty.yml
#*Core utilities
#*Shell*
#*Icons*
#*Text editor - Vim, Emacs, Sublime*
#*Compiler*
#*Help command (for terminal utilities)*
#https://github.com/manilarome/fishblocks

#Setup file manager
pacman -S mtools --noconfirm
#*GTK*
#*Icons*
#*Filesystems*
#https://github.com/deviantfero/wpgtk
#https://github.com/Misterio77/flavours

#Setup web browser
pacman -S firefox --noconfirm
#*Read arch wiki page*
#*Privacy*
#https://github.com/akshat46/FlyingFox
#https://ffprofile.com/
#https://github.com/manilarome/blurredfox
#https://www.youtube.com/watch?v=NH4DdXC0RFw&ab_channel=SunKnudsen

#Setup gaming
#*Lutris wiki*
#*CTT ultimate gaming guide*
#*Input drivers*
#*vkBasalt*
#*Arch wiki everything*
#*Benchmarking*
#*Overlock*
#*RGB*
#*Mangohud*
#*tkGlitch*
#https://github.com/gamer-os

#Setup power management
#*Brightness*
#*TLP*
#*AUTO_CPUFREQ*
#*Screensaver*
#*Auto-hibernate*
#*Profiles*
#*powertop*

#Other
yay -S freetube discord --noconfirm
#*Improving performance*
#*Manjaro settings*
#*Security*
#*Optional dependencies*
#*Audio*
#*Music*
#*Screen capture*
#*VMs*
#*Video calling*
#https://github.com/AryToNeX/Glasscord
#https://github.com/Lightcord/Lightcord
#https://unix.stackexchange.com/questions/53080/list-optional-dependencies-with-pacman-on-arch-linux
#https://github.com/hakavlad/nohang
#https://wiki.archlinux.org/index.php/Zswap
#https://github.com/Nefelim4ag/Ananicy

#Finish
cd ../
rm -r LinuxConfigs
reboot
#*System configs*
#*Script performance*
#https://wiki.archlinux.org/index.php/Dash
#https://wiki.archlinux.org/index.php/Dotfiles
#https://wiki.archlinux.org/index.php/General_recommendations
