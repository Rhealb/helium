#!/bin/bash
set -e
cp -f /opt/mntcephutils/conf/* /opt/kafka-manager/conf/
sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" /opt/kafka-manager/conf/application.conf
cd /opt/kafka-manager && bin/kafka-manager -Dconfig.file=conf/application.conf
