#!/bin/sh

insert_binding ()
{
    NUM="$(grep -n 'keyboard_mapping' /home/$USER/.spectrwm.conf | cut -f 1 -d ':')"
    NUM="$(expr $NUM - 2)"
    sed -i "$NUM a program[$1] = $2" /home/$USER/.spectrwm.conf
    NUM="$(grep -n 'QUIRKS' /home/$USER/.spectrwm.conf | cut -f 1 -d ':')"
    NUM="$(expr $NUM - 2)"
    sed -i "$NUM a bind[$1] = $3 #$4" /home/$USER/.spectrwm.conf
}

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
    pacman -Sy dialog --noconfirm --needed
    TIME="$(ls -l /etc/localtime | sed 's|.*zoneinfo/||')"
    timedatectl set-timezone $TIME
    hwclock --systohc
    mkdir -p /home/$USER/.config/scripts
    return 0
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
    SNAME=$(dialog --stdout --inputbox "What is your Spotify username?" 0 0)
    SPASS=$(dialog --stdout --passwordbox "What is your Spotify password?" 0 0)
    return 0
}

packagemanager ()
{
    cp -f $DIR/packagemanager/pacman.conf /etc/pacman.conf
    echo "#This system uses doas instead of sudo" > /etc/doas.conf
    echo "permit persist $USER" >> /etc/doas.conf
    echo "permit nopass $USER cmd pacman" >> /etc/doas.conf
    echo "permit nopass $USER cmd pikaur" >> /etc/doas.conf
    echo "permit nopass $USER cmd makepkg" >> /etc/doas.conf
    sed -i '/MAKEFLAGS.*/c\MAKEFLAGS="-j$(nproc)"' /etc/makepkg.conf
    pacman -Sy autoconf automake bison flex groff m4 pkgconf pyalpm python-commonmark make patch gcc --noconfirm --needed
    su $USER -c "git clone https://aur.archlinux.org/pikaur.git"
    cd pikaur
    su $USER -c "makepkg --noconfirm"
    pacman -U *.pkg* --noconfirm --needed
    cd ../
    rm -r pikaur
    return 0
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
    #return 0
#}

update ()
{
    pacman -S cron reflector --noconfirm --needed
    cp -f $DIR/update/update.sh /home/$USER/.config/scripts/update
    cp -f $DIR/update/backup.sh /home/$USER/.config/scripts/backup
    echo "0 3 * * 1 root /home/$USER/.config/scripts/backup" >> /etc/crontab
    echo "0 4 * * 1 $USER /home/$USER/update.sh" >> /etc/crontab
    reflector --country $(curl -sL https://raw.github.com/eggert/tz/master/zone1970.tab | grep $TIME | awk '{print $1}') --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    return 0
}

video ()
{
    pacman -S mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau --noconfirm --needed
    [ "$(echo $VIDEO | grep 'intel' | wc -l)" -gt 0 ] && pacman -S xf86-video-intel vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver --noconfirm --needed
    [ "$(echo $VIDEO | grep 'amd' | wc -l)" -gt 0 ] && pacman -S xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon --noconfirm --needed
    [ "$(echo $VIDEO | grep 'nvidia' | wc -l)" -gt 0 ] && pacman -S nvidia-dkms lib32-nvidia-utils nvidia-prime --noconfirm --needed
    [ "$(echo $VIDEO | grep 'intel' | wc -l)" -gt 0 ] && [ "$(echo $VIDEO | grep 'nvidia' | wc -l)" -gt 0 ] && pikaur -S optimus-manager && cp -f $DIR/xorg/optimus-manager.conf /etc/optimus-manager/optimus-manager.conf
    return 0
    #*Enable vsync + freesync/gsync*
    #*https://wiki.archlinux.org/index.php/NVIDIA#DRM_kernel_mode_setting*
    #https://github.com/Askannz/optimus-manager/wiki/A-guide--to-power-management-options
}

login ()
{
    pacman -S lightdm lightdm-gtk-greeter --noconfirm --needed
    cp -f $DIR/login/lightdm.conf /etc/lightdm/lightdm.conf
    sed -i "s/USER/$USER/g" /etc/lightdm/lightdm.conf
    cp -f $DIR/login/displaysetup.sh /home/$USER/.config/scripts/displaysetup
    cp -f $DIR/login/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
    sed -i "s/USER/$USER/g" /etc/lightdm/lightdm-gtk-greeter.conf
    cp -f $DIR/login/background.png /home/$USER/.config/background.png
    mkdir -p /usr/share/xsessions
    #cp -f $DIR/login/steam-big-picture.desktop /usr/share/xsessions/steam-big-picture.desktop
    #cp -f $DIR/login/jellyfin.desktop /usr/share/xsessions/jellyfin.desktop
    cp -f $DIR/login/alacritty.desktop /usr/share/xsessions/alacritty.desktop
    systemctl enable lightdm
    cp -f $DIR/login/grub /etc/default/grub
    UUID="$(blkid -o device | xargs -L1 cryptsetup luksUUID | grep -v WARNING)"
    sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(echo $UUID):cryptroot\"/g" /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    return 0
}

xorg ()
{
    pikaur -S xorg xscreensaver xdotool xclip picom all-repository-fonts --noconfirm --needed
    cp -f $DIR/xorg/xscreensaver /home/$USER/.xscreensaver
    cp -f $DIR/xorg/picom.conf /home/$USER/.config/picom.conf
    git clone https://github.com/EmperorPenguin18/SkyrimCursor
    mkdir -p /home/$USER/.local/share/icons/skyrim/cursors
    cp SkyrimCursor/Small/Linux/x11/* /home/$USER/.local/share/icons/skyrim/cursors/
    rm -r SkyrimCursor
    mkdir -p /home/$USER/.icons/default
    echo "[icon theme]" > /home/$USER/.icons/default/index.theme
    echo "Inherits=skyrim" >> /home/$USER/.icons/default/index.theme
    return 0
    #xset s off -dpms
}

windowmanager ()
{
    pacman -S spectrwm feh rofi unclutter --noconfirm --needed
    cp -f $DIR/windowmanager/spectrwm.conf /home/$USER/.spectrwm.conf
    sed -i "s/USER/$USER/g" /home/$USER/.spectrwm.conf
    cp -f $DIR/windowmanager/screenshot.sh /home/$USER/.config/scripts/screenshot
    cp -f $DIR/windowmanager/monitor.sh /home/$USER/.config/scripts/monitor
    cp -f $DIR/windowmanager/wallpaper.jpg /home/$USER/.config/wallpaper.jpg
    cp -f $DIR/windowmanager/DTM-Mono.otf /usr/share/fonts/DTM-Mono.otf
    cp -f $DIR/windowmanager/DTM-Sans.otf /usr/share/fonts/DTM-Sans.otf
    chmod 0444 /usr/share/fonts/DTM-Mono.otf
    chmod 0444 /usr/share/fonts/DTM-Sans.otf
    fc-cache
    mkdir /home/$USER/.config/rofi
    cp -f $DIR/windowmanager/config.rasi /home/$USER/.config/rofi/config.rasi
    cp -f $DIR/windowmanager/*.rasi /usr/share/rofi/themes/
    cp -f $DIR/windowmanager/rofi-* /home/$USER/.config/scripts/
    return 0
    #https://github.com/seebye/ueberzug
    #https://manpages.debian.org/testing/rofi/rofi-theme.5.en.html
    #https://github.com/adi1090x/rofi
    #https://www.youtube.com/watch?v=kw2mnwhptjw&ab_channel=meribold
}

terminal ()
{
    pacman -S alacritty wget mlocate lsd pkgfile neovim parted openssh unzip zip unrar speedtest-cli --noconfirm --needed
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
    return 0
    #*Help command (for terminal utilities)*
    #*Fetch*
}

filemanager ()
{
    pikaur -S pcmanfm-gtk3 gvfs arc-gtk-theme hicolor-icon-theme arc-icon-theme moka-icon-theme-git lxsession-gtk3 mtools exfatprogs e2fsprogs ntfs-3g xfsprogs mpv mpv-mpris libreoffice-fresh --noconfirm --needed #hfsprogs apfsprogs-git
    cp -f $DIR/filemanager/settings.ini /etc/gtk-3.0/settings.ini
    mkdir -p /home/$USER/.config/mpv
    cp -f $DIR/filemanager/mpv.conf /home/$USER/.config/mpv/mpv.conf
    cp -f $DIR/filemanager/input.conf /home/$USER/.config/mpv/input.conf
    return 0
    #https://github.com/deviantfero/wpgtk
    #https://github.com/Misterio77/flavours
    #*mpv OSC*
}

audio ()
{
    pacman -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth lib32-libpulse lib32-alsa-plugins spotifyd playerctl dunst --noconfirm --needed
    mkdir -p /home/$USER/.config/pulse
    cp -f $DIR/audio/default.pa /home/$USER/.config/pulse/default.pa
    cp -f $DIR/audio/audiocontrol.sh /home/$USER/.config/scripts/audiocontrol
    mkdir -p /home/$USER/.config/spotifyd
    cp -f $DIR/audio/spotifyd.conf /home/$USER/.config/spotifyd/spotifyd.conf
    sed -i "s/USER/$USER/g" /home/$USER/.config/spotifyd/spotifyd.conf
    sed -i "s/SNAME/$SNAME/g" /home/$USER/.config/spotifyd/spotifyd.conf
    sed -i "s/SPASS/$SPASS/g" /home/$USER/.config/spotifyd/spotifyd.conf
    cp /usr/lib/systemd/user/spotifyd.service /etc/systemd/user/
    su $USER -c "systemctl --user enable spotifyd.service"
    mkdir -p /home/$USER/.config/dunst
    cp -f $DIR/audio/dunstrc /home/$USER/.config/dunst/dunstrc
    echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    return 0
    #*Playlist*
}

browser ()
{
    pacman -S firefox pass pass-otp --noconfirm --needed
    mkdir -p /home/$USER/.mozilla/firefox
    firefox -headless &
    killall firefox
    PROFILE="$(ls /home/$USER/.mozilla/firefox | grep default-release)"
    cp -f $DIR/browser/prefs.js /home/$USER/.mozilla/firefox/$PROFILE/prefs.js
    mkdir -p /home/$USER/.mozilla/firefox/$PROFILE/extensions
    cp -f $DIR/browser/*.xpi /home/$USER/.mozilla/firefox/$PROFILE/extensions/
    cp -f $DIR/browser/homepage.html /home/$USER/.config/homepage.html
    sed -i "s/USER/$USER/g" /home/$USER/.config/homepage.html
    sed -i 's/dmenu/rofi -theme center -dmenu -p Passwords -i/g' /usr/bin/passmenu
    return 0
    #*Passwords*
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
    #https://github.com/lucasassislar/nucleuscoop/
    #https://wiki.archlinux.org/index.php/List_of_games
    #https://github.com/dreamer
#}

power ()
{
    pacman -S tlp acpid --noconfirm --needed
    cp -f $DIR/power/brightnesscontrol.sh /home/$USER/.config/scripts/brightnesscontrol
    insert_binding brightup "/home/$USER/.config/scripts/brightnesscontrol up" XF86MonBrightnessUp 'Increase brightness'
    insert_binding brightdown "/home/$USER/.config/scripts/brightnesscontrol down" XF86MonBrightnessDown 'Decrease brightness'
    #https://wiki.archlinux.org/index.php/Backlight
    systemctl enable tlp
    systemctl enable NetworkManager-dispatcher
    systemctl mask systemd-rfkill.service
    systemctl mask systemd-rfkill.socket
    cp -f $DIR/power/tlp.conf /etc/tlp.conf
    #https://wiki.archlinux.org/index.php/TLP
    systemctl enable acpid
    #https://wiki.archlinux.org/index.php/CPU_frequency_scaling / AUTO_CPUFREQ
    #*Auto-hibernate*
    #*powertop*
    #*Mute LED*
}

virtualization ()
{
    pacman -S qemu qemu-arch-extra libvirt ebtables dnsmasq virt-manager libguestfs edk2-ovmf dmidecode --noconfirm --needed
    systemctl enable libvirtd
    insert_binding virtual virt-manager MOD+m 'Open Virtual Machine Manager'
    return 0
    #https://github.com/Fmstrat/winapps
}

other ()
{
    gpg --recv-key 78CEAA8CB72E4467
    gpg --recv-key AEE9DECFD582E984
    pikaur -S freetube discord mullvad-vpn-cli networkmanager-openvpn --noconfirm
    systemctl start mullvad-daemon
    mullvad account set $MULLVAD
    mullvad auto-connect set on
    mullvad lan set allow
    mullvad relay set tunnel-protocol openvpn
    return 0
    #https://wiki.archlinux.org/index.php/Improving_performance
    #*Manjaro settings*
    #*Security*
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
    chmod +x /home/$USER/.config/scripts/*
    chown -R $USER:$USER /home/$USER
    return 0
}

pre_checks
user_prompts
packagemanager
#cloud
update
video
login
xorg
windowmanager
terminal
filemanager
audio
browser
#[ "${GAMING}" = "y" ] && gaming
[ "${LAPTOP}" = "y" ] && power
[ "${VIRTUALIZATION}" = "y" ] && virtualization
other
clean_up
echo "-------------------------------------------------"
echo "          All done! You can reboot now.          "
echo "-------------------------------------------------"

#*System configs*
#*Script performance*
#*Unify passwords*
#https://wiki.archlinux.org/index.php/Dash
#https://wiki.archlinux.org/index.php/Dotfiles
#https://wiki.archlinux.org/index.php/General_recommendations
