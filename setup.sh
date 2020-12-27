#!/bin/sh

pre_checks ()
{
    if [ "$(whoami)" != "root" ]; then
        echo "Script must be run as user: root"
        exit 255
    fi
    USER="$(ls /home)"
    cd /home/$USER/ArchConfigs
    DIR="$(pwd)"
    pacman -Sy unzip --noconfirm
}

packagemanager ()
{
    mv packagemanager/pacman.conf /etc/pacman.conf
    echo "permit nopass /usr/bin/pacman" >> /etc/doas.conf
    echo "permit nopass /usr/bin/pikaur" >> /etc/doas.conf
    echo "permit nopass /usr/bin/makepkg" >> /etc/doas.conf
    sed -i '/MAKEFLAGS/c\MAKEFLAGS="-j$(nproc)"' /etc/makepkg.conf
    cd ../
    pacman -Sy autoconf automake bison flex groff m4 pkgconf pyalpm python-commonmark --noconfirm
    su $USER -c "git clone https://aur.archlinux.org/pikaur.git"
    cd pikaur
    su $USER -c "makepkg --noconfirm"
    pacman -U *.pkg* --noconfirm
    cd ../
    rm -r pikaur
    cd $DIR
}

cloud ()
{
    pacman -S fuse rclone --noconfirm
    echo "user_allow_other" >> /etc/fuse.conf
    mkdir -p /home/$USER/.config/rclone
    mv cloud/rclone.conf /home/$USER/.config/rclone/rclone.conf
    chown $USER:$USER /home/$USER/.config/rclone/rclone.conf
    mv cloud/rclone1.service /etc/systemd/system/rclone1.service
    mv cloud/rclone2.service /etc/systemd/system/rclone2.service
    mv cloud/rclone3.service /etc/systemd/system/rclone3.service
    mkdir /mnt/Personal
    mkdir /mnt/School
    mkdir /mnt/Media
    systemctl enable rclone1
    systemctl enable rclone2
    systemctl enable rclone3
}

update ()
{
    pacman -S cron reflector --noconfirm
    chmod +x update/update.sh
    mv update/update.sh /home/$USER/update.sh
    chmod +x update/backup.sh
    mv update/backup.sh /home/$USER/backup.sh
    echo "0 3 * * 1 root /home/$USER/backup.sh" >> /etc/crontab
    echo "0 4 * * 1 $USER /home/$USER/update.sh" >> /etc/crontab
    #*Other system maintenance?*
}

xorg ()
{
    pacman -S xorg xorg-drivers lib32-mesa lib32-vulkan-icd-loader vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau vulkan-radeon lib32-vulkan-radeon amdvlk lib32-amdvlk --noconfirm
    #*Enable vsync, freesync/gsync, hardware acceleration, vulkan etc
    #mv xorg/10-monitor.conf /etc/X11/xorg.conf.d/10-monitor.conf
    #*Multi-monitor*
}

nvidia ()
{
    pacman -S nvidia-prime --noconfirm
    #*prime-run*
}

