#!/bin/bash
set -e
AMAH_HOME=/opt/amah
AMAH_CONF=${AMAH_HOME}/conf
AMAH_LIBS=${AMAH_HOME}/libs
CONF_FILE_NAME="zk.properties"
AMAH_CONF_FILE=${AMAH_CONF}/${CONF_FILE_NAME}

if [ -z "$BD_JMX_SERVERS" ]; then
    echo "\$BD_JMX_SERVERS not set"
    exit 1
fi

if [ -z "$BD_ZK_SERVERS" ]; then
    echo "\$BD_ZK_SERVERS not set"
    exit 1
fi
function replacePrefix {
  sed -i "s/%BD_ZK_SERVERS%/${BD_ZK_SERVERS}/g" ${AMAH_CONF_FILE}
  sed -i "s/%BD_JMX_SERVERS%/${BD_JMX_SERVERS}/g" ${AMAH_CONF_FILE}
}
cp -f /opt/mntcephutils/conf/${CONF_FILE_NAME} ${AMAH_CONF}
replacePrefix
java -Xmx512m -cp "${AMAH_LIBS}/*" io.helium.amah.cli.CliMain ${AMAH_CONF_FILE}
