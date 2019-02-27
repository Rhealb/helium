#!/bin/bash
set -e
if [ -z ${BD_ZK_SERVERS} ]; then
  echo "env BD_ZK_SERVERS not set "
  exit 1
fi
WORKDIR=`cd $(dirname $0) && pwd`
echo $WORKDIR
echo hostname=$HOSTNAME
if [ ! -d "/redis-cluster-utils/$HOSTNAME" ]; then
  mkdir -p /redis-cluster-utils/$HOSTNAME
fi
if [ ! -d "/redis-cluster-data/$HOSTNAME" ]; then
  mkdir -p /redis-cluster-data/$HOSTNAME
fi
if [ ! -f "/redis-cluster-utils/$HOSTNAME/redis.conf" ]; then
  cp /opt/mntcephutils/conf/redis.conf /redis-cluster-utils/$HOSTNAME/redis.conf
  sed -i "s/#HOSTNAME#/$HOSTNAME/g" /redis-cluster-utils/$HOSTNAME/redis.conf
fi
if [ -s "/redis-cluster-utils/$HOSTNAME/redis.conf" ]; then
  rm -f /redis-cluster-utils/$HOSTNAME/redis.conf
  cp /opt/mntcephutils/conf/redis.conf /redis-cluster-utils/$HOSTNAME/redis.conf
  sed -i "s/#HOSTNAME#/$HOSTNAME/g" /redis-cluster-utils/$HOSTNAME/redis.conf
fi
java -jar /opt/entrypoint-0.2.0.jar ${BD_ZK_SERVERS} /usr/bin/ redis-server /redis-cluster-utils/$HOSTNAME/redis.conf
