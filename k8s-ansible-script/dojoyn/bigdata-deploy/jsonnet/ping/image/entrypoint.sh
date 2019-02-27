#!/bin/bash
set -e
function replacePrefix {
    sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" /opt/kafka2hdfs/conf/core-site.xml
    sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" /opt/kafka2hdfs/conf/hdfs-site.xml
    sed -i "s/%BD_JOURNALNODE_SERVERS%/${BD_JOURNALNODE_SERVERS}/g" /opt/kafka2hdfs/conf/hdfs-site.xml
    sed -i "s/%BD_KAFKA_SERVERS%/${BD_KAFKA_SERVERS}/g" /opt/kafka2hdfs/conf/kafka2hdfs.conf
    sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" /opt/kafka2hdfs/conf/kafka2hdfs.conf
}
cp -f /opt/mntcephutils/conf/* /opt/kafka2hdfs/conf
replacePrefix
cd /opt/kafka2hdfs
java -jar lib/kafka2hdfs*jar io.he2.kafka2hdfs.Kafka2Hdfs ./conf/kafka2hdfs.conf
