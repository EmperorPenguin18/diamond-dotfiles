#!/bin/sh

install_repo ()
{
    emerge "$@" || return 1
    return 0
}

install_git ()
{
    return 0
}

service ()
{
    if [ "$1" = "enable" ]; then
        systemctl $@ || return 1
    elif [ "$1" = "uenable" ]; then
        su $USER -c "systemctl --user enable $2"
    elif [ "$1" = "rc" ]; then
        rc-update add "$2" default || return 1
    else
        return 1
    fi
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
    SRC="$(pwd)" || \
    return 1
    return 0
}

user_prompts ()
{
    read -p "Enter username: " USER && \
    useradd -m -G users,wheel,audio -s /bin/bash "$USER"
    local confirm
    read -p "Do want VM support? (Y/N): " confirm && \
        [ "$confirm" = "y" -o "$confirm" = "Y" ] || \
        VIRTUALIZATION=n || \
        VIRTUALIZATION=y
    #MULLVAD=$(dialog --stdout --inputbox "What is your Mullvad VPN account number?" 0 0)
    return 0
}

packagemanager ()
{
    dotfile 
    install_repo 
    return 1
    return 0
}

backups ()
{
    install_repo cronie && \
    dotfile 'update/backup.sh' "/home/$USER/.config/scripts/backup" && \
    dotfile 'update/crontab' '/etc/crontab' && \
    service enable cronie && \
    return 1
    return 0
}

login ()
{
    install_repo 
    dotfile 'login/wayrc.sh' "/home/$USER/.config/scripts/wayrc" && \
    dotfile 'login/watchdog.conf' '/etc/modprobe.d/watchdog.conf' || \
    return 1
    return 0
}

windowmanager ()
{
    install_repo  && \
    dotfile 
    return 1
    return 0
}

theme ()
{
    install_repo 
    dotfile 'login/background.png' "/home/$USER/.config/background.png" && \
    dotfile 'theme/wallpaper.jpg' "/home/$USER/.config/wallpaper.jpg" && \
    return 1
    return 0
}

terminal ()
{
    install_repo sys-apps/mlocate parted openssh && \
    dotfile 'terminal/help.sh' "/home/$USER/.config/scripts/help" && \
    return 1
    return 0
}

filemanager ()
{
    install_repo mpv && \
    dotfile 'filemanager/mpv.conf' "/home/$USER/.config/mpv/mpv.conf" && \
    dotfile 'filemanager/input.conf' "/home/$USER/.config/mpv/input.conf" || \
    return 1
    return 0
}

audio ()
{
    install_repo 
    return 1
    return 0
}

browser ()
{
    install_repo 
    dotfile 'browser/homepage.html' "/home/$USER/.config/homepage.html" && \
    dotfile 'browser/homepage.css' "/home/$USER/.config/homepage.css" && \
    return 1
    return 0
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
    install_repo 0ad xonotic minetest supertuxkart dwarffortress nethack rogue warsow openttd sauerbraten && \
    install_aur zork1 veloren vvvvvv-git thedarkmod-bin freedoom gzdoom tetris-terminal-git unvanquished adom-noteye || \
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
    #https://github.com/DavidoTek/ProtonUp-Qt
    #https://unix.stackexchange.com/questions/669565/cannot-use-trackpad-and-keyboard-at-the-same-time
}

virtualization ()
{
    install_repo qemu qemu-arch-extra libvirt ebtables dnsmasq virt-manager libguestfs edk2-ovmf dmidecode && \
    usermod -a -G libvirt $USER && \
    usermod -a -G kvm $USER && \
    service enable libvirtd && \
    return 1
    return 0
}

other ()
{
    install_aur mullvad-vpn-cli && \
    install_repo networkmanager-openvpn && \
    service start mullvad-daemon && \
    mullvad account set $MULLVAD && \
    mullvad auto-connect set on && \
    mullvad lan set allow && \
    mullvad relay set tunnel-protocol openvpn || \
    return 1
    return 0
    #https://github.com/blueOkiris/bgrm
}

clean_up ()
{
    chown -R $USER:$USER /home/$USER && \
    #fc-cache && \
    #updatedb && \
    #locale-gen && \
    #mkinitcpio -P && \
    #grub-mkconfig -o /boot/grub/grub.cfg || \
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
backups
check_error "backups failed"
login
check_error "login failed"
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
[ "${VIRTUALIZATION}" = "y" ] && virtualization; check_error "virtualization failed"
other
check_error "other failed"
clean_up
check_error "clean_up failed"
echo "-------------------------------------------------"
echo "          All done! You can reboot now.          "
echo "-------------------------------------------------"
