#!/bin/sh

USER=$(ls /home)
export DISPLAY=:0
export XAUTHORITY=/home/$USER/.Xauthority

source /home/$USER/.config/scripts/displaysetup

OUTPUT=$(pacmd list-cards | sed '1,/profiles:/d;/active profile:/,$d' | grep -v "available: no\|off:\|input:" | tail -1 | cut -f 2 -d ':')
[ -z $OUTPUT ] && OUTPUT="off" || OUTPUT="output:$OUTPUT+input:analog-stereo"
su $USER -c "pactl --server unix:/run/user/$(id -u $USER)/pulse/native set-card-profile 0 $OUTPUT"
