#!/bin/bash
set -e
SHC=`which shc`
if [ -z $SHC ]; then
  echo "please install shc"
  exit 1
fi
find cephutils/ | grep "\.sh" | grep -v mr-jobhistory-daemon.sh > scriptnamelist
shlines=$(cat scriptnamelist | wc -l)
for (( i = 1; i <= ${shlines}; i++ )); do
  shellscript=$(cat scriptnamelist | sed -n "${i}p")
  if [ $(echo $shellscript | awk -F "/" '{print $3}') != "conf" ]; then
    $SHC -f $shellscript -o $shellscript -r 
  fi
  echo "$shellscript"
done
rm -f scriptnamelist
find cephutils/ | grep ".x.c" | xargs rm -f 
