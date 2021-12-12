#!/bin/sh

USER="$(ls /home)"
NUM="$(ls /home/$USER/Downloads | grep screen | wc -l)"
RESOLUTION="$(xdpyinfo | grep 'dimensions:' | cut -f 7 -d ' ')"

edit_action () {
	gimp /home/$USER/Downloads/screen$NUM.png
}

handle_dismiss () {
	exit 0
}

ffmpeg -f x11grab -video_size $RESOLUTION -i $DISPLAY -vframes 1 /home/$USER/Downloads/screen$NUM.png
ACTION=$(dunstify --action="default,Edit" "Screenshot saved as ~/Downloads/screen$NUM.png")

case "$ACTION" in
	"default")
		edit_action
		;;
	"2")
		handle_dismiss
		;;
esac
