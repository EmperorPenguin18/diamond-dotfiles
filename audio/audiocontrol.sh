#!/bin/sh

[ "$1" = "mute" ] && pactl set-sink-mute 0 toggle && dunstify -I /usr/share/icons/Arc/status/symbolic/audio-volume-high-symbolic.svg -h string:x-dunst-stack-tag:volume "$(pactl list sinks | awk '/Mute/ {print $1 " " $2}')"
[ "$1" = "up" ] && pactl set-sink-volume 0 +5% && dunstify -I /usr/share/icons/Arc/status/symbolic/audio-volume-high-symbolic.svg -h string:x-dunst-stack-tag:volume "Volume:$(pactl list sinks | grep Volume | cut -f 2 -d '/' | sed -n '1p')"
[ "$1" = "down" ] && pactl set-sink-volume 0 -5% && dunstify -I /usr/share/icons/Arc/status/symbolic/audio-volume-high-symbolic.svg -h string:x-dunst-stack-tag:volume "Volume:$(pactl list sinks | grep Volume | cut -f 2 -d '/' | sed -n '1p')"
[ "$1" = "play" ] && playerctl --player=spotifyd play-pause && dunstify -I /usr/share/icons/Arc/emblems/symbolic/emblem-music-symbolic.svg -h string:x-dunst-stack-tag:music "$(playerctl --player=spotifyd status)"
[ "$1" = "stop" ] && playerctl --player=spotifyd stop && dunstify -I /usr/share/icons/Arc/emblems/symbolic/emblem-music-symbolic.svg -h string:x-dunst-stack-tag:music "$(playerctl --player=spotifyd status)"
[ "$1" = "next" ] && playerctl --player=spotifyd next #Notification is handled by spotifyd.conf
[ "$1" = "prev" ] && playerctl --player=spotifyd previous
