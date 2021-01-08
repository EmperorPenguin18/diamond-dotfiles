#!/bin/bash
#Shortcuts

USER="$(ls /home)"

output=$(fgrep "bind" /home/$USER/.spectrwm.conf | sed -n 's/.*= //p' | sed 's/MOD/Super/g' | sed 's/Mod1/Alt/g' | rofi -theme center -dmenu -p Shortcuts -i)
if [[ $output == "" ]]; then exit 1;
else xdotool key $output; fi
