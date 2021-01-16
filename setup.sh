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
    pacman -Sy unzip dialog --noconfirm --needed
    TIME="$(ls -l /etc/localtime | sed 's|.*zoneinfo/||')"
    timedatectl set-timezone $TIME
    hwclock --systohc
}

user_prompts ()
{
    VIDEO=$(dialog --stdout --checklist "What video drivers do you need?" 0 0 0 intel "" off amd "" off nvidia "" off | sed 's/ /\n/g')
    if dialog --yesno "Will this device be used for gaming?" 0 0; then
        GAMING=y
    else
        GAMING=n
    fi
    if dialog --default-button "no" --yesno "Is this device a laptop?" 0 0; then
        LAPTOP=y
    else
        LAPTOP=y
    fi
    if dialog --yesno "Will this device be used for virtualization?" 0 0; then
        VIRTUALIZATION=y
    else
        VIRTUALIZATION=y
    fi
    MULLVAD=$(dialog --stdout --inputbox "What is your Mullvad VPN account number?" 0 0)
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
    pacman -Sy autoconf automake bison flex groff m4 pkgconf pyalpm python-commonmark make --noconfirm --needed
    su $USER -c "git clone https://aur.archlinux.org/pikaur.git"
    cd pikaur
    su $USER -c "makepkg --noconfirm"
    pacman -U *.pkg* --noconfirm --needed
    cd ../
    rm -r pikaur
}

#cloud ()
#{
    #pacman -S fuse rclone --noconfirm --needed
    #echo "user_allow_other" >> /etc/fuse.conf
    #mkdir -p /home/$USER/.config/rclone
    #cp -f $DIR/cloud/rclone.conf /home/$USER/.config/rclone/rclone.conf
    #chown $USER:$USER /home/$USER/.config/rclone/rclone.conf
    #cp -f $DIR/cloud/rclone1.service /etc/systemd/system/rclone1.service
    #cp -f $DIR/cloud/rclone2.service /etc/systemd/system/rclone2.service
    #cp -f $DIR/cloud/rclone3.service /etc/systemd/system/rclone3.service
    #mkdir /mnt/Personal
    #mkdir /mnt/School
    #mkdir /mnt/Media
    #systemctl enable rclone1
    #systemctl enable rclone2
    #systemctl enable rclone3
#}

