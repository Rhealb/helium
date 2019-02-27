#!/bin/bash
function replacePrefix {/core-site.xml
  sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" ${TRANQUILITY_HOME}/conf/server.json
  sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" ${TRANQUILITY_HOME}/conf/kafka.json
}
cp -rf /opt/mntcephutils/conf/* ${TRANQUILITY_HOME}/conf/

tranquility server -configFile ${TRANQUILITY_HOME}/conf/server.json
#tranquility server -configFile ${TRANQUILITY_HOME}/conf/kafka.json
exec "$@"
