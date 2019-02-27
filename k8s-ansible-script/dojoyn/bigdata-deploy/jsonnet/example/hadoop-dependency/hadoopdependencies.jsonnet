{
  local globalconf = import "../global_config.jsonnet",

  local suiteprefix = globalconf.suiteprefix,
  prefix:: if suiteprefix == "" then
                 ""
               else
                 suiteprefix + "-",

  local zookeeperconf = globalconf.zookeeper,
  local hadoopconf = globalconf.hadoop,
  local hdfsconf = hadoopconf.hdfs,
  local yarnconf = hadoopconf.yarn,
  local type = "Deployment",

  items: [ 
      // namenode1 (namenode) dependends on journalnode
      {   
        name: $.prefix + "namenode1",
        namespace: globalconf.namespace,
        kind: type,
        exec: "check",
        container: [$.prefix + "namenode1",],
        dependentsOn: [
          {
            dependentType: "dns",
            parameters: {
              serviceName: $.prefix + "journalnode" + jnnum,
              namespace: globalconf.namespace,
              port: "8485",
            },
          } for jnnum in std.range(1, hdfsconf.journalnode.instancecount)
        ],
      },  
    ] + [
      // namenode1 (namenode) dependends on zookeeper
      {
        name: $.prefix + "namenode1",
        namespace: globalconf.namespace,
        kind: type,
        exec: "check",
        container: [$.prefix + "namenode1",],
        dependentsOn: [
          {
            dependentType: "dns",
            parameters: {
              serviceName: zksvc,
              namespace: globalconf.namespace,
              port: "2181",
            },
          } for zksvc in [
            $.prefix + "zookeeper" + zknum for zknum in std.range(1, zookeeperconf.instancecount)
          ]
        ],
      },
    ] + [
      // namenode2 (namenode-standby) dependends on namenode1
      {
        name: $.prefix + "namenode2",
        namespace: globalconf.namespace,
        kind: type,
        exec: "check",
        container: [$.prefix + "namenode2",],
        dependentsOn: [
          {
            dependentType: "dns",
            parameters: {
              serviceName: $.prefix + "namenode1",
              namespace: globalconf.namespace,
              port: "8020",
            },
          },
        ],
      },
    ] + [
      // resourcemanager1 dependends on zookeeper
      {
        name: $.prefix + "resourcemanager1",
        namespace: globalconf.namespace,
        kind: type,
        exec: "check",
        container: [ $.prefix + "resourcemanager1",],
        dependentsOn: [
          {
            dependentType: "dns",
            parameters: {
              serviceName: zksvc,
              namespace: globalconf.namespace,
              port: "2181",
            },
          } for zksvc in [
             $.prefix + "zookeeper" + zknum for zknum in std.range(1, zookeeperconf.instancecount)
          ]
        ],
      },
    ] + [
      // resourcemanager2 dependends on resourcemanager1
      {
        name:  $.prefix + "resourcemanager2",
        namespace: globalconf.namespace,
        kind: type,
        exec: "check",
        container: [ $.prefix + "resourcemanager2",],
        dependentsOn: [
          {
            dependentType: "dns",
            parameters: {
              serviceName: $.prefix + "resourcemanager1",
              namespace: globalconf.namespace,
              port: "8088",
            },
          }
        ],
      },
    ] + [
      // mrjobhistoryserver dependends on namenode1 & namenode2
      {
        name:  $.prefix + "mrjobhistory",
        namespace: globalconf.namespace,
        kind: type,
        exec: "check",
        container: [ $.prefix + "mrjobhistory",],
        dependentsOn: [
          {
            dependentType: "dns",
            parameters: {
              serviceName: nnsvc,
              namespace: globalconf.namespace,
              port: "8020",
            },
          } for nnsvc in [
             $.prefix + "namenode" + nnnum for nnnum in std.range(1, hdfsconf.namenode.instancecount)
          ]
        ],
      },
    ],
}
