#!/bin/sh
#
# Clean up the mess left with dns ANY capture processes.
#
# o Remove any files that are only 24 bytes long.
# o move all files into proper YYYY/MM/DD/HH subdirectories.
#
# author: chris@as701.net
# gplv2-ish.
# 
ARCHIVE_DIR=/prod/docs.as701.net/dnsany
BELOW_MIN_LEN="-size -25c -a -size +0c -a -type f"
ABOVE_MIN_LEN="-size +25c -a -type f"
STORE_DIR=/prod/logs/caps
MKDIR=$(which mkdir)
MV=$(which mv)
RM=$(which rm)

while getopts ":s:a:" opt; do
  case ${opt} in
    s)
      STORE_DIR=${OPTARG}
      ;;
    a)
      ARCHIVE_DIR=${OPTARG}
      ;;
    *)
      echo "Usage: $0 -s <storageloc> -a <archiveloc>"
      exit
      ;;
  esac
done

if [ ! -d ${ARCHIVE_DIR} ] ; then
  ${MKDIR} ${ARCHIVE_DIR}
fi

# First remove all too-small files.
echo 'Removing files:'
for file in $( find ${STORE_DIR} ${BELOW_MIN_LEN} ); do
  echo $file
  ${RM} ${file}
done

echo 'Moving files:'
# Find all qualifying files, set to rename and then move.
for file in $( find ${STORE_DIR} ${ABOVE_MIN_LEN} ); do
  OLDDIR=$(dirname $file)
  OLDFILE=$(basename $file)
  DATEGRP=$(echo $OLDFILE | sed  's/^[a-z_A-Z]*-\([0-9]*\)-\([0-9]*\)-\([0-9]*\)-\([0-9]*\):\(.*\)$/\1\/\2\/\3\/\4/')
  NEWFILE="${ARCHIVE_DIR}/${DATEGRP}/${OLDFILE}"
  if [ ! -d ${ARCHIVE_DIR}/${DATEGRP} ] ; then
    ${MKDIR} -p ${ARCHIVE_DIR}/${DATEGRP} 
  fi
  echo "$file -> "
  echo "    ${NEWFILE}"
  ${MV} ${file} ${NEWFILE}
done
