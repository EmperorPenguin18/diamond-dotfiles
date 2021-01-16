#!/bin/sh

USER="$(ls /home)"

#Update system
pikaur -Syyuuq --noconfirm >output.txt 2>&1
#*Password*
firefox file:///home/$USER/output.txt

#Finish
reboot
