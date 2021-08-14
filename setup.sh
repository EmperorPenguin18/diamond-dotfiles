#!/bin/sh

install_repo ()
{
    pacman -Sy "$@" --noconfirm --needed || return 1
    return 0
}
install_aur ()
{
    pikaur -Sy "$@" --noconfirm --needed --mflags=--skippgpcheck || return 1
    return 0
}
install_git ()
{
    for I in $@
    do
        su $USER -c "git clone $I newgitpackage" && \
        cd newgitpackage && \
        sed -i "s/depends=('vim')//g" PKGBUILD && \
        su $USER -c "makepkg --noconfirm" && \
        pacman -U *.pkg* --noconfirm --needed && \
        cd ../ && \
        rm -r newgitpackage || \
        return 1
    done
    return 0
}

service ()
{
    systemctl $@ || return 1
    return 0
}

dotfile ()
{
    NUM=$(echo "$1" | grep -o '/' | wc -l)
    DIR=$(echo "$1" | cut -f -$NUM -d '/')
    FILE=$(echo "$1" | cut -f $(expr $NUM + 1) -d '/')
    NUM=$(echo "$2" | grep -o '/' | wc -l)
    DEST=$(echo "$2" | cut -f -$NUM -d '/')
    RENAME=$(echo "$2" | cut -f $(expr $NUM + 1) -d '/')
    echo "$2" | grep -o '/' > /dev/null && mkdir -p $DEST
    cd "$DIR"
    for I in $(find . -type f -name "$FILE"); do
        [ -z "$RENAME" ] || I="$RENAME"
        cp -f $SRC/"$DIR"/"$I" "$DEST"/"$I"
        if file -i "$DEST"/"$I" | grep shellscript; then
            chmod +x "$DEST"/"$I"
        elif file "$DEST"/"$I" | grep font; then
            chmod 0444 "$DEST"/"$I"
        else
            sed -i "s/USER/$USER/g" "$DEST"/"$I"
        fi
    done
    [ "$2" = "/etc/default/grub" ] || [ "$2" = "/home/$USER/.config/spotifyd/spotifyd.conf" ] || \
        echo "$1","$2" >> /home/$USER/.config/files.csv
    cd $SRC
}

pre_checks ()
{
    if [ "$(whoami)" != "root" ]; then
        echo "Script must be run as user: root"
        exit 255
    fi
    USER="$(ls /home)" && \
    su $USER -c "git clone https://github.com/EmperorPenguin18/diamond-dotfiles /home/$USER/dotfiles" && \
    cd /home/$USER/dotfiles && \
    SRC="$(pwd)" && \
    install_repo dialog && \
    TIME="$(ls -l /etc/localtime | sed 's|.*zoneinfo/||')" || \
    return 1
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
    dotfile 'packagemanager/pacman.conf' '/etc/pacman.conf' && \
    dotfile 'packagemanager/doas.conf' '/etc/doas.conf' && \
    dotfile 'packagemanager/nvidia.hook' '/etc/pacman.d/hooks/nvidia.hook' && \
    sed -i '/MAKEFLAGS.*/c\MAKEFLAGS="-j$(nproc)"' /etc/makepkg.conf && \
    install_repo autoconf automake bison flex groff m4 pkgconf pyalpm python-commonmark make patch gcc && \
    install_git "https://aur.archlinux.org/pikaur.git" || \
    return 1
    return 0
}

cloud ()
{
    install_repo fuse rclone && \
    dotfile 'cloud/fuse.conf' '/etc/fuse.conf' && \
    dotfile 'cloud/rclonewrapper.sh' "/home/$USER/.config/scripts/rclonewrapper" && \
    dotfile 'cloud/80-netperf.conf' '/etc/sysctl.d/80-netperf.conf' || \
    return 1
    return 0
    #https://github.com/jstaf/onedriver
}

