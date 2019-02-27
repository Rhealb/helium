#!/bin/bash
set -e

if [ -z "${ES_HOME}" ]; then
  echo "\${ES_HOME} not set"
  exit 1
fi
if [ -z "${JAVA_HOME}" ]; then
  echo "\${JAVA_HOME} not set"
  exit 1
fi
if [ -z "${BD_MAX_MAP_COUNT}" ]; then
  echo "\${BD_MAX_MAP_COUNT} not set"
fi
function replaceVar {
  sed -i "s/%BD_JAVA_XMS%/${BD_JAVA_XMS}/g" ${ES_HOME}/config/jvm.options
  sed -i "s/%BD_JAVA_XMX%/${BD_JAVA_XMX}/g" ${ES_HOME}/config/jvm.options
}

#copy config file
cp -f /opt/mntcephutils/conf/* ${ES_HOME}/config/
replaceVar
mv -f ${ES_HOME}/config/java.policy $JAVA_HOME/jre/lib/security
mv -f ${ES_HOME}/config/limits.conf /etc/security/

if [ -z "${BD_MAX_MAP_COUNT}" ] || [ ${BD_MAX_MAP_COUNT} -lt 262144 ]; then
  echo "BD_MAX_MAP_COUNT should be greater than 262144"
  echo "set BD_MAX_MAP_COUNT to min value(262144)"
  BD_MAX_MAP_COUNT=262144
fi

max_map_count=$(sysctl vm.max_map_count | awk -F "=" '{print $2}')
if [[ $max_map_count -lt ${BD_MAX_MAP_COUNT} ]]; then
  sysctl -w vm.max_map_count=${BD_MAX_MAP_COUNT}
fi

# add user elasticsearch
groupadd elasticsearch && useradd elasticsearch -g elasticsearch -p 1
chown -R elasticsearch:elasticsearch ${ES_HOME} && chown -R elasticsearch:elasticsearch /opt/${ES_NAME}

cd ${ES_HOME}
su elasticsearch -c 'bin/elasticsearch'
