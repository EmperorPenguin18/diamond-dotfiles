#File manager
cd $@
output=$(ls -a | rofi -dmenu -p Files -i)
if [[ $output == ""]]; then exit 1; fi
if [ -d $output ]; then /home/sebastien/rofi.sh $output; fi
if [ -f $output ]; then xdg-open $output; fi
