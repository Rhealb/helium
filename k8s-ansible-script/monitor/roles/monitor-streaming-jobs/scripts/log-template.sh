#!/usr/bin/env bash

es_url=$1

#curl -XPUT 'http://10.19.140.200:31921/_template/enn-dependency:template' -d '{
curl -XPUT http://${es_url}/_template/template_1 -d '{
  "template": "{{ cluster_name }}-*",
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
          "type": "date",
          "format": "dateOptionalTime"
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
