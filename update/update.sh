#!/bin/sh

USER="$(ls /home)"

#Update system
pikaur -Syyuuq --noconfirm >output.txt 2>&1
firefox file:///home/$USER/output.txt

#Update dotfiles
git clone https://github.com/EmperorPenguin18/diamond-dotfiles /tmp/dotfiles
while IFS=, read -r input output; do
    NUM=$(echo "$input" | grep -o '/' | wc -l)
    DIR=$(echo "$input" | cut -f -$NUM -d '/')
    FILE=$(echo "$input" | cut -f $(expr $NUM + 1) -d '/')
    NUM=$(echo "$output" | grep -o '/' | wc -l)
    DEST=$(echo "$output" | cut -f -$NUM -d '/')
        RENAME=$(echo "$2" | cut -f $(expr $NUM + 1) -d '/')
    cd "$DIR"
    for I in $(find . -type f -name "$FILE"); do
        [ -z "$RENAME" ] || I="$RENAME"
        cp -f /tmp/dotfiles/"$DIR"/"$I" "$DEST"/"$I"
        if file -i "$DEST"/"$I" | grep shellscript; then
            chmod +x "$DEST"/"$I"
        elif file "$DEST"/"$I" | grep font; then
            chmod 0444 "$DEST"/"$I"
        else
            sed -i "s/USER/$USER/g" "$DEST"/"$I"
        fi
    done
done < /home/$USER/.config/files.csv

#Finish
reboot
