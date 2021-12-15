#!/bin/sh

calc(){ awk "BEGIN { print "$*" }"; }

[ "$1" = "int" ] && \
	dunstify -h string:x-dunst-stack-tag:internet \
	"Internet: $(nmcli -t c show --active | cut -f 1 -d ':')" \
	"Download: $(speedtest --no-upload --simple | awk '/^Download/ {print $2 " " $3}')" \
	"VPN status: $(mullvad status)" && \
	exit 0

[ "$1" = "mem" ] && \
	PROCS=$(ps axch -o cmd:15,%mem --sort=-%mem) && \
	TOTAL=$(free -m | awk '/^Mem:/ {print $2}') && \
	dunstify -h string:x-dunst-stack-tag:memory \
	"Memory usage: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')" \
	"$(echo "$PROCS" | head | awk "\$NF=\$NF/100*$TOTAL" | sed 's/$/Mi/g;s/\..*M/M/g' | rev | sed 's/ /~~~/' | rev | sed 's/ /%%%/g;s/~~~/  \t/;s/%%%/ /g')" && \
	exit 0

[ "$1" = "cpu" ] && \
	PROCS=$(ps axch -o cmd:15,%cpu --sort=-%cpu) && \
	dunstify -h string:x-dunst-stack-tag:cpu \
	"CPU Usage: $(calc $(echo "$PROCS" | awk '{print $NF}' | paste -sd+ | bc)/$(nproc))%" \
	"CPU Temp: $(sensors | awk '/^Package/ {print $4}')\n$(echo "$PROCS" | head | sed 's/$/%/')" && \
	exit 0
