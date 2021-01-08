#!/bin/sh

pre_checks ()
{
    if [ "$(whoami)" != "root" ]; then
        echo "Script must be run as user: root"
        exit 255
    fi
    USER="$(ls /home)"
    su $USER -c "git clone https://github.com/EmperorPenguin18/diamond-dotfiles /home/$USER/dotfiles"
    cd /home/$USER/dotfiles
    DIR="$(pwd)"
    pacman -Sy unzip --noconfirm --needed
    TIME="$(ls -l /etc/localtime | sed 's|.*zoneinfo/||')"
}

packagemanager ()
{
    cp -f $DIR/packagemanager/pacman.conf /etc/pacman.conf
    echo "#This system uses doas instead of sudo" > /etc/doas.conf
    echo "permit persist $USER" >> /etc/doas.conf
    echo "permit nopass /usr/bin/pacman" >> /etc/doas.conf
    echo "permit nopass /usr/bin/pikaur" >> /etc/doas.conf
    echo "permit nopass /usr/bin/makepkg" >> /etc/doas.conf
    sed -i '/MAKEFLAGS.*/c\MAKEFLAGS="-j$(nproc)"' /etc/makepkg.conf
    pacman -Sy autoconf automake bison flex groff m4 pkgconf pyalpm python-commonmark --noconfirm --needed
    su $USER -c "git clone https://aur.archlinux.org/pikaur.git"
    cd pikaur
    su $USER -c "makepkg --noconfirm"
    pacman -U *.pkg* --noconfirm --needed
    cd ../
    rm -r pikaur
}

cloud ()
{
    pacman -S fuse rclone --noconfirm --needed
    echo "user_allow_other" >> /etc/fuse.conf
    mkdir -p /home/$USER/.config/rclone
    cp -f $DIR/cloud/rclone.conf /home/$USER/.config/rclone/rclone.conf
    chown $USER:$USER /home/$USER/.config/rclone/rclone.conf
    cp -f $DIR/cloud/rclone1.service /etc/systemd/system/rclone1.service
    cp -f $DIR/cloud/rclone2.service /etc/systemd/system/rclone2.service
    cp -f $DIR/cloud/rclone3.service /etc/systemd/system/rclone3.service
    mkdir /mnt/Personal
    mkdir /mnt/School
    mkdir /mnt/Media
    systemctl enable rclone1
    systemctl enable rclone2
    systemctl enable rclone3
}

