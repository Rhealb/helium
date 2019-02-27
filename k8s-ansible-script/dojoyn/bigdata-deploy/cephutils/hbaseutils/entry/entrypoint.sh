#!/bin/bash
set -e

if [ -z "$HBASE_SERVER_TYPE" ]; then
  echo "\$HBASE_SERVER_TYPE not set"
  exit 1
fi
if [ -z "$BD_HMASTER_PERMSIZE" ]; then
  echo "\$BD_HMASTER_PERMSIZE is not set"
  exit 1
fi
if [ -z "$BD_HMASTER_MAXPERMSIZE" ]; then
  echo "\$BD_HMASTER_MAXPERMSIZE is not set"
  exit 1
fi
if [ -z "$BD_HMASTER_XMX" ]; then
  echo "\$BD_HMASTER_XMX is not set"
  exit 1
fi
if [ -z "$BD_HREGIONSERVER_PERMSIZE" ]; then
  echo "\$BD_HREGIONSERVER_PERMSIZE is not set"
  exit 1
fi
if [ -z "$BD_HREGIONSERVER_MAXPERMSIZE" ]; then
  echo "\$BD_HREGIONSERVER_MAXPERMSIZE is not set"
  exit 1
fi
if [ -z "$BD_HREGIONSERVER_XMX" ]; then
  echo "\$BD_HREGIONSERVER_XMX is not set"
  exit 1
fi
function replacePrefix {
  sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" $HBASE_HOME/conf/hdfs-site.xml
  sed -i -e "s/%ZKNAME%/${ZKNAME}/g"  $HBASE_HOME/conf/hbase-site.xml
  sed -i -e "s/%HOSTNAME%/${HOSTNAME}/g" $HBASE_HOME/conf/hbase-site.xml
}
cp -f /opt/mntcephutils/conf/* $HBASE_HOME/conf/
replacePrefix

if [ $(echo ${HBASE_SERVER_TYPE} | tr [A-Z] [a-z]) = "master" ]; then
  cp -rf /opt/mntcephutils/scripts /opt
  chmod +x /opt/scripts/*
  xinetd -f /opt/scripts/checkactive &
  hbase master start
elif [ $(echo ${HBASE_SERVER_TYPE} | tr [A-Z] [a-z]) = "regionserver" ]; then
  hbase regionserver start
fi

exec "$@"
