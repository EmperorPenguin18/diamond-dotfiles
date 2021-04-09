#!/bin/sh

CAPACITY=$(/usr/bin/cat /sys/class/power_supply/BAT0/capacity)
STATUS=$(/usr/bin/cat /sys/class/power_supply/BAT0/status)

[ $CAPACITY -le 10 ] && [ $STATUS = "Discharging" ] && /usr/bin/dunstify "Warning: Critical battery (<10%)" && exit 0
[ $CAPACITY -le 25 ] && [ $STATUS = "Discharging" ] && /usr/bin/dunstify "Warning: Low battery (<25%)" && exit 0
