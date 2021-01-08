#!/bin/bash
#Shortcuts

USER="$(ls /home)"

output="$(rofi -theme center -dmenu -p Shortcuts -i -input /home/$USER/kb.txt)"
if [[ $output == "" ]]; then exit 1;
else xdotool key $output; fi
