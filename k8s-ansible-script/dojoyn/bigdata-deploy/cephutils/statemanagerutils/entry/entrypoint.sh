#!/bin/bash

java -cp /opt/experimental-0.0.1-ALPHA-SNAPSHOT-jar-with-dependencies.jar cn.enncloud.dojoyn.experimental.samplecase.StateManagerService --mongodb-server pre1-mongodb1:27017 --joiner-grpc-port 23377 --joiner-grpc-host pre1-joiner1 --mongodb-database-name TEST --retry-kafka-servers pre1-kafka1:9092
