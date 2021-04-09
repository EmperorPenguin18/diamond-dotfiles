#!/bin/sh

[ "$1" = "check" ] && acpi | head -1 | grep Discharging && xscreensaver & || killall xscreensaver
[ "$1" = "true" ] && xscreensaver &
[ "$1" = "false" ] && killall xscreensaver
