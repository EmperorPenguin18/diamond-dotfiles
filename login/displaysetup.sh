#!/bin/sh

NAME="$(xrandr | grep ' connected' | awk '{print $1}')"
RESOLUTION="$(xrandr | sed "1,/$(echo $NAME | awk '{print $(NF)}')/d" | grep + | sed -n '1p' | awk '{print $1}')"
REFRESH="$(xrandr | sed "1,/$(echo $NAME | awk '{print $(NF)}')/d" | grep + | sed -n '1p' | sed 's/ /\n/g' | sort | tail -1)"

for I in $NAME
do
	xrandr --output $I --off
done
xrandr --output $(echo $NAME | awk '{print $(NF)}') --mode $RESOLUTION --refresh $REFRESH --primary #--set TearFree on
