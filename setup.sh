#!/bin/sh

install_repo ()
{
    emerge -q "$@" || return 1
    return 0
}

install_git ()
{
    local url="$1" && \
    command -v git >/dev/null && \
    git clone "$1" /tmp/repo && \
    pushd /tmp/repo && \
    make release && \
    make install && \
    popd && \
    rm -rf /tmp/repo || \
    return 1
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
    ln -sf "$(pwd)/$DIR/$FILE" "$DEST/$RENAME"
}

error ()
{
    echo $@
    exit 1
}

pre_checks ()
{
    [ "$(whoami)" = "root" ] && \
    [ "$(nproc)" -gt "3" ] && \
    [ "$(awk '/MemTotal/ {printf "%.0f\n", $2 / 1000}' /proc/meminfo)" -gt "8000" ] || \
    error "One or more pre-checks failed"
    return 0
}

user_prompts ()
{
    read -p "Enter username: " USER && \
    useradd -m -G users,wheel,audio,video -s /bin/bash "$USER" && \
    mkdir -p /home/$USER/.config
    #local confirm
    #read -p "Do you want VM support? (y/N): " confirm && \
        #[ "$confirm" = "y" -o "$confirm" = "Y" ] || \
        #VIRTUALIZATION=n || \
        #VIRTUALIZATION=y
    return 0
}

packagemanager ()
{
    dotfile 'packagemanager/make.conf' '/etc/portage/make.conf' && \
    dotfile 'packagemanager/no-lto.conf' '/etc/portage/env/no-lto.conf' && \
    dotfile 'packagemanager/package.env' '/etc/portage/package.env' && \
    dotfile 'packagemanager/libglvnd.use' '/etc/portage/package.use/libglvnd' && \
    dotfile 'packagemanager/pillow.use' '/etc/portage/package.use/pillow' && \
    rm -rf /var/db/repos/gentoo && \
    until emerge -q --sync; do echo "Attempting sync again"; done && \
    eselect profile set default/linux/amd64/23.0/desktop && \
    emerge -qe system && \
    install_repo app-eselect/eselect-repository && \
    eselect repository enable guru && \
    emerge -q --sync || \
    return 1
    return 0
}

backups ()
{
    install_repo virtual/cron grub-btrfs && \
    dotfile 'update/backup.sh' "/home/$USER/.config/scripts/backup" && \
    ln -s "/home/$USER/.config/scripts/backup" /etc/cron.weekly/backup && \
    service rc cronie || \
    return 1
    return 0
}

login ()
{
    dotfile 'login/agetty-autologin' '/etc/conf.d/agetty-autologin' && \
    sed -i "s/<username>/$USER/g" /etc/conf.d/agetty-autologin && \
    ln -s agetty /etc/init.d/agetty-autologin.tty1 && \
    service rc agetty-autologin.tty1 || \
    return 1
    return 0
}

shell ()
{
    dotfile 'shell/vim.use' '/etc/portage/package.use/vim' && \
    install_repo app-shells/bash-completion sys-apps/mlocate app-editors/vim && \
    dotfile 'shell/bashrc' "/home/$USER/.bashrc" && \
    dotfile 'shell/help.sh' "/home/$USER/.config/scripts/help" && \
    dotfile 'shell/colors.sh' "/home/$USER/.config/scripts/colours" && \
    dotfile 'shell/vimrc' "/home/$USER/.config/vim/vimrc" && \
    dotfile 'shell/init.lua' "/home/$USER/.config/vim/init.lua" || \
    return 1
    return 0
}

windowmanager ()
{
    dotfile 'windowmanager/hyprland.use' '/etc/portage/package.use/hyprland' && \
    dotfile 'windowmanager/clang.use' '/etc/portage/package.use/clang' && \
    dotfile 'windowmanager/seatd.use' '/etc/portage/package.use/seatd' && \
    install_repo gui-wm/hyprland gui-apps/swaybg gui-apps/waybar && \
    service rc seatd && \
    usermod -aG seat "$USER" && \
    dotfile 'windowmanager/bash_profile' "/home/$USER/.bash_profile" && \
    dotfile 'windowmanager/hyprland.conf' "/home/$USER/.config/hypr/hyprland.conf" || \
    return 1
    return 0
}

audio ()
{
    dotfile 'audio/pipewire.use' '/etc/portage/package.use/pipewire' && \
    install_repo media-video/pipewire && \
    service rc dbus || \
    return 1
    return 0
}

