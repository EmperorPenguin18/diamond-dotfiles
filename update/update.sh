#!/bin/sh

#Update system
yay -Syyuuq --combinedupgrade --noconfirm > output.txt
#*Send output*
rm output.txt

#Finish
reboot