update ()
{
    pacman -S cron reflector --noconfirm --needed
    cp -f $DIR/update/update.sh /home/$USER/update.sh
    cp -f $DIR/update/backup.sh /home/$USER/backup.sh
    #echo "0 3 * * 1 root /home/$USER/backup.sh" >> /etc/crontab
    #echo "0 4 * * 1 $USER /home/$USER/update.sh" >> /etc/crontab
    reflector --country $(curl -sL https://raw.github.com/eggert/tz/master/zone1970.tab | grep $TIME | awk '{print $1}') --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    #*Other system maintenance?*
}

xorg ()
{
    pacman -S xorg xorg-drivers lib32-mesa lib32-vulkan-icd-loader vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau vulkan-radeon lib32-vulkan-radeon amdvlk lib32-amdvlk --noconfirm --needed
    #*Enable vsync, freesync/gsync, hardware acceleration, vulkan etc
    #mv xorg/10-monitor.conf /etc/X11/xorg.conf.d/10-monitor.conf
    #*Multi-monitor*
}

nvidia ()
{
    pacman -S nvidia-prime --noconfirm --needed
    #*prime-run*
}

login ()
{
    #pikaur -S lightdm lightdm-webkit2-greeter lightdm-webkit2-theme-glorious --noconfirm
    pacman -S lxdm-gtk3 --noconfirm --needed
    #mv login/lightdm.conf /etc/lightdm/lightdm.conf
    #mv login/lightdm-webkit2-greeter.conf /etc/lightdm/lightdm-webkit2-greeter.conf
    #mv login/index.html /usr/share/lightdm-webkit/themes/glorious/
    #rm -r /usr/share/backgrounds/*
    #mv login/background.png /usr/share/backgrounds/
    mkdir -p /usr/share/xsessions
    cp -f $DIR/login/steam-big-picture.desktop /usr/share/xsessions/steam-big-picture.desktop
    cp -f $DIR/login/jellyfin.desktop /usr/share/xsessions/jellyfin.desktop
    cp -f $DIR/login/alacritty.desktop /usr/share/xsessions/alacritty.desktop
    chmod +x /usr/share/xsessions/*
    #systemctl enable lightdm
    systemctl enable lxdm
    #*Theme*
    #*Sessions*
    #*On-screen keyboard*
    #*http://www.mattfischer.com/blog/archives/5*
}

plymouth ()
{
    pikaur -S plymouth --noconfirm --needed
    sed -i '4d' /etc/mkinitcpio.conf
    echo "HOOKS=(base udev plymouth plymouth-encrypt autodetect modconf block filesystems keyboard fsck)" >> /etc/mkinitcpio.conf
    cp -f $DIR/plymouth/grub /etc/default/grub
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
    pacman -S spectrwm feh picom rofi unclutter --noconfirm --needed #all-repository-fonts
    cp -f $DIR/windowmanager/spectrwm.conf /home/$USER/.spectrwm.conf
    cp -f $DIR/windowmanager/wallpaper.jpg /home/$USER/wallpaper.jpg
    cp -f $DIR/windowmanager/picom.conf /home/$USER/.config/picom.conf
    #git clone https://github.com/EmperorPenguin18/SkyrimCursor
    #mkdir -p /home/$USER/.local/share/icons/skyrim/cursor
    #cp SkyrimCursor/Small/Linux/x11/* /home/$USER/.local/share/icons/skyrim/cursor/
    #rm -r SkyrimCursor
    unzip $DIR/windowmanager/DTM.ZIP -d /usr/share/fonts/
    chmod 0444 /usr/share/fonts/DTM-Mono.otf
    chmod 0444 /usr/share/fonts/DTM-Sans.otf
    fc-cache
    mkdir /home/$USER/.config/rofi
    cp -f $DIR/windowmanager/config.rasi /home/$USER/.config/rofi/config.rasi
    cd windowmanager
    ls *.rasi | xargs -L1 -i{} cp -f $DIR/windowmanager/{} /usr/share/rofi/themes/{}
    ls rofi-*.sh | xargs -L1 -i{} cp -f $DIR/windowmanager/{} /home/$USER/{}
    cd ../
    chmod +x /home/$USER/rofi-*.sh
    #https://github.com/seebye/ueberzug
    #https://manpages.debian.org/testing/rofi/rofi-theme.5.en.html
    #https://github.com/adi1090x/rofi
    #https://www.youtube.com/watch?v=kw2mnwhptjw&ab_channel=meribold
}

terminal ()
{
    pacman -S alacritty mlocate lsd pkgfile neovim parted openssh --noconfirm --needed
    mkdir -p /home/$USER/.config/alacritty
    cp -f $DIR/terminal/alacritty.yml /home/$USER/.config/alacritty/alacritty.yml
    mkdir -p /home/$USER/.config/fish
    cp -f $DIR/terminal/config.fish /home/$USER/.config/fish/config.fish
    cp -f $DIR/terminal/fish_variables /home/$USER/.config/fish/fish_variables
    rm /home/$USER/.bash*
    updatedb
    systemctl enable pkgfile-update.timer
    mkdir -p /home/$USER/.config/nvim
    cp -f $DIR/terminal/init.vim /home/$USER/.config/nvim/init.vim
    #*Help command (for terminal utilities)*
    #*Fetch*
}

filemanager ()
{
    pacman -S pcmanfm-gtk3 gvfs arc-gtk-theme mtools exfatprogs e2fsprogs ntfs-3g xfsprogs mpv --noconfirm --needed #hfsprogs apfsprogs-git onlyoffice-bin
    cp -f $DIR/filemanager/settings.ini /etc/gtk-3.0/settings.ini
    mkdir -p /home/$USER/.config/mpv
    cp -f $DIR/filemanager/mpv.conf /home/$USER/.config/mpv/mpv.conf
    cp -f $DIR/filemanager/input.conf /home/$USER/.config/mpv/input.conf
    #https://github.com/deviantfero/wpgtk
    #https://github.com/Misterio77/flavours
    #*mpv addons / MPRIS*
    #*mpv OSC*
}

audio ()
{
    pacman -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth lib32-libpulse lib32-alsa-plugins spotifyd dunst --noconfirm --needed #alsa-utils
    mkdir -p /home/$USER/.config/dunst
    cp -f $DIR/audio/dunstrc /home/$USER/.config/dunst/dunstrc
    #https://github.com/Spotifyd/spotifyd
}

browser ()
{
    pacman -S firefox --noconfirm --needed
    mkdir -p /home/$USER/.mozilla/firefox/default
    unzip $DIR/browser/profile.zip -d /home/$USER/.mozilla/firefox/default/
    cp -f $DIR/browser/profiles.ini /home/$USER/.mozilla/firefox/profiles.ini
    #*Hardware acceleration*
    #https://github.com/akshat46/FlyingFox
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
    chown -R $USER:$USER /home/$USER
}

pre_checks
packagemanager
update
xorg
login
windowmanager
terminal
filemanager
audio
browser
clean_up
echo "-------------------------------------------------"
echo "          All done! You can reboot now.          "
echo "-------------------------------------------------"

#*System configs*
#*Script performance*
#https://wiki.archlinux.org/index.php/Dash
#https://wiki.archlinux.org/index.php/Dotfiles
#https://wiki.archlinux.org/index.php/General_recommendations
