#!/usr/bin/env bash

es_url=$1

#curl -XPUT 'http://10.19.140.200:31921/_template/enn-dependency:template' -d '{
curl -XPUT http://${es_url}/_template/enn-dependency:template -d '{
  "template": "enn-dependency-*",
  "mappings": {
    "trace-aggregate": {
      "properties": {
        "callee_svc": {
          "type": "keyword"
        },
        "callee_biz": {
          "type": "keyword"
        },
        "callee_ins": {
          "type": "keyword"
        },
        "callee_res": {
          "type": "keyword"
        },
        "caller_svc": {
          "type": "keyword"
        },
        "caller_biz": {
          "type": "keyword"
        },
        "caller_ins": {
          "type": "keyword"
        },
        "caller_res": {
          "type": "keyword"
        }
      }
    }
  }
}'
