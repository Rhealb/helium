#!/bin/bash

if [ -z "${DRUID_SERVER_TYPE}" ]; then
    echo "\${DRUID_SERVER_TYPE} not set"
    exit 1
fi
function replacePrefix {
    sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" ${DRUID_HOME}/conf/druid/_common/core-site.xml
    sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" ${DRUID_HOME}/conf/druid/_common/hdfs-site.xml
    sed -i "s/%BD_JOURNALNODE_SERVERS%/${BD_JOURNALNODE_SERVERS}/g" ${DRUID_HOME}/conf/druid/_common/hdfs-site.xml
    sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" ${DRUID_HOME}/conf/druid/_common/yarn-site.xml
    sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" ${DRUID_HOME}/conf/druid/_common/yarn-site.xml
    sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" ${DRUID_HOME}/conf/druid/_common/mapred-site.xml
    sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" ${DRUID_HOME}/conf/druid/_common/common.runtime.properties
    sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" ${DRUID_HOME}/conf/druid/_common/common.runtime.properties
    sed -i "s/%BD_MYSQL_PASSWD%/${BD_MYSQL_PASSWD}/g" ${DRUID_HOME}/conf/druid/_common/common.runtime.properties
    sed -i "s/%BD_MYSQL_USERNAME%/${BD_MYSQL_USERNAME}/g" ${DRUID_HOME}/conf/druid/_common/common.runtime.properties
}
cp -rf /opt/mntcephutils/conf/* ${DRUID_HOME}/conf/druid/
replacePrefix
cd ${DRUID_HOME}
mkdir -p ${DRUID_HOME}/var/tmp
TYPES="historical broker coordinator overlord middleManager"
for TYPE in $TYPES; do
    if [ $(echo ${DRUID_SERVER_TYPE} | tr [A-Z] [a-z]) = $(echo $TYPE | tr [A-Z] [a-z]) ]; then
        echo "starting druid $TYPE......"        
        java `cat ${DRUID_CONF_DIR}/druid/${TYPE}/jvm.config | xargs` -cp "${DRUID_CONF_DIR}/druid/_common:${DRUID_CONF_DIR}/druid/${TYPE}:lib/*" io.druid.cli.Main server ${TYPE}
        exec "$@"
        exit 0
    fi
done

echo "$DRUID_SERVER_TYPE is not valid"
exit 1
