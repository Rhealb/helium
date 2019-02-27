{
  local globalconf = import "../global_config.jsonnet",

  local suiteprefix = globalconf.suiteprefix,
  prefix:: if suiteprefix == "" then
                 ""
               else
                 suiteprefix + "-",

  local zookeeperconf = globalconf.zookeeper,
  local kafkaconf = globalconf.kafka,
  local type = "Deployment",

  items: [
      // kafka dependends on zookeeper
      {
        name: $.prefix + "kafka" + kafkanum,
        namespace: globalconf.namespace,
        kind: type,
        exec: "check",
        container: [$.prefix + "kafka" + kafkanum,],
        dependentsOn: [
          {
            dependentType: "dns",
            parameters: {
              serviceName: zksvc,
              namespace: globalconf.namespace,
              port: "2181"
            },
          } for zksvc in [
            $.prefix + "zookeeper" + zknum for zknum in std.range(1, zookeeperconf.instancecount)
          ]
        ],
      } for kafkanum in std.range(1, kafkaconf.instancecount)
    ],
}
