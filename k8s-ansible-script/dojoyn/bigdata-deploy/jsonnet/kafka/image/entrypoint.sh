#!/bin/bash
set -e
if [ -z "${KAFKA_BROKER_ID}" ]; then
    echo "\${KAFKA_BROKER_ID} not set"
    exit 1
fi
if [ -z "${ZOOKEEPER_SERVERS}" ]; then
    echo "\${ZOOKEEPER_SERVERS} not set"
    exit 1
fi
function replacePrefix {
    sed -i "s/%KAFKA_BROKER_ID%/${KAFKA_BROKER_ID}/g" ${KAFKA_CONF_DIR}/server.properties
    sed -i "s/%ZOOKEEPER_SERVERS%/${ZOOKEEPER_SERVERS}/g" ${KAFKA_CONF_DIR}/server.properties
}
cp -f /opt/mntcephutils/conf/* ${KAFKA_CONF_DIR}/
replacePrefix

KAFKACONF="${KAFKA_CONF_DIR}/server.properties"
if [ "${BD_KAFKA_EXSERVICETYPE}" == "ClusterIP" ]; then
  echo "advertised.listeners=PLAINTEXT://${BD_KAFKA_AD_LISTERNERS}" >> "${KAFKACONF}"
elif [ "${BD_KAFKA_EXSERVICETYPE}" == "NodePort" ] && [ "${BD_KAFKA_EXBROKERPORT}" != "" ]; then
  echo "advertised.listeners=PLAINTEXT://${BD_KAFKA_AD_LISTERNERS}" >> "${KAFKACONF}"
else
  echo "advertised.listeners=PLAINTEXT://$HOSTNAME.$BD_NAMESPACE:2181" >> "${KAFKACONF}"
fi
JMX_PORT=${BD_KAFKA_JMX_PORT} kafka-server-start.sh ${KAFKACONF}

exec "$@"
