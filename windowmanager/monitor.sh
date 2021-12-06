#!/bin/sh

[ "$1" = "int" ] && dunstify -h string:x-dunst-stack-tag:internet "Internet: $(nmcli -t c show --active | cut -f 1 -d ':')" "Download: $(speedtest --no-upload --simple | awk '/^Download/ {print $2 " " $3}')" "VPN status: $(mullvad status)" && exit 0
[ "$1" = "mem" ] && dunstify -h string:x-dunst-stack-tag:memory "Memory usage: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')" "$(ps axch -o cmd:15,%mem --sort=-%mem | head | sed 's/$/%/')" && exit 0
[ "$1" = "cpu" ] && dunstify -h string:x-dunst-stack-tag:cpu "CPU Usage: $(mpstat | sed 's/ /\n/g' | sed 'N;s/\n/ /;0,/all/d' | sed -r 's/\s+//g;/^\s*$/d' | head -n -1 | paste -sd+ | bc)%" "CPU Temp: $(sensors | awk '/^Package/ {print $4}')\n$(ps axch -o cmd:15,%cpu --sort=-%cpu | head | sed 's/$/%/')" && exit 0
