#!/bin/bash
set -e
PING_HOME=/opt/ping
function replacePrefix {
    sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" ${PING_HOME}/conf/core-site.xml
    sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" ${PING_HOME}/conf/hdfs-site.xml
    sed -i "s/%BD_JOURNALNODE_SERVERS%/${BD_JOURNALNODE_SERVERS}/g" ${PING_HOME}/conf/hdfs-site.xml
    sed -i "s/%BD_KAFKA_SERVERS%/${BD_KAFKA_SERVERS}/g" ${PING_HOME}/conf/kafka2hdfs.conf
    sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" ${PING_HOME}/conf/kafka2hdfs.conf
}
cp -f /opt/mntcephutils/conf/* ${PING_HOME}/conf/
replacePrefix
java -cp ${PING_HOME}/kafka2hdfs.jar:/opt/ping/lib/* io.he2.kafka2hdfs.Main ${PING_HOME}/conf/kafka2hdfs.conf
