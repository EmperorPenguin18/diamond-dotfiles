#!/bin/sh

USER="$(ls /home)"
REMOTES="$(cat .config/rclone/rclone.conf | grep ']')"

for I in $REMOTES
do
        
done

#cp -f $DIR/cloud/rclone1.service /etc/systemd/system/rclone1.service
#cp -f $DIR/cloud/rclone2.service /etc/systemd/system/rclone2.service
#cp -f $DIR/cloud/rclone3.service /etc/systemd/system/rclone3.service
#mkdir /mnt/Personal
#mkdir /mnt/School
#mkdir /mnt/Media
#systemctl enable rclone1
#systemctl enable rclone2
#systemctl enable rclone3
