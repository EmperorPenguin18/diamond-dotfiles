#!/bin/sh

ACTION="$1"
NUM=$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $NF}')
ACTIVE=$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $NF}')

if [ "$ACTION" = "left" ]
then
        [ $NUM -eq 0 ] && NUM=4 || NUM=$(expr $NUM - 1)
        wmctrl -s $NUM && \
        dunstify -I /usr/share/icons/Arc/places/symbolic/start-here-symbolic.svg -h string:x-dunst-stack-tag:workspace $(expr $NUM + 1) && \
        exit 0
elif [ "$ACTION" = "right" ]
then
        [ $NUM -eq 4 ] && NUM=0 || NUM=$(expr $NUM + 1)
        wmctrl -s $NUM && \
        dunstify -I /usr/share/icons/Arc/places/symbolic/start-here-symbolic.svg -h string:x-dunst-stack-tag:workspace $(expr $NUM + 1) && \
        exit 0
elif [ "$ACTION" = "send-left" ]
then
        [ $NUM -eq 0 ] && NUM=4 || NUM=$(expr $NUM - 1)
        wmctrl -i -r $ACTIVE -t $NUM && \
        wmctrl -i -a $ACTIVE && \
        dunstify -I /usr/share/icons/Arc/places/symbolic/start-here-symbolic.svg -h string:x-dunst-stack-tag:workspace $(expr $NUM + 1) && \
        exit 0
elif [ "$ACTION" = "send-right" ]
then
        [ $NUM -eq 4 ] && NUM=0 || NUM=$(expr $NUM + 1)
        wmctrl -i -r $ACTIVE -t $NUM && \
        wmctrl -i -a $ACTIVE && \
        dunstify -I /usr/share/icons/Arc/places/symbolic/start-here-symbolic.svg -h string:x-dunst-stack-tag:workspace $(expr $NUM + 1) && \
        exit 0
elif [ "$ACTION" = "one" ]
then
        wmctrl -s 0 && \
        dunstify -I /usr/share/icons/Arc/places/symbolic/start-here-symbolic.svg -h string:x-dunst-stack-tag:workspace 1 && \
        exit 0
elif [ "$ACTION" = "two" ]
then
        wmctrl -s 1 && \
        dunstify -I /usr/share/icons/Arc/places/symbolic/start-here-symbolic.svg -h string:x-dunst-stack-tag:workspace 2 && \
        exit 0
elif [ "$ACTION" = "three" ]
then
        wmctrl -s 2 && \
        dunstify -I /usr/share/icons/Arc/places/symbolic/start-here-symbolic.svg -h string:x-dunst-stack-tag:workspace 3 && \
        exit 0
elif [ "$ACTION" = "four" ]
then
        wmctrl -s 3 && \
        dunstify -I /usr/share/icons/Arc/places/symbolic/start-here-symbolic.svg -h string:x-dunst-stack-tag:workspace 4 && \
        exit 0
elif [ "$ACTION" = "five" ]
then
        wmctrl -s 4 && \
        dunstify -I /usr/share/icons/Arc/places/symbolic/start-here-symbolic.svg -h string:x-dunst-stack-tag:workspace 5 && \
        exit 0
elif [ "$ACTION" = "fullscreen" ]
then
        wmctrl -r :ACTIVE: -b toggle,fullscreen && \
        exit 0
elif [ "$ACTION" = "close" ]
then
        wmctrl -c :ACTIVE: && \
        exit 0
else
        echo "Wrong argument"
fi

exit 1
