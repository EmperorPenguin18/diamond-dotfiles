#!/bin/sh

[ "$1" = "mute" ] && pactl set-sink-mute 0 toggle && dunstify -h string:x-dunst-stack-tag:volume "$(pactl list sinks | grep Mute)"
[ "$1" = "up" ] && pactl set-sink-volume 0 +5% && dunstify -h string:x-dunst-stack-tag:volume "Volume $(pactl list sinks | grep Volume | cut -f 2 -d '/' | sed -n '1p')"
[ "$1" = "down" ] && pactl set-sink-volume 0 -5% && dunstify -h string:x-dunst-stack-tag:volume "Volume $(pactl list sinks | grep Volume | cut -f 2 -d '/' | sed -n '1p')"
[ "$1" = "play" ] && playerctl --player=spotifyd play-pause && dunstify -h string:x-dunst-stack-tag:music "$(playerctl --player=spotifyd status)"
[ "$1" = "stop" ] && playerctl --player=spotifyd stop && dunstify -h string:x-dunst-stack-tag:music "$(playerctl --player=spotifyd status)"
[ "$1" = "next" ] && playerctl --player=spotifyd next && dunstify -h string:x-dunst-stack-tag:music "$(playerctl --player=spotifyd metadata --format 'Title: {{ title }} Album: {{ album }} Artist: {{ artist }}')"
[ "$1" = "prev" ] && playerctl --player=spotifyd previous && dunstify -h string:x-dunst-stack-tag:music "$(playerctl --player=spotifyd metadata --format 'Title: {{ title }} Album: {{ album }} Artist: {{ artist }}')"
