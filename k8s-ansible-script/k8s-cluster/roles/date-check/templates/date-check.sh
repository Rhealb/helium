#!/bin/bash

curr_time=$(date +%s)
water_mark={{ current_localtime.stdout.strip() }}

diff=$(( $curr_time - $water_mark ))


if [ $diff -gt 60 ]
then
  echo "current time $curr_time is skewed to the furture too much from water mark $water_mark"
  exit 1
fi

if [ $diff -lt -10 ]
then
  echo "current time $curr_time is skewed to the past too much from water mark $water_mark"
  exit 1
fi


echo "Target node time is within acceptable region given the base water mark."
exit 0
