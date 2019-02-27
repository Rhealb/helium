#!/bin/bash
sleep 10
target=40
num=0
$@
while (( $? ))
do
  sleep 10
  let "num+=1"
#  echo "$num"
  if [ $num == $target ]; then
    echo "fail"
    break
  fi
  $@
done