update ()
{
    pacman -S cron reflector --noconfirm --needed
    #cp -f $DIR/update/update.sh /home/$USER/.config/scripts/update
    #chmod +x /home/$USER/.config/scripts/update
    cp -f $DIR/update/backup.sh /home/$USER/.config/scripts/backup
    chmod +x /home/$USER/.config/scripts/backup
    echo "0 3 * * 1 root /home/$USER/.config/scripts/backup" >> /etc/crontab
    #echo "0 4 * * 1 $USER /home/$USER/update.sh" >> /etc/crontab
    reflector --country $(curl -sL https://raw.github.com/eggert/tz/master/zone1970.tab | grep $TIME | awk '{print $1}') --protocol https --sort rate --save /etc/pacman.d/mirrorlist
}

xorg ()
{
    pacman -S xorg xorg-drivers lib32-mesa lib32-vulkan-icd-loader libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau --noconfirm --needed
    [ "$(echo $VIDEO | grep 'intel' | wc -l)" -gt 0 ] && pacman -S vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver --noconfirm --needed
    [ "$(echo $VIDEO | grep 'amd' | wc -l)" -gt 0 ] && pacman -S vulkan-radeon lib32-vulkan-radeon amdvlk lib32-amdvlk --noconfirm --needed
    [ "$(echo $VIDEO | grep 'nvidia' | wc -l)" -gt 0 ] && pacman -S nvidia-dkms lib32-nvidia-utils nvidia-prime --noconfirm --needed
    #*Enable vsync + freesync/gsync*
    #*Multi-monitor*
}

login ()
{
    pacman -S lightdm lightdm-gtk-greeter --noconfirm --needed
    cp -f $DIR/login/lightdm.conf /etc/lightdm/lightdm.conf
    sed -i "s/USER/$USER/g" /etc/lightdm/lightdm.conf
    cp -f $DIR/login/displaysetup.sh /home/$USER/.config/scripts/displaysetup
    chmod +x /home/$USER/.config/scripts/displaysetup
    cp -f $DIR/login/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
    sed -i "s/USER/$USER/g" /etc/lightdm/lightdm-gtk-greeter.conf
    cp -f $DIR/login/background.png /home/$USER/.config/background.png
    mkdir -p /usr/share/xsessions
    cp -f $DIR/login/steam-big-picture.desktop /usr/share/xsessions/steam-big-picture.desktop
    cp -f $DIR/login/jellyfin.desktop /usr/share/xsessions/jellyfin.desktop
    cp -f $DIR/login/alacritty.desktop /usr/share/xsessions/alacritty.desktop
    systemctl enable lightdm
    cp -f $DIR/login/grub /etc/default/grub
    sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(blkid -o device | xargs -L1 cryptsetup luksUUID):cryptroot\"/g" /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    #*Sessions*
    #*On-screen keyboard*
}

windowmanager ()
{
    pacman -S spectrwm feh picom xscreensaver rofi xdotool unclutter --noconfirm --needed #all-repository-fonts
    cp -f $DIR/windowmanager/spectrwm.conf /home/$USER/.spectrwm.conf
    sed -i "s/USER/$USER/g" /home/$USER/.spectrwm.conf
    cp -f $DIR/windowmanager/screenshot.sh /home/$USER/.config/scripts/screenshot
    chmod +x /home/$USER/.config/scripts/screenshot
    cp -f $DIR/windowmanager/wallpaper.jpg /home/$USER/.config/wallpaper.jpg
    cp -f $DIR/windowmanager/picom.conf /home/$USER/.config/picom.conf
    cp -f $DIR/windowmanager/xscreensaver /home/$USER/.xscreensaver
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
    cp -f $DIR/windowmanager/*.rasi /usr/share/rofi/themes/
    cp -f $DIR/windowmanager/rofi-* /home/$USER/.config/scripts/
    cd ../
    chmod +x /home/$USER/rofi-*
    #https://github.com/seebye/ueberzug
    #https://manpages.debian.org/testing/rofi/rofi-theme.5.en.html
    #https://github.com/adi1090x/rofi
    #https://www.youtube.com/watch?v=kw2mnwhptjw&ab_channel=meribold
}

terminal ()
{
    pacman -S alacritty wget mlocate lsd pkgfile neovim parted openssh bashtop --noconfirm --needed
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
    pikaur -S pcmanfm-gtk3 gvfs arc-gtk-theme hicolor-icon-theme arc-icon-theme moka-icon-theme-git lxsession-gtk3 mtools exfatprogs e2fsprogs ntfs-3g xfsprogs mpv --noconfirm --needed #hfsprogs apfsprogs-git onlyoffice-bin
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
    pacman -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth lib32-libpulse lib32-alsa-plugins spotifyd dunst --noconfirm --needed
    pactl set-sink-mute 0 false
    pactl set-sink-volume 0 100%
    cp -f $DIR/audio/audiocontrol.sh /home/$USER/.config/scripts/audiocontrol
    chmod +x /home/$USER/.config/scripts/audiocontrol
    mkdir -p /home/$USER/.config/dunst
    cp -f $DIR/audio/dunstrc /home/$USER/.config/dunst/dunstrc
    #Mic
    #https://github.com/Spotifyd/spotifyd
}

browser ()
{
    pacman -S firefox --noconfirm --needed
    mkdir -p /home/$USER/.mozilla/firefox
    firefox -headless &
    killall firefox
    unzip -o $DIR/browser/profile.zip -d /home/$USER/.mozilla/firefox/"$(ls /home/$USER/.mozilla/firefox | grep default-release)"/
    #*Bookmarks*
    #*Passwords*
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
    pikaur -S freetube discord mullvad-vpn-cli --noconfirm
    mullvad account set $MULLVAD
    #https://wiki.archlinux.org/index.php/Improving_performance
    #*Manjaro settings*
    #*Security*
    #*Optional dependencies*
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
user_prompts
packagemanager
#cloud
update
xorg
login
windowmanager
terminal
filemanager
audio
browser
#[ "${GAMING}" = "y" ] && gaming
#[ "${LAPTOP}" = "y" ] && power
#[ "${VIRTUALIZATION}" = "y" ] && virtualization
#other
clean_up
echo "-------------------------------------------------"
echo "          All done! You can reboot now.          "
echo "-------------------------------------------------"

#*System configs*
#*Script performance*
#https://wiki.archlinux.org/index.php/Dash
#https://wiki.archlinux.org/index.php/Dotfiles
#https://wiki.archlinux.org/index.php/General_recommendations
