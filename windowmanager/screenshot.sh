#!/bin/sh

USER="$(ls /home)"
NUM="$(ls /home/$USER/Downloads | grep screen | wc -l)"
RESOLUTION="$(xdpyinfo | grep 'dimensions:' | cut -f 7 -d ' ')"

ffmpeg -f x11grab -video_size $RESOLUTION -i $DISPLAY -vframes 1 /home/$USER/Downloads/screen$NUM.png
dunstify "Screenshot saved as ~/Downloads/screen$NUM.png"
