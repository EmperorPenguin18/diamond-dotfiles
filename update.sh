#Backup system
btrfs subvolume snapshot / /home/sebastien/.snapshots/"$(echo date)"
rclone sync --config=/home/sebastien/.config/rclone/rclone.conf /home/sebastien/.snapshots onedriveschool:/Backups/

#Update system
curl 'https://www.archlinux.org/mirrorlist/?country=CA&protocol=http&protocol=https&ip_version=4' > /etc/pacman.d/mirrorlist
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
rankmirrors /etc/pacman.d/mirrorlist >> /etc/pacman.d/mirrorlist
yay -Syyuuq --combinedupgrade --noconfirm > output.txt
curl -X POST https://textbelt.com/text \
   --data-urlencode phone='6137200482' \
   --data-urlencode message=$(cat output.txt) \
   -d key=textbelt
rm output.txt

#Finish
reboot
