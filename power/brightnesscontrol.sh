#!/bin/sh

[ "$1" = "up" ] && light -A 5 && dunstify -I /usr/share/icons/Arc/status/symbolic/brightness-display-symbolic.svg -h string:x-dunst-stack-tag:brightness "Brightness: $(light -G)%"
[ "$1" = "down" ] && light -U 5 && dunstify -I /usr/share/icons/Arc/status/symbolic/brightness-display-symbolic.svg -h string:x-dunst-stack-tag:brightness "Brightness: $(light -G)%"
