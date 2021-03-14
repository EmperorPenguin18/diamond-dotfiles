#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
      echo "This script must be run as root"
      exit 1
fi

USER="$(ls /home)"
REMOTES="$(cat /home/$USER/.config/rclone/rclone.conf | grep ']')"
DIR=$1

NUM=0
for I in $REMOTES
do
        NAME=$(echo $I | cut -c 2- | rev | cut -c 2- | rev)
        cp -f $DIR/cloud/rclone.service /etc/systemd/system/rclone$NUM.service
        sed -i "s/NAME/$NAME/g" /etc/systemd/system/rclone$NUM.service
        sed -i "s/USER/$USER/g" /etc/systemd/system/rclone$NUM.service
        mkdir /mnt/$NAME
        systemctl enable rclone$NUM

        NUM=$(expr $NUM + 1)
done
