#!/bin/sh

dotfile ()
{
    echo $2 | grep -o '/' > /dev/null && mkdir -p (echo $2 | cut -f -(echo $2 | grep -o '/' | wc -l) -d '/')
    cp -f $DIR/$1 $2
    if file -i $2 | grep shellscript; then
        chmod +x $2
    elif file $2 | grep font; then
        chmod 0444 $2
    else
        sed -i "s/USER/$USER/g" $2
    fi
    echo $1,$2 >> /home/$USER/.config/files.csv
}
export -f dotfile

insert_binding ()
{
    echo "$1    #$3" >> /home/$USER/.config/sxhkd/sxhkdrc
    echo "  $2" >> /home/$USER/.config/sxhkd/sxhkdrc
    echo "" >> /home/$USER/.config/sxhkd/sxhkdrc
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
    dotfile 'packagemanager/pacman.conf' '/etc/pacman.conf'
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
    #*Remove nopass*
}

cloud ()
{
    pacman -S fuse rclone --noconfirm --needed
    echo "user_allow_other" >> /etc/fuse.conf
    clear
    echo "Setup any rclone remotes you want. If you don't want any just enter 'q'."
    echo
    rclone config
    dotfile 'cloud/rcloneautomater.sh' '/home/$USER/.config/scripts/rcloneautomater'
    /home/$USER/.config/scripts/rcloneautomater $DIR
    return 0
}

