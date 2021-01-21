#!/bin/sh

USER="$(ls /home)"

#Update system
pikaur -Syyuuq --noconfirm >output.txt 2>&1
firefox file:///home/$USER/output.txt

#Finish
reboot
