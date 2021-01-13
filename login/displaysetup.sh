#!/bin/sh

NAME="$(xrandr | grep ' connected' | awk '{print $1}')"
COLUMNS="$(echo $NAME | awk '{print NF}' | sort -nu | tail -n 1)"
RESOLUTION="$(xrandr | sed "1,/$(echo $NAME | awk '{print $(NF)}')/d" | grep + | awk '{print $1}')"
REFRESH="$(xrandr | sed "1,/$(echo $NAME | awk '{print $(NF)}')/d" | grep + | sed 's/ /\n/g' | sort | tail -1)"

for i in $COLUMNS
do
	xrandr --output $(echo $NAME | awk "{print \$$i") --off
done
xrandr --output $(echo $NAME | awk '{print $(NF)}') --mode $RESOLUTION --refresh $REFRESH --primary
