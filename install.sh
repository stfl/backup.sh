#!/bin/bash

# install to /usr/bin/
sudo ln -sfv $(pwd)/backup.sh /usr/bin/ -sfv
sudo ln -sfv $(pwd)/backup_home.sh /usr/bin/ -sfv

# link .exclude-backup to home dir
ln -sfv $(pwd)/.exclude-backup ~

# enable for daily backup in crontab -e
# root
echo "sudo crontab -e"
echo "@daily			/usr/bin/backup.sh /media/data/backup/debian_rootfs_daily -q"

# stefan
echo "crontab -e"
echo "@daily			/usr/bin/backup_home.sh /media/data/backup/debian_home_daily -q"

