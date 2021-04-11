#!/bin/sh

DIRECTION="$1"
NUM=$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $NF}')

if [ "$DIRECTION" = "left" ]
then
	[ $NUM -eq 0 ] && NUM=4 || NUM=$(expr $NUM - 1)
elif [ "$DIRECTION" = "right" ]
then
	[ $NUM -eq 4 ] && NUM=0 || NUM=$(expr $NUM + 1)
else
	echo "Wrong argument"
	exit 1
fi

wmctrl -s $NUM && dunstify -h string:x-dunst-stack-tag:workspace $(expr $NUM + 1) && exit 0 || exit 1
