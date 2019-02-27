#!/bin/bash

java -cp /opt/experimental-0.0.1-ALPHA-SNAPSHOT-jar-with-dependencies.jar cn.enncloud.dojoyn.experimental.samplecase.JoinerService --lookup-service-host pre1-lookupservice1 --lookup-service-port 50051 --mongodb-database-name TEST --joiner-service-host pre1-joiner1 --mongodb-server pre1-mongodb1:27017 --joiner-service-port 23377
