#!/bin/sh

NC='\033[0m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
LCYAN='\033[1;36m'

printf "${LCYAN}       /\         ${MAGENTA}$(whoami)${BLUE}@${MAGENTA}$(uname -n)
${LCYAN}      /  \        ${BLUE}os     ${NC}$(lsb_release -a | awk '/Description/ {print $2, $3}')
${LCYAN}     /\   \       ${BLUE}host   ${NC}$(cat /sys/devices/virtual/dmi/id/product_name)
${LCYAN}    /      \      ${BLUE}kernel ${NC}$(uname -r)
${LCYAN}   /   ,,   \     ${BLUE}uptime ${NC}$(uptime -p | awk '{(NF-5 > 0) ? day = $(NF-5)"d " : day = ""; (NF-3 > 0) ? hour = $(NF-3)"h " : hour = ""; print day""hour""$(NF-1)"m"}')
${LCYAN}  /   |  |  -\    ${BLUE}pkgs   ${NC}$(pacman -Q | wc -l)
${LCYAN} /_-''    ''-_\   ${BLUE}ip     ${NC}$(ip -br -4 addr | awk '/UP/ {print $3}')
${NC}"
