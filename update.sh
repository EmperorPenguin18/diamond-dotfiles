#Update system
yay -Syyuuq --combinedupgrade --noconfirm > output.txt
curl -X POST https://textbelt.com/text \
   --data-urlencode phone='6137200482' \
   --data-urlencode message=$(cat output.txt) \
   -d key=textbelt
rm output.txt

#Finish
reboot
