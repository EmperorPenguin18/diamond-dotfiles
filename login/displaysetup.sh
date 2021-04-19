#!/bin/sh

XRANDR="$(xrandr)"
NAME=$(echo "$XRANDR" | awk '/ connected/ {print $1}')
PRIMARY=$(echo $NAME | awk '{print $(NF)}')
RESOLUTION=$(echo "$XRANDR" | grep + | sed "1,/$PRIMARY/d;1p" | awk '{print $1}')
REFRESH=$(echo "$XRANDR" | grep + | sed "1,/$PRIMARY/d;1p;s/ /\\n/g;s/*//g;s/+//g" | sort | tail -1)

for I in $NAME
do
        xrandr --output $I --off
done
xrandr --output $PRIMARY --mode $RESOLUTION --refresh $REFRESH --primary #--set TearFree on

TEXT=$(echo -e "$(echo $NAME | awk '{print $(NF)}')\n$RESOLUTION\n$REFRESH")
dunstify -I /usr/share/icons/Arc/devices/symbolic/video-display-symbolic.svg "$TEXT"
