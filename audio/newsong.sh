#!/bin/sh

USER="$(ls /home)"

DATA="$(playerctl --player=spotifyd metadata --format '{{ title }}|{{ album }}|{{ artist }}|{{ mpris:artUrl }}|{{ mpris:trackid }}')"
TITLE="$(echo $DATA | cut -f 1 -d '|')"
ALBUM="$(echo $DATA | cut -f 2 -d '|')"
ARTIST="$(echo $DATA | cut -f 3 -d '|')"
wget -O /tmp/album.png "$(echo $DATA | cut -f 4 -d '|')"

TEXT=$(echo -e "Title:" "$TITLE" "\nAlbum:" "$ALBUM" "\nArtist:" "$ARTIST")
dunstify -I /tmp/album.png -h string:x-dunst-stack-tag:music "$TEXT"

echo $DATA >> /home/$USER/.config/spotifyd/library.txt
cat /home/$USER/.config/spotifyd/library.txt | sort -u -o /home/$USER/.config/spotifyd/library.txt