theme ()
{
    mkdir -p /home/$USER/git && \
    git clone "https://github.com/Vurmiraaz/Skyrim-Wallpaper" /home/$USER/git/Skyrim-Wallpaper && \
    ln -sf "/home/$USER/git/Skyrim-Wallpaper/Windhelm - Palace of The Kings.png" /home/$USER/.config/wallpaper.png || \
    return 1
    return 0
}

terminal ()
{
    install_repo gui-apps/foot && \
    dotfile 'terminal/foot.ini' "/home/$USER/.config/foot/foot.ini" || \
    return 1
    return 0
}

filemanager ()
{
    dotfile 'filemanager/mpv.use' '/etc/portage/package.use/mpv' && \
    install_repo app-shells/fzf media-video/mpv media-gfx/pqiv && \
    dotfile 'filemanager/fuzzybuddy.sh' "/home/$USER/.config/scripts/.fuzzybuddy" && \
    dotfile 'filemanager/mpv.conf' "/home/$USER/.config/mpv/mpv.conf" && \
    dotfile 'filemanager/input.conf' "/home/$USER/.config/mpv/input.conf" || \
    return 1
    return 0
}

browser ()
{
    eselect repository add brave-overlay git https://gitlab.com/jason.oliveira/brave-overlay.git && \
    emerge --sync brave-overlay && \
    echo 'dev-libs/libpthread-stubs **' >> /etc/portage/package.accept_keywords/libpthread-stubs && \
    install_repo www-client/brave-bin::brave-overlay && \
    dotfile 'browser/brave.sh' "/home/$USER/.config/scripts/brave" && \
    dotfile 'browser/homepage.html' "/home/$USER/.config/homepage.html" && \
    dotfile 'browser/homepage.css' "/home/$USER/.config/homepage.css" || \
    return 1
    return 0
}

#security ()
#{
    #install_repo ufw fail2ban apparmor && \
    #service enable ufw && \
    #sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw && \
    #ufw limit 22/tcp && \
    #ufw allow 80/tcp && \
    #ufw allow 443/tcp && \
    #ufw default deny incoming && \
    #ufw default allow outgoing && \
    #ufw enable && \
    #service enable fail2ban && \
    #dotfile 'security/jail.local' '/etc/fail2ban/jail.local' && \
    #service enable apparmor && \
    #dotfile 'security/host.conf' '/etc/host.conf' && \
    #dotfile 'security/90-netsec.conf' '/etc/sysctl.d/90-netsec.conf' || \
    #return 1
    #return 0
#}

#gaming ()
#{
    #install_repo 0ad xonotic minetest supertuxkart dwarffortress nethack rogue warsow openttd sauerbraten && \
    #install_aur zork1 veloren vvvvvv-git thedarkmod-bin freedoom gzdoom tetris-terminal-git unvanquished adom-noteye || \
    #return 1
    #return 0
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
    #neverball
    #stunt rally
    #opensurge
#}

#virtualization ()
#{
    #install_repo qemu qemu-arch-extra libvirt ebtables dnsmasq virt-manager libguestfs edk2-ovmf dmidecode && \
    #usermod -a -G libvirt $USER && \
    #usermod -a -G kvm $USER && \
    #service enable libvirtd && \
    #return 1
    #return 0
#}

other ()
{
    echo "tmpfs /tmp tmpfs rw,nosuid,nodev,size=4G,mode=1777 0 0" >> /etc/fstab && \
    echo "tmpfs /home/$USER/.cache tmpfs rw,nosuid,nodev,size=4G,mode=1777 0 0" >> /etc/fstab && \
    install_repo net-vpn/mullvadvpn-app || \
    return 1
    return 0
}

clean_up ()
{
    emerge --depclean && \
    grub-mkconfig -o /boot/grub/grub.cfg && \
    updatedb && \
    chown -R $USER:$USER /home/$USER || \
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
shell
check_error "shell failed"
windowmanager
check_error "windowmanager failed"
audio
check_error "audio failed"
theme
check_error "theme failed"
terminal
check_error "terminal failed"
filemanager
check_error "filemanager failed"
browser
check_error "browser failed"
#security
#check_error "security failed"
#if [ "${VIRTUALIZATION}" = "y" ]; then
    #virtualization
    #check_error "virtualization failed"
#fi
other
check_error "other failed"
clean_up
check_error "clean_up failed"
echo "-------------------------------------------------"
echo "          All done! You can reboot now.          "
echo "-------------------------------------------------"
