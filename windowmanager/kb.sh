#!/bin/sh

USER="$(ls /home)"

fgrep "bind" /home/$USER/.spectrwm.conf | sed -n 's/.*= //p' > /home/$USER/kb.txt && sed -i 's/MOD/Super/g' /home/$USER/kb.txt && sed -i 's/Mod1/Alt/g' /home/$USER/kb.txt
