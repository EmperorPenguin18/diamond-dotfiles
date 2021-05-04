#!/bin/sh

NC='\033[0m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
LCYAN='\033[1;36m'

printf "${LCYAN}       /\         ${MAGENTA}$(whoami)${BLUE}@${MAGENTA}$(uname -n)\n"
printf "${LCYAN}      /  \        ${BLUE}os     ${NC}$(lsb_release -a | awk '/Description/ {print $2 " " $3}')\n"
printf "${LCYAN}     /\   \       ${BLUE}host   ${NC}$(cat /sys/devices/virtual/dmi/id/product_name)\n"
printf "${LCYAN}    /      \      ${BLUE}kernel ${NC}$(uname -r)\n"
printf "${LCYAN}   /   ,,   \     ${BLUE}uptime ${NC}$(uptime -p | awk '{print $2"d "$4"h "$6"m"}')\n"
printf "${LCYAN}  /   |  |  -\    ${BLUE}pkgs   ${NC}$(pacman -Qq | wc -l)\n"
printf "${LCYAN} /_-''    ''-_\   ${BLUE}ip     ${NC}$(ifconfig | sed '/^virbr0/,/^        TX e/{/^virbr0/!{/^        TX e/!d}};/^tun0/,/^        TX e/{/^tun0/!{/^        TX e/!d}};/^lo/,/^        TX e/{/^lo/!{/^        TX e/!d}};' | awk '/255.255.255.0/ {print $2}')\n${NC}"
