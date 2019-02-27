#!/bin/bash

if [ -z "$SPARK_SERVER_TYPE" ]; then
    echo "\$SPARK_SERVER_TYPE not set"
    exit 1
fi
function replacePrefix {
    sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" ${SPARK_HOME}/conf/core-site.xml
    sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" ${SPARK_HOME}/conf/core-site.xml

    sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" ${SPARK_HOME}/conf/hdfs-site.xml
    sed -i "s/%BD_JOURNALNODE_SERVERS%/${BD_JOURNALNODE_SERVERS}/g" ${SPARK_HOME}/conf/hdfs-site.xml

    sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" ${SPARK_HOME}/conf/yarn-site.xml
    sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" $HADOOP_CONF_DIR/yarn-site.xml

    sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" ${SPARK_HOME}/conf/spark-env.sh
    sed -i "s|%BD_ENENTLOG_DIR%|${BD_ENENTLOG_DIR}|g" ${SPARK_HOME}/conf/spark-env.sh

    sed -i "s|%BD_ENENTLOG_DIR%|${BD_ENENTLOG_DIR}|g" ${SPARK_HOME}/conf/spark-defaults.conf
}

cp -f /opt/mntcephutils/conf/* ${SPARK_HOME}/conf/
replacePrefix
export HADOOP_CONF_DIR=${SPARK_HOME}/conf/
export SPARK_CONF_DIR=${SPARK_HOME}/conf/

if [ $(echo ${SPARK_SERVER_TYPE} | tr [A-Z] [a-z]) = "master" ]; then
    cp -rf /opt/mntcephutils/scripts /opt
    xinetd -f /opt/scripts/checkactive &
    echo "starting spark master......"
    start-master.sh
elif [ $(echo ${SPARK_SERVER_TYPE} | tr [A-Z] [a-z]) = "worker" ]; then
    echo "staring worker......"
    start-slave.sh spark://${BD_SPARK_MASTER_SERVERS}
elif [ $(echo ${SPARK_SERVER_TYPE} | tr [A-Z] [a-z]) = "historyserver" ]; then
    echo "starting spark historyserver......"
    start-history-server.sh
else
   echo "$SPARK_SERVER_TYPE is not valid"
   exit 1
fi

exec "$@"
