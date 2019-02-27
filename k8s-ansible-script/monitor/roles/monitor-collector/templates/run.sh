#!/bin/bash

umount /data/docker/containers/*/shm

# 需要判断是否有拿到nodename
nodename=`curl --insecure -u $USERNAME:$PASSWD $APIURL/api/v1/namespaces/$NAMESPACE/pods/$HOSTNAME | jq ".spec.nodeName" | sed -s -e "s/\"//g"`

cp /opt/conf/fluent-bit.conf /opt

sed -i "s/%NODENAME%/$nodename/g" /opt/fluent-bit.conf
sed -i "s/%CLUSTERNAME%/$CLUSTERNAME/g" /opt/fluent-bit.conf
sed -i "s/%GATEWAYSERVER%/$GATEWAYSERVER/g" /opt/fluent-bit.conf
sed -i "s/%GATEWAYPORT%/$GATEWAYPORT/g" /opt/fluent-bit.conf
sed -i "s#%DOCKERPATH%#$DOCKERPATH#g" /opt/fluent-bit.conf

/opt/fluent-bit/bin/fluent-bit -c /opt/fluent-bit.conf
