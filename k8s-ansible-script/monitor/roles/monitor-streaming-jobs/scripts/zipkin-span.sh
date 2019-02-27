#!/usr/bin/env bash

es_url=$1

#curl -XPUT 'http://10.19.140.200:31921/_template/enn-dependency:template' -d '{
curl -XPUT http://${es_url}/_template/zipkin:span_template -d \
'{
    "template": "zipkin:span*",
    "mappings": {
        "span": {
            "dynamic_templates": [{
                "strings": {
                    "match": "*",
                    "match_mapping_type": "string",
                    "mapping": {
                        "ignore_above": 256,
                        "norms": false,
                        "type": "keyword"
                    }
                }
            }],
            "properties": {
                "traceId": {
                    "type": "keyword"
                },
                "duration": {
                    "type": "long"
                },
                "id": {
                    "type": "keyword",
                    "ignore_above": 256
                },
                "shared": {
                    "type": "boolean"
                },
                "tags": {
                    "dynamic": "false",
                    "properties": {
                        "bizLine": {
                            "type": "keyword"
                        },
                        "instance": {
                            "type": "keyword"
                        },
                        "resource": {
                            "type": "keyword"
                        }
                    }
                },
                "timestamp": {
                    "type": "long"
                },
                "timestamp_millis": {
                    "type": "date",
                    "format": "epoch_millis"
                },
                "parentId": {
                    "type": "keyword",
                    "ignore_above": 256
                },
                "name": {
                    "type": "keyword"
                },
                "kind": {
                    "type": "keyword",
                    "ignore_above": 256
                },
                "remoteEndpoint": {
                    "dynamic": "false",
                    "properties": {
                        "serviceName": {
                            "type": "keyword"
                        }
                    }
                },
                "localEndpoint": {
                    "dynamic": "false",
                    "properties": {
                        "serviceName": {
                            "type": "keyword"
                        }
                    }
                },
                "annotations": {
                    "type": "object",
                    "enabled": false
                }
            }
        },
        "_default_": {
            "dynamic_templates": [{
                "strings": {
                    "match": "*",
                    "match_mapping_type": "string",
                    "mapping": {
                        "ignore_above": 256,
                        "norms": false,
                        "type": "keyword"
                    }
                }
            }]
        }
    }
  }'