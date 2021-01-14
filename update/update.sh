#!/bin/sh

#Update system
pikaur -Syyuuq --noconfirm >output.txt 2>&1
#*Password*
#*Send output*
rm output.txt

#Finish
reboot
