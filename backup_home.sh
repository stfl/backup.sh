#!/bin/bash

[ $1 == "-h" ] && echo "Usage: $0 destination [addtional flags]"

if [ "$(id -un)" != "stefan" ]; then
   echo "This script can (currently) only run by user 'stefan'" 1>&2
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
rsync -aAXhHS --info=progress2 --delete $addition_flags --exclude-from '/home/stefan/.exclude-backup' /home/stefan/ "$1"
FINISH=$(date +%s)
echo "$(date '+%Y-%m-%d, %T, %A')" > $1/backup_from 
echo "total time: $(( ($FINISH-$START) / 60 )) minutes, $(( ($FINISH-$START) % 60 )) seconds" >> $1/backup_from 

