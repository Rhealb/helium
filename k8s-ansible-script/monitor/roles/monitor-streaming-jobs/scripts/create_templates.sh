#!/usr/bin/env bash

# env=$1
# if [ $env == "shanghai" ]; then
#     es_url="10.19.140.200:31921"
# elif [ $env == "yancheng" ]; then
#     es_url="10.19.248.200:31921"
# fi
es_url="pre1-esclient-ex.monitor-essential-service:9200"

echo $es_url

./log-template.sh $es_url
./enn-dependency.sh $es_url
./enn-trace-log.sh $es_url
./svc-resource-histograms.sh $es_url
./svc-resource-instance-percentiles.sh $es_url
./svc-resource-percentiles.sh $es_url
./zipkin-span.sh $es_url
