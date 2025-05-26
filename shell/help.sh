#!/bin/sh

NC='\033[1;0m'
WHITE='\033[1;37m'

describe ()
{
        printf "${WHITE}$1${NC} -$(man -f $1 | cut -f 2- -d '-')\n"
}

echo "Basic commands:"
describe ls
describe cd
describe cp
describe mv
describe rm
describe cat
describe less
describe pwd
describe exit
describe clear
describe mkdir
describe rmdir
describe touch
describe date
echo

echo "Intermediate commands:"
describe echo
describe doas
describe bsdtar
describe grep
describe find
describe nvim
describe source
describe convert
describe mediainfo
describe pacman
describe du
describe df
describe systemctl
describe killall
describe uname
describe head
describe tail
echo

echo "Advanced commands:"
describe curl
describe dmidecode
describe whereis
describe fdisk
describe sfdisk
describe lsblk
describe split
describe lynx
describe scp
describe ssh
describe ffmpeg
describe chmod
describe chown
describe git
describe diff
describe patch
describe ip
describe awk
describe sed
describe cut
echo

echo "Use 'man {command}' to learn more about a command"
