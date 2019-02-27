#!/bin/bash

esclient_nodeport='{{ elasticsearch_nodeports_httpport }}'
nodeportlist=(${esclient_nodeport//,/ })
virtual_ip={{ master_list[0] }}
URL=()
for url in ${nodeportlist[@]}
do
  drurl=${url//\"}
  URL+=("${virtual_ip}:${drurl}")
done

CURL="curl"
CHECK_URL="http://${URL[0]}/_template/template_1"

${CURL} -m 10 -u elastic:changeme -XPUT ${CHECK_URL} -d '{
  "template": "*",
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1
  },
  "mappings": {
    "log_type": {
      "_source": {
        "enabled": false
      },
      "properties": {
        "dateTime": {
          "type": "date"
        },
        "createTime": {
          "type": "date"
        },
        "logLevel": {
          "type": "keyword"
        },
        "logType": {
          "type": "keyword"
        },
        "clusterName": {
          "type": "keyword"
        },
        "nodeName": {
          "type": "ip"
        },
        "appName": {
          "type": "keyword"
        },
        "nameSpace": {
          "type": "keyword"
        },
        "podName": {
          "type": "keyword"
        },
        "position": {
          "type": "text"
        },
        "pid": {
          "type": "keyword"
        },
        "threadName": {
          "type": "text"
        },
        "traceId": {
          "type": "keyword"
        },
        "parentPod": {
          "type": "keyword"
        },
        "log": {
          "type": "text"
        },
        "token": {
          "type": "keyword"
        }
      }
    }
  }
}'
