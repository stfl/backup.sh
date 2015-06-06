#!/bin/bash

[ "$1" == "-h" ] && echo "Usage: $0 destination [addtional flags]" && exit 0

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ $# -lt 1 ]; then
    echo "No destination defined. Usage: $0 destination [addtional flags]" >&2
    exit 1
elif [ $# -gt 2 ]; then
    echo "Too many arguments. Usage: $0 destination [addtional flags]" >&2
    exit 1
elif [ ! -d "$1" ]; then
   mkdir -p "$1"
   if [ $? != "0" ]; then
      echo "Invalid path: $1" >&2
      exit 1
   fi
fi

case "$1" in
  "/mnt") ;;
  "/mnt/"*) ;;
  "/media") ;;
  "/media/"*) ;;
  "/run/media") ;;
  "/run/media/"*) ;;
  *) echo "Destination not allowed." >&2
     exit 1
     ;;
esac

if [ ! -z "$2" ]; then
   # f.e. --quiet -q
   addition_flags="$2"
fi

START=$(date +%s)
rsync -aAXhH --info=progress2 --delete $addition_flags --exclude={"/home/*","/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","swapfile*"} / "$1"
FINISH=$(date +%s)

echo "$(date '+%Y-%m-%d, %T, %A')" > $1/backup_from 
echo "total time: $(( ($FINISH-$START) / 60 )) minutes, $(( ($FINISH-$START) % 60 )) seconds" >> $1/backup_from 
