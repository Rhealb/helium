#!/bin/bash
if [ -z "$HBASE_SERVER_TYPE" ]; then
    echo "\$HBASE_SERVER_TYPE not set"
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
    xinetd -f /opt/scripts/checkactive &
    hbase master start
elif [ $(echo ${HBASE_SERVER_TYPE} | tr [A-Z] [a-z]) = "regionserver" ]; then
    hbase regionserver start
fi

exec "$@"
