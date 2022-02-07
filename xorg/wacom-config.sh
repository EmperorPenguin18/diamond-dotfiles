#!/bin/sh

for i in $(seq 10); do
    if xsetwacom list devices | grep -q Wacom; then
        break
    fi
    sleep 1
done

list=$(xsetwacom list devices)
pad=$(echo "${list}" | awk '/pad/{print $7}')
stylus=$(echo "${list}" | xsetwacom list devices | awk '/stylus/{print $7}')

if [ -z "${pad}" ]; then
    exit 0
fi

xsetwacom set "${stylus}" Button 1 11
xsetwacom set "${stylus}" Button 2 12
xsetwacom set "${pad}" Button 1 13
xsetwacom set "${pad}" Button 2 14
xsetwacom set "${pad}" Button 3 15
xsetwacom set "${pad}" Button 4 16
