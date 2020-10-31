#!/bin/bash
#Shortcuts
output=$(rofi -theme center -dmenu -p Shortcuts -i -input /home/sebastien/kb.txt)
if [[ $output == "" ]]; then exit 1;
else xdotool key $output; fi
