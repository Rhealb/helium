#!/bin/bash
sleep 10
success=0

while [ $success -eq 0 ];
do
    success=$(/opt/zookeeper/bin/zkCli.sh < /tmp/cmd 2>&1 | grep ${BD_SUITE_PREFIX}-zookeeper${SERVER_ID} | wc -l)
    echo $success
    sleep 1
done
echo exit
