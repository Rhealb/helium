#!/bin/bash

if [ -z "$HADOOP_SERVER_TYPE" ]; then
    echo "\$HADOOP_SERVER_TYPE not set"
    exit 1
fi

function replacePrefix {
  sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" $HADOOP_CONF_DIR/core-site.xml
  sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" $HADOOP_CONF_DIR/hdfs-site.xml
  sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" $HADOOP_CONF_DIR/yarn-site.xml
  sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" $HADOOP_CONF_DIR/mapred-site.xml
  sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" $HADOOP_CONF_DIR/core-site.xml
  sed -i "s/%BD_ZOOKEEPER_SERVERS%/${BD_ZOOKEEPER_SERVERS}/g" $HADOOP_CONF_DIR/yarn-site.xml
  sed -i "s/%BD_JOURNALNODE_SERVERS%/${BD_JOURNALNODE_SERVERS}/g" $HADOOP_CONF_DIR/hdfs-site.xml
  sed -i "s|%BD_TMPDIRLIST%|${BD_TMPDIRLIST}|g" $HADOOP_CONF_DIR/core-site.xml
  sed -i "s|%BD_DATADIRLIST%|${BD_DATADIRLIST}|g" $HADOOP_CONF_DIR/hdfs-site.xml
}
cp -f /opt/mntcephutils/conf/* $HADOOP_CONF_DIR/
replacePrefix
hadoopservertype=$(echo ${HADOOP_SERVER_TYPE} | tr [A-Z] [a-z])

if [ ${hadoopservertype} = "namenode" ]; then
  cp -rf /opt/mntcephutils/scripts /opt
  chmod +x /opt/scripts/*
  xinetd -f /opt/scripts/nncheckactive &
  echo "starting namenode......"
  /usr/bin/expect <<-EOF
  spawn hdfs --config $HADOOP_CONF_DIR zkfc -formatZK
  expect "Proceed formatting /hadoop-ha/enncloud-hadoop? (Y or N)"
  send "N\r"
  expect eof
EOF

  if [ ! -d /hdfs/dfs/name/current ]; then
    /usr/bin/expect <<-EOF
    spawn hdfs --config $HADOOP_CONF_DIR namenode -format
    expect {
      -re "Re-format filesystem in QJM to .*\\(Y or N\\)" {
        send "N\r"
        spawn hdfs --config $HADOOP_CONF_DIR namenode -bootstrapStandby
      }
    }
    expect eof
EOF
  fi
  hadoop-daemon.sh start zkfc
  nohup /bin/bash /opt/scripts/checkzkfc.sh 2>&1 &
  hdfs --config $HADOOP_CONF_DIR namenode

elif [ ${hadoopservertype} = "namenode-standby" ]; then
    cp -rf /opt/mntcephutils/scripts /opt
    chmod +x /opt/scripts/*
    xinetd -f /opt/scripts/nncheckactive &
    sed -i 's|<value>nn1<\/value>|<value>nn2<\/value>|' $HADOOP_CONF_DIR/hdfs-site.xml
    echo "starting namenode-standby....."
    if [ ! -d /hdfs/dfs/name/current ]; then
       hdfs --config $HADOOP_CONF_DIR namenode -bootstrapStandby
    fi
    hadoop-daemon.sh start zkfc
    nohup /bin/bash /opt/scripts/checkzkfc.sh 2>&1 &
    hdfs --config $HADOOP_CONF_DIR namenode

elif [ ${hadoopservertype} = "datanode" ] || [ ${hadoopservertype} = "journalnode" ]; then
     echo "starting ${hadoopservertype}......"
     hdfs --config $HADOOP_CONF_DIR ${hadoopservertype}
elif [ ${hadoopservertype} = "resourcemanager1" ] || [ ${hadoopservertype} = "resourcemanager2" ]; then
    cp -rf /opt/mntcephutils/scripts /opt
    chmod +x /opt/scripts/*
    xinetd -f /opt/scripts/rmcheckactive &
    if [ ${hadoopservertype} = "resourcemanager1" ]; then
      echo "starting resourcemanager1......"
    else
      sed -i 's|<value>rm1<\/value>|<value>rm2<\/value>|' $HADOOP_CONF_DIR/yarn-site.xml
      echo "starting resourcemanager2......"
    fi
    yarn --config $HADOOP_CONF_DIR resourcemanager
elif [ ${hadoopservertype} = "nodemanager" ]; then
    echo "staring nodemanager......"
    yarn --config $HADOOP_CONF_DIR nodemanager

elif [ ${hadoopservertype} = "mrjobhistory" ]; then
    echo 'export HADOOP_PREFIX=$HADOOP_HOME' >> $HADOOP_CONF_DIR/hadoop-env.sh
    cp -f /opt/mntcephutils/scripts/mr-jobhistory-daemon.sh $HADOOP_HOME/sbin/
    chmod +x $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh
    echo "starting mapreduce job history server......"
    mr-jobhistory-daemon.sh start historyserver nodaemon
else
    echo "\$HADOOP_SERVER_TYPE is not valid"
    exit 1
fi

exec "$@"