update ()
{
    pacman -S cron reflector --noconfirm --needed
    dotfile 'update/backup.sh' '/home/$USER/.config/scripts/backup'
    dotfile 'update/update.sh' '/home/$USER/.config/scripts/update'
    echo "0 3 * * 1 root /home/$USER/.config/scripts/backup" >> /etc/crontab
    echo "0 4 * * 1 $USER /home/$USER/.config/scripts/update" >> /etc/crontab
    reflector --country $(curl -sL https://raw.github.com/eggert/tz/master/zone1970.tab | grep $TIME | awk '{print $1}') --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    return 0
}

video ()
{
    pacman -S mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau --noconfirm --needed
    [ "$(echo $VIDEO | grep 'intel' | wc -l)" -gt 0 ] && pacman -S xf86-video-intel vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver --noconfirm --needed
    [ "$(echo $VIDEO | grep 'amd' | wc -l)" -gt 0 ] && pacman -S xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon --noconfirm --needed
    [ "$(echo $VIDEO | grep 'nvidia' | wc -l)" -gt 0 ] && pacman -S nvidia-dkms lib32-nvidia-utils nvidia-prime --noconfirm --needed
    #[ "$(echo $VIDEO | grep 'intel' | wc -l)" -gt 0 ] && [ "$(echo $VIDEO | grep 'nvidia' | wc -l)" -gt 0 ] && pikaur -S optimus-manager && cp -f $DIR/xorg/optimus-manager.conf /etc/optimus-manager/optimus-manager.conf
    return 0
    #*Enable vsync + freesync/gsync*
    #*https://wiki.archlinux.org/index.php/NVIDIA#DRM_kernel_mode_setting*
    #https://github.com/Askannz/optimus-manager/wiki/A-guide--to-power-management-options
    #https://wiki.archlinux.org/index.php/PRIME#PRIME_synchronization
}

login ()
{
    pacman -S lightdm lightdm-gtk-greeter --noconfirm --needed
    dotfile 'login/lightdm.conf' '/etc/lightdm/lightdm.conf'
    dotfile 'login/displaysetup.sh' '/home/$USER/.config/scripts/displaysetup'
    dotfile 'login/lightdm-gtk-greeter.conf' '/etc/lightdm/lightdm-gtk-greeter.conf'
    dotfile 'login/background.png' '/home/$USER/.config/background.png'
    dotfile 'login/alacritty.desktop' '/usr/share/xsessions/alacritty.desktop'
    dotfile 'login/xinitrc.desktop' '/usr/share/xsessions/xinitrc.desktop'
    dotfile 'login/xinitrc' '/home/$USER/.xinitrc'
    rm /usr/share/xsessions/spectrwm.desktop
    systemctl enable lightdm
    dotfile 'login/grub' '/etc/default/grub'
    UUID="$(blkid -o device | xargs -L1 cryptsetup luksUUID | grep -v WARNING)"
    sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(echo $UUID):cryptroot\"/g" /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    return 0
    #https://github.com/phillipberndt/autorandr
}

xorg ()
{
    pikaur -S xorg xdotool xclip picom-git all-repository-fonts --noconfirm --needed
    dotfile 'xorg/picom.conf' '/home/$USER/.config/picom.conf'
    su $USER -c "git clone https://github.com/EmperorPenguin18/SkyrimCursor"
    cd SkyrimCursor
    su $USER -c "makepkg --noconfirm"
    pacman -U *.pkg* --noconfirm --needed
    cd ../
    rm -r SkyrimCursor
    mkdir -p /home/$USER/.icons/default
    echo "[icon theme]" > /home/$USER/.icons/default/index.theme
    echo "Inherits=skyrim" >> /home/$USER/.icons/default/index.theme
    return 0
}

windowmanager ()
{
    pacman -S spectrwm sxhkd feh rofi unclutter --noconfirm --needed
    dotfile 'windowmanager/spectrwm.conf' '/home/$USER/.spectrwm.conf'
    dotfile 'windowmanager/sxhkdrc' '/home/$USER/.config/sxhkd/sxhkdrc'
    dotfile 'windowmanager/screenshot.sh' '/home/$USER/.config/scripts/screenshot'
    dotfile 'windowmanager/monitor.sh' '/home/$USER/.config/scripts/monitor'
    dotfile 'windowmanager/wallpaper.jpg' '/home/$USER/.config/wallpaper.jpg'
    dotfile 'windowmanager/DTM-Mono.otf' '/usr/share/fonts/DTM-Mono.otf'
    dotfile 'windowmanager/DTM-Sans.otf' '/usr/share/fonts/DTM-Sans.otf'
    dotfile 'windowmanager/config.rasi' '/home/$USER/.config/rofi/config.rasi'
    ls $DIR/windowmanager/*.rasi | cut -f 6 -d '/' | xargs -P 0 -n 1 -I {} sh -c dotfile windowmanager/{} /usr/share/rofi/themes/{}
    ls $DIR/windowmanager/rofi-* | cut -f 6 -d '/' | xargs -P 0 -n 1 -I {} sh -c dotfile windowmanager/{} /home/$USER/.config/scripts/{}
    return 0
    #https://manpages.debian.org/testing/rofi/rofi-theme.5.en.html
    #*Workspace notification*
}

terminal ()
{
    pacman -S alacritty wget mlocate lsd pkgfile neovim parted openssh unzip zip unrar speedtest-cli --noconfirm --needed
    dotfile 'terminal/alacritty.yml' '/home/$USER/.config/alacritty/alacritty.yml'
    dotfile 'terminal/config.fish' '/home/$USER/.config/fish/config.fish'
    dotfile 'terminal/fish_variables' '/home/$USER/.config/fish/fish_variables'
    rm /home/$USER/.bash*
    systemctl enable pkgfile-update.timer
    dotfile 'terminal/init.vim' '/home/$USER/.config/nvim/init.vim'
    return 0
    #*Help command (for terminal utilities)*
    #*Fetch*
}

filemanager ()
{
    pikaur -S pcmanfm-gtk3 gvfs arc-gtk-theme hicolor-icon-theme arc-icon-theme moka-icon-theme-git lxsession-gtk3 mtools exfatprogs e2fsprogs ntfs-3g xfsprogs zathura zathura-cb zathura-djvu zathura-pdf-mupdf zathura-ps mpv mpv-mpris libreoffice-fresh --noconfirm --needed #hfsprogs apfsprogs-git
    dotfile 'filemanager/settings.ini' '/etc/gtk-3.0/settings.ini'
    dotfile 'filemanager/mpv.conf' '/home/$USER/.config/mpv/mpv.conf'
    dotfile 'filemanager/input.conf' '/home/$USER/.config/mpv/input.conf'
    return 0
    #https://github.com/deviantfero/wpgtk
    #https://github.com/Misterio77/flavours
    #https://github.com/themix-project/oomox
}

audio ()
{
    pacman -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth lib32-libpulse lib32-alsa-plugins spotifyd playerctl dunst --noconfirm --needed
    dotfile 'audio/default.pa' '/home/$USER/.config/pulse/default.pa'
    dotfile 'audio/audiocontrol.sh' '/home/$USER/.config/scripts/audiocontrol'
    dotfile 'audio/spotifyd.conf' '/home/$USER/.config/spotifyd/spotifyd.conf'
    sed -i "s/SNAME/$SNAME/g" /home/$USER/.config/spotifyd/spotifyd.conf
    sed -i "s/SPASS/$SPASS/g" /home/$USER/.config/spotifyd/spotifyd.conf
    cp /usr/lib/systemd/user/spotifyd.service /etc/systemd/user/
    su $USER -c "systemctl --user enable spotifyd.service"
    dotfile 'audio/newsong.sh' '/home/$USER/.config/scripts/newsong'
    dotfile 'audio/dunstrc' '/home/$USER/.config/dunst/dunstrc'
    echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
    return 0
    #*Output auto-selection*
}

browser ()
{
    pacman -S firefox pass pass-otp --noconfirm --needed
    #mkdir -p /home/$USER/.mozilla/firefox
    firefox -headless &
    killall firefox
    PROFILE="$(ls /home/$USER/.mozilla/firefox | grep default-release)"
    dotfile 'browser/prefs.js' '/home/$USER/.mozilla/firefox/$PROFILE/prefs.js'
    ls $DIR/browser/*.xpi | cut -f 6 -d '/' | xargs -P 0 -n 1 -I {} sh -c dotfile browser/{} /home/$USER/.mozilla/firefox/$PROFILE/extensions/{}
    dotfile 'browser/homepage.html' '/home/$USER/.config/homepage.html'
    sed -i 's/dmenu/rofi -theme center -dmenu -p Passwords -i/g' /usr/bin/passmenu
    return 0
    #*Passwords (+spotify)*
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
    pikaur -S light tlp acpid --noconfirm --needed
    dotfile 'power/brightnesscontrol.sh' '/home/$USER/.config/scripts/brightnesscontrol'
    insert_binding XF86MonBrightnessUp "/home/$USER/.config/scripts/brightnesscontrol up" 'Increase brightness'
    insert_binding XF86MonBrightnessDown "/home/$USER/.config/scripts/brightnesscontrol down" 'Decrease brightness'
    systemctl enable tlp
    systemctl enable NetworkManager-dispatcher
    systemctl mask systemd-rfkill.service
    systemctl mask systemd-rfkill.socket
    dotfile 'power/tlp.conf' '/etc/tlp.conf'
    #https://wiki.archlinux.org/index.php/TLP
    systemctl enable acpid
    #https://wiki.archlinux.org/index.php/Laptop_Mode_Tools
    #https://wiki.archlinux.org/index.php/CPU_frequency_scaling / AUTO_CPUFREQ
    #*Hibernate*
    #*powertop*
    #*Mute LED*
    #*Screen timeout*
    #*Battery notification*
}

virtualization ()
{
    pacman -S qemu qemu-arch-extra libvirt ebtables dnsmasq virt-manager libguestfs edk2-ovmf dmidecode --noconfirm --needed
    systemctl enable libvirtd
    insert_binding 'super + m' virt-manager 'Open Virtual Machine Manager'
    return 0
    #https://github.com/Fmstrat/winapps
}

other ()
{
    gpg --recv-key 78CEAA8CB72E4467
    gpg --recv-key AEE9DECFD582E984
    pikaur -S freetube discord mullvad-vpn-cli networkmanager-openvpn aic94xx-firmware wd719x-firmware upd72020x-fw --noconfirm
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
    chown -R $USER:$USER /home/$USER
    fc-cache
    updatedb
    locale-gen
    mkinitcpio -P
    return 0
}

pre_checks
user_prompts
packagemanager
cloud
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

#*Script performance*
#*Dotfile management (chezmoi)*
#https://wiki.archlinux.org/index.php/General_recommendations