login ()
{
    pikaur -S lightdm lightdm-webkit2-greeter lightdm-webkit2-theme-glorious --noconfirm
    mv login/lightdm.conf /etc/lightdm/lightdm.conf
    mv login/lightdm-webkit2-greeter.conf /etc/lightdm/lightdm-webkit2-greeter.conf
    mv login/index.html /usr/share/lightdm-webkit/themes/glorious/
    rm -r /usr/share/backgrounds/*
    mv login/background.png /usr/share/backgrounds/
    mkdir -p /usr/share/xsessions
    mv login/steam-big-picture.desktop /usr/share/xsessions/
    mv login/jellyfin.desktop /usr/share/xsessions/
    #*Theme*
    #*Sessions*
    #*On-screen keyboard*
    #*http://www.mattfischer.com/blog/archives/5*
}

plymouth ()
{
    pikaur -S plymouth --noconfirm
    sed -i '4d' /etc/mkinitcpio.conf
    echo "HOOKS=(base udev plymouth plymouth-encrypt autodetect modconf block btrfs filesystems keyboard fsck)" >> /etc/mkinitcpio.conf
    mv plymouth/grub /etc/default/grub
    sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(blkid -o device | xargs -L1 cryptsetup luksUUID):cryptroot\"/g" /etc/default/grub
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
}

windowmanager ()
{
    pikaur -S spectrwm feh picom all-repository-fonts rofi unclutter --noconfirm --needed
    mv windowmanager/spectrwm.conf /home/$USER/.spectrwm.conf
    mv windowmanager/wallpaper.jpg /home/$USER/wallpaper.jpg
    echo "feh --bg-scale /home/$USER/wallpaper.jpg" > /home/$USER/.fehbg
    chmod +x /home/$USER/.fehbg
    mv windowmanager/picom.conf /home/$USER/.config/picom.conf
    cd ../
    git clone https://github.com/EmperorPenguin18/SkyrimCursor
    mkdir -p /home/$USER/.local/share/icons/skyrim/cursor
    cp SkyrimCursor/Small/Linux/x11/* /home/$USER/.local/share/icons/skyrim/cursor/
    rm -r SkyrimCursor
    cd $DIR
    unzip windowmanager/DTM.ZIP -d ./
    rm windowmanager/DTM.ZIP
    mv *.otf /usr/share/fonts/
    chmod 0444 /usr/share/fonts/DTM-Mono.otf
    chmod 0444 /usr/share/fonts/DTM-Sans.otf
    fc-cache
    mkdir /home/$USER/.config/rofi
    mv windowmanager/config.rasi /home/$USER/.config/rofi/
    mv windowmanager/*.rasi /usr/share/rofi/themes/
    chmod +x windowmanager/rofi-*.sh
    mv windowmanager/rofi-*.sh /home/$USER/
    #https://github.com/seebye/ueberzug
    #https://manpages.debian.org/testing/rofi/rofi-theme.5.en.html
    #https://github.com/adi1090x/rofi
    #https://www.youtube.com/watch?v=kw2mnwhptjw&ab_channel=meribold
}

terminal ()
{
    pacman -S alacritty mlocate lsd pkgfile neovim parted openssh --noconfirm
    mkdir -p /home/$USER/.config/alacritty
    mv terminal/alacritty.yml /home/$USER/.config/alacritty/alacritty.yml
    mkdir -p /home/$USER/.config/fish
    mv terminal/config.fish /home/$USER/.config/fish/config.fish
    mv terminal/fish_variables /home/$USER/.config/fish/fish_variables
    systemctl enable pkgfile-update.timer
    mkdir -p /home/$USER/.config/nvim
    mv terminal/init.vim /home/$USER/.config/nvim/init.vim
    #*Help command (for terminal utilities)*
    #*Fetch*
}

filemanager ()
{
    pacman -S pcmanfm-gtk3 mtools --noconfirm
    #*GTK*
    #*Icons*
    #*Filesystems*
    #*File types*
    #https://github.com/deviantfero/wpgtk
    #https://github.com/Misterio77/flavours
}

#audio ()
#{
    #*ALSA*
    #*PulseAudio*
    #*Spotify*
#}

browser ()
{
    pacman -S firefox --noconfirm
    #*Read arch wiki page*
    #*Privacy*
    #https://github.com/akshat46/FlyingFox
    #https://ffprofile.com/
    #https://github.com/manilarome/blurredfox
    #https://www.youtube.com/watch?v=NH4DdXC0RFw&ab_channel=SunKnudsen
}

#gaming ()
#{
    #*Lutris wiki*
    #*CTT ultimate gaming guide*
    #*Input drivers*
    #*vkBasalt*
    #*Arch wiki everything*
    #*Benchmarking*
    #*Overlock*
    #*RGB*
    #*Mangohud*
    #*GloriousEggroll*
    #*tkGlitch*
    #https://github.com/gamer-os
#}

#power ()
#{
    #*Brightness*
    #*TLP*
    #*AUTO_CPUFREQ*
    #*Screensaver*
    #*Auto-hibernate*
    #*Profiles*
    #*powertop*
#}

#virtualization ()
#{
    #*KVM*
    #*QEMU*
    #*Virt-manager*
    #*Extras*
    #https://github.com/Fmstrat/winapps
#}

other ()
{
    pikaur -S freetube discord --noconfirm
    #*Improving performance*
    #*Manjaro settings*
    #*Security*
    #*Optional dependencies*
    #*Screen capture*
    #*Video calling*
    #https://github.com/AryToNeX/Glasscord
    #https://github.com/Lightcord/Lightcord
    #https://unix.stackexchange.com/questions/53080/list-optional-dependencies-with-pacman-on-arch-linux
    #https://github.com/hakavlad/nohang
    #https://wiki.archlinux.org/index.php/Zswap
    #https://github.com/Nefelim4ag/Ananicy
}

clean_up ()
{
    cd ../
    rm -r ArchConfigs
    reboot
}

pre_checks
packagemanager
update
xorg
login
plymouth
windowmanager
terminal

#*System configs*
#*Script performance*
#https://wiki.archlinux.org/index.php/Dash
#https://wiki.archlinux.org/index.php/Dotfiles
#https://wiki.archlinux.org/index.php/General_recommendations
