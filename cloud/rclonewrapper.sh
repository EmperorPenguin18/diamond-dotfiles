#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
      echo "This script must be run as root"
      exit 1
fi

USER="$(ls /home)"
SERVICE=${1:-rclone.service}

rm /etc/systemd/system/rclone*.service
mkdir -p /home/$USER/.config/rclone
touch /home/$USER/.config/rclone/rclone.conf
su $USER -c "rclone config"

NUM=0
REMOTES="$(cat /home/$USER/.config/rclone/rclone.conf | grep ']')"
for I in $REMOTES
do
        NAME=$(echo $I | cut -c 2- | rev | cut -c 2- | rev)
        cp -f $SERVICE /etc/systemd/system/rclone$NUM.service
        sed -i "s/NAME/$NAME/g" /etc/systemd/system/rclone$NUM.service
        sed -i "s/USER/$USER/g" /etc/systemd/system/rclone$NUM.service
        mkdir /mnt/$NAME
        chown $USER:$USER /mnt/$NAME
        systemctl enable rclone$NUM

        NUM=$(expr $NUM + 1)
done
