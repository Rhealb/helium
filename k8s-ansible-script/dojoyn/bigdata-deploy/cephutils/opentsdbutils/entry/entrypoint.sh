#!/bin/bash
set -e

test -d /etc/opentsdb || mkdir -p /etc/opentsdb
rm -f /etc/opentsdb/*
cp -f /opt/mntcephutils/conf/* /etc/opentsdb
sed -i -e "s|%JVMOPTIONS%|$JVMOPTIONS|g" /usr/share/opentsdb/bin/tsdb
sed -i -e "s|%HOSTNAME%|$HOSTNAME|g" /etc/opentsdb/opentsdb.conf
sed -i -e "s|%ZOOKEEPER_SERVERS%|$ZOOKEEPER_SERVERS|g" /etc/opentsdb/opentsdb.conf
tsdb tsd
