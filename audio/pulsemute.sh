#!/bin/sh

CLIENTS=$(pactl list sink-inputs | grep -e \# -e application.process.id)

mute() {
	SINK=$(echo "$CLIENTS" | tac | awk "f{print;f=0} /$1/{f=1}" | cut -f 2 -d '#')
	for I in $SINK
	do
		pactl set-sink-input-mute $I toggle
	done
}

findChilds() {
	for child in $(ps --ppid $1 ho pid) ;do
		mute $child
		findChilds $child
	done
}

WINDOW=$(xprop -id $(xdotool getwindowfocus) | awk '/_NET_WM_PID/ {print $(NF)}')
mute $WINDOW
findChilds $WINDOW
