#!/usr/bin/env bash

es_url=$1

#curl -XPUT 'http://10.19.140.200:31921/_template/enn-dependency:template' -d '{
curl -XPUT http://${es_url}/_template/enn-service-resource-histogram:template -d '{
  "template": "enn-service-resource-histogram-*",
  "mappings": {
    "trace-stats": {
      "properties": {
        "bizLine": {
          "type": "keyword"
        },
        "service": {
          "type": "keyword"
        },
        "resource": {
          "type": "keyword"
        }
      }
    }
  }
}'