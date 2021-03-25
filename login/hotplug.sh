#!/bin/sh

USER=$(ls /home)
export DISPLAY=:0
export XAUTHORITY=/home/$USER/.Xauthority
source /home/$USER/.config/scripts/displaysetup
