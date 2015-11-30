#!/bin/bash

usage(){
   echo "Usage: $0 [options]"
   echo "-h | --help"
   echo "-s | --src        Source directory which will be backed up (use without trailing /)"
   echo "-d | --dest       Destination dir where the backup will be stored"
   echo "-r | --restore    Restore the backupt -s <backup location> -d <restore dest>"
   echo "-c | --cycle      Update the tail of cycling backups. Not recomendet for snapshots"
   echo "                  [not yet implemented]"
   echo "-a | --add        Addition flags passed to rsync like \"-q --dry-run --delete-excluded...\""
   echo "-e | --exclude    Exclude file"
   exit 1
}

# if [ "$(id -un)" != "stefan" ]; then
   # echo "This script can (currently) only run by user 'stefan'" 1>&2
   # exit 1
# fi

SRC="$HOME/" # default src for root backup

EXCLUDE_FILE=$HOME/.exclude-backup

while [[ $# > 0 ]]
do
key="$1"

case $key in
    -h|--help)
       usage
    ;;
    -s|--src)
       SRC="$2"
       src_set=true
       if [ "/" != "${SRC: -1}" ]; then
          read -rsp $"no trailing / in SRC. add now? (Y/n): " -n1 inp
          if [ "$inp" != "n" ]; then
             SRC="$SRC/"
          fi
          echo ""
       fi
       shift
    ;;
    -d|--dst)
       DEST="$2"
       shift
    ;;
    -r|--restore)
       RESTORE=true
    ;;
    -c|--cycle)
       echo "cycling not yet implemented"
       CYCLE=true
       shift
    ;;
    -a|--add)
       ADDITION_FLAGS=$2
       shift
    ;;
    -e|--exclude)
       EXCLUDE_FILE=$2
       if [ ! -e $EXCLUDE_FILE ]; then
          echo "Exclude file can't be found" >&2
          exit 1
       fi
       shift
    ;;
    *)
       echo "unknown argument $key"
       usage
    ;;
esac
shift
done

if [ $RESTORE ] && ([ ! $src_set ] || [ -z ${DEST+x} ]); then
   echo "restore mode requires -s and -d" >&2
   usage
fi

mkdir -p "$DEST"
if [ "$?" != "0" ]; then
   echo "Invalid path: $DEST" >&2
   exit 1
fi

if [ ! -d "$SRC" ]; then
   echo "Invalid source $SRC" >&2
      exit 1
elif [ $RESTORE ] && [ ! -e $SRC/backup_from ]; then
   echo "this is not of my backups - no \$SRC/backup_from found"
   read -rsp $"continue anyway? (y/N): " -n1 cont
   if [ "y" != "$cont" ]; then
      exit
   fi
   echo ""
fi

if [ ! $RESTORE ]; then
   case "$DEST" in
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
fi

START=$(date +%s)
echo "rsync -aAXhHS --info=progress2 --delete $ADDITION_FLAGS \
      --exclude-from $EXCLUDE_FILE \
      $SRC $DEST"
FINISH=$(date +%s)

if [ ! $RESTORE ]; then
   touch $DEST # update mtime
   echo "$(date '+%Y-%m-%d, %T, %A')" > $DEST/backup_from
   echo "total time: $(( ($FINISH-$START) / 60 )) minutes, $(( ($FINISH-$START) % 60 )) seconds" >> $DEST/backup_from
else
   rm $DEST/backup_from -f
   # removing the backup_from when restoring
fi

exit 0
