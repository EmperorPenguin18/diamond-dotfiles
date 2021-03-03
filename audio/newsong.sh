#!/bin/sh

wget -O /tmp/album.png $(playerctl --player=spotifyd metadata | awk '/artUrl/ {print $3}')

DATA="$(playerctl --player=spotifyd metadata --format '{{ title }}|{{ album }}|{{ artist }}')"
TITLE="$(echo $DATA | cut -f 1 -d '|')"
ALBUM="$(echo $DATA | cut -f 2 -d '|')"
ARTIST="$(echo $DATA | cut -f 3 -d '|')"

TEXT=$(echo -e "Title:" "$TITLE" "\nAlbum:" "$ALBUM" "\nArtist:" "$ARTIST")
dunstify -I /tmp/album.png -h string:x-dunst-stack-tag:music "$TEXT"
