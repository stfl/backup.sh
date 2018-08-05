#!/bin/bash

dest="/media/backup"

START=$(date +%s)

#can't backup rootfs - need to be root!
#backup home
/usr/bin/backup_home.sh $dest/home_daily

#backup Music -> RPi
#backup Pictures -> RPi
#backup Projects
# git commit?! 

FINISH=$(date +%s)

echo "$(date '+%Y-%m-%d, %T, %A')" > $dest/backup_daily 
echo "total time: $(( ($FINISH-$START) / 60 )) minutes, $(( ($FINISH-$START) % 60 )) seconds" >> $1/backup_from 
