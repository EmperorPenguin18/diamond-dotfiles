#!/bin/sh

[ "$1" = "mute" ] && pactl set-sink-mute 0 toggle && dunstify -h string:x-dunst-stack-tag:volume "$(pactl list sinks | grep Mute)"
[ "$1" = "up" ] && pactl set-sink-volume 0 +5% && dunstify -h string:x-dunst-stack-tag:volume "Volume $(pactl list sinks | grep Volume | cut -f 2 -d '/' | sed -n '1p')"
[ "$1" = "down" ] && pactl set-sink-volume 0 -5% && dunstify -h string:x-dunst-stack-tag:volume "Volume $(pactl list sinks | grep Volume | cut -f 2 -d '/' | sed -n '1p')"
#[ "$1" = "" ] &&
#[ "$1" = "" ] &&
#[ "$1" = "" ] &&
#[ "$1" = "" ] &&
