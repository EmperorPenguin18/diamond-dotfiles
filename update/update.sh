#!/bin/sh

USER="$(ls /home)"

#Update system
pikaur -Syyuuq --noconfirm >output.txt 2>&1
firefox file:///home/$USER/output.txt

#Update dotfiles
git clone https://github.com/EmperorPenguin18/diamond-dotfiles /tmp/dotfiles
while IFS=, read -r input output; do
    cp -f /tmp/dotfiles/$1 $2
    if file -i $2 | grep shellscript; then
        chmod +x $2
    elif file $2 | grep font; then
        chmod 0444 $2
    else
        sed -i "s/USER/$USER/g" $2
    fi
done < /home/$USER/.config/files.csv

#Finish
reboot
