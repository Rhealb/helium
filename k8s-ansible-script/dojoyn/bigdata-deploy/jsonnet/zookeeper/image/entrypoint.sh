#!/bin/bash
set -e
if [ -z "${BD_SUITE_PREFIX}" ]; then
    echo "\${BD_SUITE_PREFIX} not set"
    exit 1
fi

if [ ! -f "$ZK_DATA_DIR/myid" ]; then
    echo "$SERVER_ID" > "$ZK_DATA_DIR/myid"
fi
function replacePara {
    sed -i "s|%ZK_PORT%|${ZK_PORT}|g" $ZOOKEEPER_CONF_DIR/zoo.cfg 
    sed -i "s|%ZK_DATA_DIR%|${ZK_DATA_DIR}|g" $ZOOKEEPER_CONF_DIR/zoo.cfg
    sed -i "s|%ZK_DATA_LOG_DIR%|${ZK_DATA_LOG_DIR}|g" $ZOOKEEPER_CONF_DIR/zoo.cfg
    sed -i "s|%ZK_TICK_TIME%|${ZK_TICK_TIME}|g" $ZOOKEEPER_CONF_DIR/zoo.cfg
    sed -i "s|%ZK_INIT_LIMIT%|${ZK_INIT_LIMIT}|g" $ZOOKEEPER_CONF_DIR/zoo.cfg
    sed -i "s|%ZK_SYNC_LIMIT%|${ZK_SYNC_LIMIT}|g" $ZOOKEEPER_CONF_DIR/zoo.cfg
}
cp -f /opt/mntcephutils/conf/* $ZOOKEEPER_CONF_DIR
replacePara
# add dynamic reconfiguration feature
if [ -f "$ZOOKEEPER_CONF_DIR/zoo.cfg" ]; then
    CONFIG="$ZOOKEEPER_CONF_DIR/zoo.cfg"
    if [ ! -z "$SERVER_ID" ] && [ ! -z "$MAX_SERVERS" ]; then
        echo "Starting up in clustered mode"
        echo "$SERVER_ID / $MAX_SERVERS"
        echo -n "" > /tmp/cfg
        for((i=1;i<=$MAX_SERVERS;i++));do
          echo "server.$i=${BD_SUITE_PREFIX}-zookeeper$i:2888:3888" >> "$CONFIG"
          echo "server.${i}=${BD_SUITE_PREFIX}-zookeeper${i}:2888:3888" >> /tmp/cfg
        done
        echo "addauth digest super:helium" > /tmp/cmd
        echo "reconfig -file /tmp/cfg" >> /tmp/cmd
        echo "" >> /tmp/cmd
    else
        echo "Starting up in standalone mode"
    fi
else
    echo "zoo.cfg doesn't exists, exiting..."
    exit 1
fi
cp -f /opt/mntcephutils/entry/reconfig.sh /opt/entry/reconfig.sh
chmod a+x /opt/entry/reconfig.sh
/opt/entry/reconfig.sh > /tmp/out 2>&1 &
echo "start server"
export SERVER_JVMFLAGS="-Dzookeeper.DigestAuthenticationProvider.superDigest=super:O32iwIbnp3zoU/NLNfoDg+8xe50="
zkServer.sh start-foreground
