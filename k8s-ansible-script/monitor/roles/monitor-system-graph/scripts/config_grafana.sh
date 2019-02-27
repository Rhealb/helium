#!/bin/bash

curl -X POST -H 'content-type: application/json' \
-u {{ admin_username }}:{{ admin_password }}  http://{{ master_list[0] }}:29008/api/datasources \
-d '{
      "name":"Promethous",
      "type": "prometheus",
      "url":"http://prometheus-engine1.monitor-application:9090",
      "access":"proxy",
      "basicAuth":false
    }'

curl -X POST -H 'content-type: application/json' \
-u {{ admin_username }}:{{ admin_password }} http://{{ master_list[0] }}:29008/api/dashboards/import \
-d '{"dashboard":{"__inputs":[{"name":"DS_PROMETHEUS","label":"ennprometheus","description":"","type":"datasource","pluginId":"prometheus","pluginName":"Prometheus"}],"__requires":[{"type":"grafana","id":"grafana","name":"Grafana","version":"4.4.3"},{"type":"datasource","id":"prometheus","name":"Prometheus","version":"1.0.0"},{"type":"panel","id":"table","name":"Table","version":""}],"annotations":{"list":[]},"editable":true,"gnetId":null,"graphTooltip":0,"hideControls":false,"id":null,"links":[],"refresh":"10s","rows":[{"collapse":false,"height":null,"panels":[{"columns":[{"text":"Current","value":"current"}],"datasource":"${DS_PROMETHEUS}","fontSize":"100%","height":"885px","id":1,"links":[],"pageSize":null,"scroll":true,"showHeader":true,"sort":{"col":1,"desc":true},"span":3,"styles":[{"dateFormat":"YYYY-MM-DD HH:mm:ss","pattern":"Time","type":"date"},{"colorMode":"row","colors":["rgba(50, 172, 45, 0.97)","rgba(237, 129, 40, 0.89)","rgba(245, 54, 54, 0.9)"],"decimals":0,"pattern":"Current","thresholds":["1","2"],"type":"number","unit":"short"}],"targets":[{"aggregator":"sum","downsampleAggregator":"avg","downsampleFillPolicy":"none","downsampleInterval":"","expr":"min_over_time(script_success{job=\"services\"}[2m])","format":"time_series","intervalFactor":2,"legendFormat":"{{ '{{ instance }}' }}","refId":"A","step":2}],"title":"service-monitor","transform":"timeseries_aggregations","type":"table"}],"repeat":null,"repeatIteration":null,"repeatRowId":null,"showTitle":false,"title":"Dashboard Row","titleSize":"h6"}],"schemaVersion":14,"style":"dark","tags":[],"templating":{"list":[]},"time":{"from":"now-1m","to":"now"},"timepicker":{"refresh_intervals":["5s","10s","30s","1m","5m","15m","30m","1h","2h","1d"],"time_options":["5m","15m","1h","6h","12h","24h","2d","7d","30d"]},"timezone":"browser","title":"service-monitor","version":1},"overwrite":true,"inputs":[{"name":"DS_PROMETHEUS","type":"datasource","pluginId":"prometheus","value":"Promethous"}]}'
