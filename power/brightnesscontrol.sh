#!/bin/sh

[ "$1" = "up" ] && light -A 5 && dunstify -h string:x-dunst-stack-tag:brightness "Brightness: $(light -G)%"
[ "$1" = "down" ] && light -U 5 && dunstify -h string:x-dunst-stack-tag:brightness "Brightness: $(light -G)%"