update ()
{
    install_repo cronie reflector && \
    dotfile 'update/backup.sh' "/home/$USER/.config/scripts/backup" && \
    dotfile 'update/update.sh' "/home/$USER/.config/scripts/update" && \
    dotfile 'update/crontab' '/etc/crontab' && \
    service enable cronie && \
    reflector --country $(curl -sL https://raw.github.com/eggert/tz/master/zone1970.tab | grep $TIME | awk '{print $1}') --protocol https --sort rate --save /etc/pacman.d/mirrorlist || \
    return 1
    return 0
}

video ()
{
    install_repo mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau || return 1
    [ "$(echo $VIDEO | grep 'intel' | wc -l)" -gt 0 ] && install_repo xf86-video-intel vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver lib32-libva-intel-driver || return 1
    [ "$(echo $VIDEO | grep 'amd' | wc -l)" -gt 0 ] && install_repo xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon || return 1
    [ "$(echo $VIDEO | grep 'nvidia' | wc -l)" -gt 0 ] && install_repo nvidia-dkms lib32-nvidia-utils nvidia-prime && sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/g' /etc/mkinitcpio.conf || return 1
    return 0
    #*Enable vsync + freesync/gsync*
    #https://wiki.archlinux.org/index.php/PRIME#PRIME_synchronization
}

login ()
{
    install_repo lightdm lightdm-gtk-greeter && \
    dotfile 'login/lightdm.conf' '/etc/lightdm/lightdm.conf' && \
    dotfile 'login/displaysetup.sh' "/home/$USER/.config/scripts/displaysetup" && \
    dotfile 'login/lightdm-gtk-greeter.conf' '/etc/lightdm/lightdm-gtk-greeter.conf' && \
    dotfile 'login/background.png' "/home/$USER/.config/background.png" && \
    dotfile 'login/alacritty.desktop' '/usr/share/xsessions/alacritty.desktop' && \
    dotfile 'login/xinitrc.desktop' '/usr/share/xsessions/xinitrc.desktop' && \
    dotfile 'login/xinitrc' "/home/$USER/.xinitrc" && \
    rm /usr/share/xsessions/spectrwm.desktop && \
    service enable lightdm && \
    dotfile 'login/grub' '/etc/default/grub' && \
    UUID="$(blkid -o device | xargs -L1 cryptsetup luksUUID | grep -v WARNING)" && \
    SWAP="$(blkid | grep swap | cut -f 2 -d '"')" && \
    sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(echo $UUID):cryptroot resume=UUID=$(echo $SWAP)\"/g" /etc/default/grub && \
    dotfile 'login/95-monitor-hotplug.rules' '/etc/udev/rules.d/95-monitor-hotplug.rules' && \
    dotfile 'login/hotplug.sh' "/home/$USER/.config/scripts/hotplug" && \
    dotfile 'login/watchdog.conf' '/etc/modprobe.d/watchdog.conf' || \
    return 1
    return 0
}

xorg ()
{
    install_repo xorg xdotool xclip && \
    install_aur picom-git && \
    dotfile 'xorg/picom.conf' "/home/$USER/.config/picom.conf" || \
    return 1
    return 0
}

windowmanager ()
{
    install_repo spectrwm sxhkd wmctrl rofi unclutter dunst && \
    install_git "https://github.com/EmperorPenguin18/gobble" && \
    dotfile 'windowmanager/spectrwm.conf' "/home/$USER/.spectrwm.conf" && \
    dotfile 'windowmanager/sxhkdrc' "/home/$USER/.config/sxhkd/sxhkdrc" && \
    dotfile 'windowmanager/screenshot.sh' "/home/$USER/.config/scripts/screenshot" && \
    dotfile 'windowmanager/monitor.sh' "/home/$USER/.config/scripts/monitor" && \
    dotfile 'windowmanager/ws.sh' "/home/$USER/.config/scripts/ws" && \
    dotfile 'windowmanager/config.rasi' "/home/$USER/.config/rofi/config.rasi" && \
    dotfile 'windowmanager/rofi-*' "/home/$USER/.config/scripts/" && \
    dotfile 'windowmanager/dunstrc' "/home/$USER/.config/dunst/dunstrc" || \
    return 1
    return 0
}

theme ()
{
    install_repo xwallpaper arc-gtk-theme kvantum-qt5 hicolor-icon-theme arc-icon-theme && \
    install_aur moka-icon-theme-git all-repository-fonts && \
    install_git "https://github.com/EmperorPenguin18/SkyrimCursor" && \
    dotfile 'theme/wallpaper.jpg' "/home/$USER/.config/wallpaper.jpg" && \
    dotfile 'theme/DTM-Mono.otf' '/usr/share/fonts/DTM-Mono.otf' && \
    dotfile 'theme/DTM-Sans.otf' '/usr/share/fonts/DTM-Sans.otf' && \
    dotfile 'theme/*.rasi' '/usr/share/rofi/themes/' && \
    dotfile 'theme/Trolltech.conf' '/etc/xdg/Trolltech.conf' && \
    dotfile 'theme/kvantum.kvconfig' "/home/$USER/.config/Kvantum/kvantum.kvconfig" && \
    dotfile 'theme/index.theme' "/home/$USER/.icons/default/index.theme" || \
    return 1
    return 0
}

terminal ()
{
    install_repo alacritty wget mlocate lsd pkgfile neovim ctags python-nvim parted openssh speedtest-cli && \
    install_aur python2-nvim hexokinase-git vim-hexokinase-git && \
    install_git "https://aur.archlinux.org/vim-sneak.git" && \
    dotfile 'terminal/alacritty.yml' "/home/$USER/.config/alacritty/alacritty.yml" && \
    dotfile 'terminal/config.fish' "/home/$USER/.config/fish/config.fish" && \
    dotfile 'terminal/fish_variables' "/home/$USER/.config/fish/fish_variables" && \
    rm /home/$USER/.bash* && \
    service enable pkgfile-update.timer && \
    dotfile 'terminal/init.vim' "/home/$USER/.config/nvim/init.vim" && \
    dotfile 'terminal/help.sh' "/hoem/$USER/.config/scripts/help" && \
    dotfile 'terminal/fetch.sh' "/home/$USER/.config/scripts/fetch" || \
    return 1
    return 0
}

filemanager ()
{
    install_repo pcmanfm-gtk3 gvfs lxsession-gtk3 mtools exfatprogs e2fsprogs ntfs-3g xfsprogs zathura zathura-cb zathura-djvu zathura-pdf-mupdf zathura-ps imv mpv libreoffice-fresh && \
    install_aur mpv-mpris && \
    dotfile 'filemanager/settings.ini' '/etc/gtk-3.0/settings.ini' && \
    dotfile 'filemanager/mpv.conf' "/home/$USER/.config/mpv/mpv.conf" && \
    dotfile 'filemanager/input.conf' "/home/$USER/.config/mpv/input.conf" || \
    return 1
    return 0
}

audio ()
{
    install_repo pulseaudio pulseaudio-alsa pulseaudio-bluetooth lib32-libpulse lib32-alsa-plugins spotifyd playerctl && \
    dotfile 'audio/default.pa' "/home/$USER/.config/pulse/default.pa" && \
    dotfile 'audio/audiocontrol.sh' "/home/$USER/.config/scripts/audiocontrol" && \
    dotfile 'audio/spotifyd.conf' "/home/$USER/.config/spotifyd/spotifyd.conf" && \
    sed -i "s/SNAME/$SNAME/g" /home/$USER/.config/spotifyd/spotifyd.conf && \
    sed -i "s/SPASS/$SPASS/g" /home/$USER/.config/spotifyd/spotifyd.conf && \
    cp /usr/lib/systemd/user/spotifyd.service /etc/systemd/user/ && \
    su $USER -c "systemctl --user enable spotifyd.service" && \
    dotfile 'audio/newsong.sh' "/home/$USER/.config/scripts/newsong" && \
    dotfile 'audio/locale.gen' '/etc/locale.gen' || \
    return 1
    return 0
}

browser ()
{
    install_repo firefox firefox-ublock-origin pass pass-otp && \
    dotfile 'browser/profiles.ini' "/home/$USER/.mozilla/firefox/profiles.ini" && \
    dotfile 'browser/prefs.js' "/home/$USER/.mozilla/firefox/profile/prefs.js" && \
    dotfile 'browser/@testpilot-containers.xpi' "/home/$USER/.mozilla/firefox/profile/extensions/@testpilot-containers.xpi" && \
    dotfile 'browser/homepage.html' "/home/$USER/.config/homepage.html" && \
    dotfile 'browser/homepage.css' "/home/$USER/.config/homepage.css" && \
    sed -i 's/dmenu/rofi -theme center -dmenu -p Passwords -i/g' /usr/bin/passmenu || \
    return 1
    return 0
    #*Passwords (+spotify)*
    #https://www.youtube.com/watch?v=NH4DdXC0RFw&ab_channel=SunKnudsen
}

security ()
{
    install_repo ufw fail2ban apparmor && \
    service enable ufw && \
    sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw && \
    ufw limit 22/tcp && \
    ufw allow 80/tcp && \
    ufw allow 443/tcp && \
    ufw default deny incoming && \
    ufw default allow outgoing && \
    ufw enable && \
    service enable fail2ban && \
    dotfile 'security/jail.local' '/etc/fail2ban/jail.local' && \
    service enable apparmor && \
    dotfile 'security/host.conf' '/etc/host.conf' && \
    dotfile 'security/90-netsec.conf' '/etc/sysctl.d/90-netsec.conf' || \
    return 1
    return 0
}

gaming ()
{
    install_repo 0ad xonotic minetest supertuxkart dwarffortress nethack rogue warsow openttd && \
    install_aur zork1 veloren vvvvvv-git thedarkmod-bin freedoom gzdoom tetris-terminal-git || \
    return 1
    return 0
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
    #https://github.com/dreamer
    #https://libredd.it/r/leagueoflinux/comments/dr2qye/amazing_performance_boost_by_tweaking_pulseaudio/
    #https://blog.thepoon.fr/osuLinuxAudioLatency/
    #https://github.com/AUNaseef/protonup
}

power ()
{
    install_repo light acpid hdparm sdparm xscreensaver && \
    install_aur laptop-mode-tools auto-cpufreq && \
    dotfile 'power/brightnesscontrol.sh' "/home/$USER/.config/scripts/brightnesscontrol" && \
    dotfile 'power/power.kb' "/home/$USER/.config/sxhkd/power.kb" && \
    service enable acpid && \
    service enable auto-cpufreq && \
    dotfile 'power/laptop-mode.conf' '/etc/laptop-mode/laptop-mode.conf' && \
    service enable laptop-mode && \
    dotfile 'power/powersave.rules' '/etc/udev/rules.d/powersave.rules' && \
    dotfile 'power/powerevents.sh' "/home/$USER/.config/scripts/powerevents" && \
    dotfile 'power/99-battery.sh' '/etc/X11/xinit/xinitrc.d/99-battery.sh' && \
    dotfile 'power/batterycron' '/etc/cron.d/batterycron' && \
    dotfile 'power/batterynotify.sh' "/home/sebastien/.config/scripts/batterynotify" && \
    dotfile 'power/mute.conf' '/etc/modprobe.d/mute.conf' || \
    return 1
    return 0
}

virtualization ()
{
    install_repo qemu qemu-arch-extra libvirt ebtables dnsmasq virt-manager libguestfs edk2-ovmf dmidecode && \
    usermod -a -G libvirt $USER && \
    usermod -a -G kvm $USER && \
    service enable libvirtd && \
    dotfile '/virtualization/virt.kb' "/home/$USER/.config/sxhkd/virt.kb" || \
    return 1
    return 0
}

other ()
{
    install_aur freetube lightcord mullvad-vpn-cli aic94xx-firmware wd719x-firmware upd72020x-fw && \
    install_repo networkmanager-openvpn && \
    service start mullvad-daemon && \
    mullvad account set $MULLVAD && \
    mullvad auto-connect set on && \
    mullvad lan set allow && \
    mullvad relay set tunnel-protocol openvpn || \
    return 1
    return 0
    #https://unix.stackexchange.com/questions/53080/list-optional-dependencies-with-pacman-on-arch-linux
}

clean_up ()
{
    chown -R $USER:$USER /home/$USER && \
    fc-cache && \
    updatedb && \
    locale-gen && \
    mkinitcpio -P && \
    grub-mkconfig -o /boot/grub/grub.cfg || \
    return 1
    return 0
}

check_error ()
{
   if [ $? -ne 0 ]; then
      echo $1
      exit -1
   fi
}

pre_checks
user_prompts
packagemanager
check_error "packagemanager failed"
cloud
check_error "cloud failed"
update
check_error "update failed"
video
check_error "video failed"
login
check_error "login failed"
xorg
check_error "xorg failed"
windowmanager
check_error "windowmanager failed"
theme
check_error "theme failed"
terminal
check_error "terminal failed"
filemanager
check_error "filemanager failed"
audio
check_error "audio failed"
browser
check_error "browser failed"
security
check_error "security failed"
[ "${GAMING}" = "y" ] && gaming
[ "${LAPTOP}" = "y" ] && power; check_error "power failed"
[ "${VIRTUALIZATION}" = "y" ] && virtualization; check_error "virtualization failed"
other
check_error "other failed"
clean_up
check_error "clean_up failed"
echo "-------------------------------------------------"
echo "          All done! You can reboot now.          "
echo "-------------------------------------------------"

#*Script performance*
