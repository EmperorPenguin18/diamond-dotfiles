#!/bin/sh

CLIENTS=$(pactl list sink-inputs | grep -e \# -e application.process.id)
WINDOW=$(xprop -id $(xdotool getwindowfocus) | awk '/_NET_WM_PID/ {print $(NF)}')
SINK=$(echo "$CLIENTS" | tac | awk "f{print;f=0} /$WINDOW/{f=1}" | cut -f 2 -d '#')

pactl set-sink-input-mute $SINK toggle
