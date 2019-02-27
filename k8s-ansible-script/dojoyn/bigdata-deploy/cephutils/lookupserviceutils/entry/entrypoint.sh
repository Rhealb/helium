#!/bin/bash

java -cp /opt/experimental-0.0.1-ALPHA-SNAPSHOT-jar-with-dependencies.jar cn.enncloud.dojoyn.experimental.samplecase.LookupService --lookup-service-port 50051 --server-thread-num 1 --lookup-service-batch-size 10 --lookup-service-query-threads 1 --lookup-service-flush-threads 1

