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
elif [ "$ACTION" = "close" ]
then
        wmctrl -c :ACTIVE: && \
        exit 0
else
        echo "Wrong argument"
fi

exit 1
