#!/bin/sh

NC='\033[0m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
LCYAN='\033[1;36m'

DEVICE=$(nmcli -t con show | cut -f 4 -d ':' | head -1)

printf "${LCYAN}       /\         ${MAGENTA}$(whoami)${BLUE}@${MAGENTA}$(uname -n)\n"
printf "${LCYAN}      /  \        ${BLUE}os     ${NC}$(lsb_release -a | awk '/Description/ {print $2 " " $3}')\n"
printf "${LCYAN}     /\   \       ${BLUE}host   ${NC}$(cat /sys/devices/virtual/dmi/id/product_name)\n"
printf "${LCYAN}    /      \      ${BLUE}kernel ${NC}$(uname -r)\n"
printf "${LCYAN}   /   ,,   \     ${BLUE}uptime ${NC}$(uptime -p)\n"
printf "${LCYAN}  /   |  |  -\    ${BLUE}pkgs   ${NC}$(pacman -Qq | wc -l)\n"
printf "${LCYAN} /_-''    ''-_\   ${BLUE}ip     ${NC}$(ip addr show $DEVICE | awk '/inet / {print $2}')\n${NC}"
