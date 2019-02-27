{
  namespace: "dojoyn",
  suiteprefix: "pre1",

  // location use "yancheng" or "shanghai" or "langfang" or "aws" or "aliyun"
  location: "shanghai",

  // deploytype use "podservice" or "storage"
  deploytype: "podservice",

  // exservicetype use "ClusterIP" or "NodePort" or "None"
  exservicetype: "NodePort",

  // utilsstoretype use "FS" or "ConfigMap"
  utilsstoretype: "FS",

  // componentoramah use "component" or "amah" or "both"
  componentoramah: "component",

  // "CephFS" for ceph or "EFS" for aws or "NFS" for aliyun
  mountdevtype: "CephFS",

  // ceph address
  // yancheng ceph address: "10.19.248.27:6789,10.19.248.28:6789,10.19.248.29:6789,10.19.248.30:6789"
  // shanghai ceph address: "10.19.137.144:6789,10.19.137.145:6789,10.19.137.146:6789"
  // langfang ceph address: "10.38.240.29:6789,10.38.240.30:6789,10.38.240.31:6789,10.38.240.32:6789,10.38.240.33:6789"
  cephaddress: "10.19.248.27:6789,10.19.248.28:6789,10.19.248.29:6789,10.19.248.30:6789",

  // nfs address
  // aws nfs:"fs-df45b5a6.efs.us-east-2.amazonaws.com"
  // aliyun nfs: "398de48d04-qar32.cn-shanghai.nas.aliyuncs.com"
  nfsaddress: "fs-df45b5a6.efs.us-east-2.amazonaws.com",

  registry: if $.location == "shanghai" then
               "127.0.0.1:29006"
             else if $.location == "yancheng" then
               "10.19.248.12:30100"
             else if $.location == "langfang" then
               "10.38.240.34:30100"
             else if $.location == "aws" then
               "127.0.0.1:30100"
             else if $.location == "aliyun" then
               "127.0.0.1:30100"
             else
               error "error location type",

  externalips: if $.location == "shanghai" then
                 ["10.19.137.140", "10.19.137.141", "10.19.137.142"]
               else if $.location == "yancheng" then
                 ["10.19.248.13", "10.19.248.14", "10.19.248.15"]
               else
                 ["10.38.240.29", "10.38.240.30", "10.38.240.31"],

  elasticsearch: {
    image: $.registry + "/tools/centos7-elasticsearch-6.1.0:0.1-lbsheng",
    exservicetype: $.exservicetype,
    esdatastoragesize: "1Gi",
    externalports: {
      httpports: [29200 + i for i in std.range(0, $.elasticsearch.client.instancecount)],
      transports: [29300 + i for i in std.range(0, $.elasticsearch.client.instancecount)],
    },
    nodeports: {
      httpports: ["" for count in std.range(1, $.elasticsearch.client.instancecount)],
      transports: ["" for count in std.range(1, $.elasticsearch.client.instancecount)],
    },
    master: {
      instancecount: 3,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      javaxms: "1g",
      javaxmx: "1g",
    },

    data: {
      instancecount: 3,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      javaxms: "1g",
      javaxmx: "1g",
    },
    client: {
      instancecount: 3,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      javaxms: "1g",
      javaxmx: "1g",
    },
  },

  haproxy: {
    image: $.registry + "/tools/dockerio-haproxy-1.7.0-alpine:0.3-lbsheng",
    exservicetype: $.exservicetype,
    instancecount: 1,
    requestcpu: "0",
    requestmem: "0",
    limitcpu: "0",
    limitmem: "0",
    externalports: {
      hawebports: [10800 + i for i in std.range(0, $.haproxy.instancecount - 1)],
      sparkuiports: [9999 + i for i in std.range(0, $.haproxy.instancecount - 1)],
      hdfsuiports: [9998 + i for i in std.range(0, $.haproxy.instancecount - 1)],
      hbaseuiports: [9997 + i for i in std.range(0, $.haproxy.instancecount - 1)],
      overlorduiports: [8090 + i for i in std.range(0, $.haproxy.instancecount - 1)],
      coordinatoruiports: [8081 + i for i in std.range(0, $.haproxy.instancecount - 1)],
    },
    nodeports: {
      hawebports: ["" for count in std.range(1, $.haproxy.instancecount)],
      sparkuiports: ["" for count in std.range(1, $.haproxy.instancecount)],
      hdfsuiports: ["" for count in std.range(1, $.haproxy.instancecount)],
      hbaseuiports: ["" for count in std.range(1, $.haproxy.instancecount)],
      overlorduiports: ["" for count in std.range(1, $.haproxy.instancecount)],
      coordinatoruiports: ["" for count in std.range(1, $.haproxy.instancecount)],
    },
  },

  mysql: {
    creatdbstart: "false",
    databases: ["druid",],
    image: $.registry + "/tools/dep-centos7-mysql-5.7.18:0.2-lbsheng",
    exservicetype: $.exservicetype,
    instancecount: 1,
    mysqldatapvcstoragesize: "5Gi",
    requestcpu: "300m",
    requestmem: "1Gi",
    limitcpu: "1",
    limitmem: "2Gi",
    password: "123456",
    externalports: {
      mysqlports: [3306 + i for i in std.range(0, $.mysql.instancecount - 1)],
    },
     nodeports: {
      mysqlports: [30015],
    },
  },

  druid: {
    plyql: {
      image: $.registry + "/tools/dep-centos7-plyql-0.11.2:0.4-lbsheng",
      exservicetype: $.exservicetype,
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        mysqlgatewayports: [3306 + i for i in std.range(0, $.druid.plyql.instancecount - 1)],
      },
       nodeports: {
        mysqlgatewayports: ["" for count in std.range(1, $.druid.plyql.instancecount)],
      },
    },
    origin: {
      mysqlusername: "root",
      mysqlpasswd: "123456",
      image: $.registry + "/tools/dep-centos7-druid-0.10.0:0.1-lbsheng",
      exservicetype: $.exservicetype,
      externalports: {
        brokerports: [8082 + i*2 for i in std.range(0, $.druid.origin.broker.instancecount - 1)],
        coordports: [8081 + i*2 for i in std.range(0, $.druid.origin.coordinator.instancecount - 1)],
        overlordports: [8090 + i for i in std.range(0, $.druid.origin.overlord.instancecount - 1)],
      },
      nodeports: {
        brokerports: ["" for count in std.range(1, $.druid.origin.broker.instancecount)],
        coordports: ["" for count in std.range(1, $.druid.origin.coordinator.instancecount)],
        overlordports: ["" for count in std.range(1, $.druid.origin.overlord.instancecount)],
      },
      broker: {
        instancecount: 1,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
      coordinator: {
        instancecount: 1,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
      historical: {
        histsegmentcachepvcstoragesize: "200Mi",
        instancecount: 1,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
      middlemanager: {
        mmsegmentsstoragesize: "200Mi",
        instancecount: 1,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
      overlord: {
        instancecount: 1,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
    },
    tranquility: {
      image: $.registry + "/tools/dep-centos7-tranquility-0.8.2:0.1-lbsheng",
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
    },
  },

  hadoop: {
    hdfs: {
      image: $.registry + "/tools/dep-centos7-hadoop-2.7.4:0.1-lbsheng",
      exservicetype: $.exservicetype,
      datadirpvcstoragesize: "50Gi",
      specusepvcstoragesize: "500Mi",
      datadirstoragecount:: 4,
      externalports: {
        nnhttpports: [52070 + i for i in std.range(0, $.hadoop.hdfs.namenode.instancecount - 1)],
      },
      nodeports: {
        nnhttpports: [29470,29471],
      },
      namenode: {
        instancecount: 2,
        requestcpu: "300m",
        requestmem: "1Gi",
        limitcpu: "1",
        limitmem: "2Gi",
      },
      journalnode: {
        instancecount: 3,
        requestcpu: "300m",
        requestmem: "1Gi",
        limitcpu: "1",
        limitmem: "2Gi",
      },
      datanode: {
        instancecount: 3,
        requestcpu: "1",
        requestmem: "2Gi",
        limitcpu: "2",
        limitmem: "4Gi",
      },
    },
    yarn: {
      image: $.registry + "/tools/dep-centos7-hadoop-2.7.4:0.1-lbsheng",
      exservicetype: $.exservicetype,
      hostpathpvcstoragesize: "500Mi",
      rmtmpdirpvcstoragesize: "100Mi",
      nmtmpdirpvcstoragesize: "100Mi",
      tmpdirstoragecount:: 4,
      externalports: {
        yarnhttpports: [28088 + i for i in std.range(0, $.hadoop.yarn.resourcemanager.instancecount - 1)],
        jhshttpports: [29888 + i for i in std.range(0, $.hadoop.yarn.mrjobhistory.instancecount - 1)],
      },
      nodeports: {
        yarnhttpports: ["" for count in std.range(1, $.hadoop.yarn.resourcemanager.instancecount)],
        jhshttpports: ["" for count in std.range(1, $.hadoop.yarn.mrjobhistory.instancecount)],
      },
      resourcemanager: {
        instancecount: 2,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
      nodemanager: {
        instancecount: 3,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
      mrjobhistory: {
        instancecount: 1,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
    },
  },

  hbase: {
    image: $.registry + "/tools/dep-centos7-hbase-1.2.6:0.1-lbsheng",
    exservicetype: $.exservicetype,
    tsdbttl: 2592000,
    externalports: {
      masterhttpports: [36010 + i for i in std.range(0, $.hbase.master.instancecount - 1)],
    },
    nodeports: {
      masterhttpports: [29472,29473,29474],
    },
    master: {
      instancecount: 3,
      requestcpu: "300m",
      requestmem: "1Gi",
      limitcpu: "1",
      limitmem: "2Gi",
      permsize: "128m",
      maxpermsize: "128m",
      javaxmx: "1g",
    },
    regionserver: {
      instancecount: 3,
      requestcpu: "300m",
      requestmem: "2Gi",
      limitcpu: "2",
      limitmem: "4Gi",
      permsize: "128m",
      maxpermsize: "128m",
      javaxmx: "2g",
    },
  },

  kafka: {
    image: $.registry + "/tools/dep-centos7-kafka-2.11-0.10.1.1:0.1-lbsheng",
    exservicetype: $.exservicetype,
    instancecount: 3,
    requestcpu: "300m",
    requestmem: "1Gi",
    limitcpu: "1",
    limitmem: "2Gi",
    logpvcstoragesize: "10Gi",
    externalports: {
      brokerports: [29092 + i for i in std.range(0, $.kafka.instancecount - 1)],
      jmxports: [29999 + i for i in std.range(0, $.kafka.instancecount - 1)],
    },
    nodeportip: "10.19.248.200",
    nodeports: {
      brokerports: [29479,29480,29481],
      jmxports: ["" for count in std.range(1, $.kafka.instancecount)],
    },
    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-kafka-2.11-0.10.1.1:ary-beta-1.0.5",
      exservicetype: $.exservicetype,
      kafkainstancecount: $.kafka.instancecount,
      replicas: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        amahports:[8084,],
      },
      nodeports: {
        amahports:["",],
      },
     },
  },

  kafkamanager: {
    image: $.registry + "/tools/kafka-manager:0.1-lbsheng",
    exservicetype: $.exservicetype,
    instancecount: 1,
    requestcpu: "0",
    requestmem: "0",
    limitcpu: "0",
    limitmem: "0",
    externalports: {
      httpports: [9000 + i for i in std.range(0, $.kafkamanager.instancecount - 1)],
    },
    nodeports: {
      httpports: ["" for count in std.range(1, $.kafkamanager.instancecount)],
    },
  },

  opentsdb: {
    image: $.registry + "/tools/opentsdb-2.3.0:beta-0.4",
    exservicetype: $.exservicetype,
    instancecount: 1,
    requestcpu: "0",
    requestmem: "0",
    limitcpu: "0",
    limitmem: "0",
    logpvcstoragesize: "50Mi",
    javaxmx: "2g",
    javaxms: "2g",
    externalports: {
      httpports: [33117 + i for i in std.range(0, $.opentsdb.instancecount - 1)],
      jmxports: [33218 + i for i in std.range(0, $.opentsdb.instancecount - 1)],
    },
    nodeports: {
      httpports: ["" for count in std.range(1, $.opentsdb.instancecount)],
      jmxports: ["" for count in std.range(1, $.opentsdb.instancecount)],
    },
  },

  spark: {
    image: $.registry + "/tools/dep-centos7-spark-2.1.1-hadoop-2.7:0.1-lbsheng",
    exservicetype: $.exservicetype,
    workerworkdirpvcstoragesize: "200Mi",
    localdirpvcstoragesize: "200Mi",
    externalports: {
      masteruiports: [28080 + i for i in std.range(0, $.spark.master.instancecount - 1)],
      masterports: [27070 + i for i in std.range(0, $.spark.master.instancecount - 1)],
      applicationuiports: [24040 + i for i in std.range(0, $.spark.master.instancecount - 1)],
      restports: [6066 + i for i in std.range(0, $.spark.master.instancecount - 1)],
      historyuiports: [48080 + i for i in std.range(0, $.spark.historyserver.instancecount - 1)],
    },
    nodeports: {
      masteruiports: [30012,30013,30014],
      masterports: ["" for count in std.range(1, $.spark.master.instancecount)],
      applicationuiports: ["" for count in std.range(1, $.spark.master.instancecount)],
      restports: ["" for count in std.range(1, $.spark.master.instancecount)],
      historyuiports: ["" for count in std.range(1, $.spark.historyserver.instancecount)],
    },
    master: {
      instancecount: 3,
      requestcpu: "300m",
      requestmem: "1Gi",
      limitcpu: "1",
      limitmem: "2Gi",
    },
    worker: {
      instancecount: 3,
      requestcpu: "2",
      requestmem: "4Gi",
      limitcpu: "4",
      limitmem: "8Gi",
      sparkworkercores: "3",
    },
    historyserver: {
      sparkeventlogdir: "hdfs://enncloud-hadoop/var/log/spark",
      instancecount: 1,
      requestcpu: "300m",
      requestmem: "1Gi",
      limitcpu: "1",
      limitmem: "2Gi",
    },
  },

  tensorflow: {
    exservicetype: $.exservicetype,
    externalports: {
      tfpsports: [22222 + i for i in std.range(0, $.tensorflow.psnum - 1)],
    },
    nodeports: {
      tfpsports: ["" for count in std.range(1, $.tensorflow.psnum)],
    },
    tfworkerrequestcpu: "1",
    tfworkerrequestmem: "1Gi",
    tfworkerlimitcpu: "1",
    tfworkerlimitmem: "1Gi",
    tfpsrequestcpu: "0.5",
    tfpsrequestmem: "1Gi",
    tfpslimitcpu: "0.5",
    tfpslimitmem: "1Gi",
    grpcimage: $.registry + "/tensorflow/tf_grpc_test_server-gpu:platform-py2-py3-tf1.1",
    jobname: "tf-gpu",
    setup_cluster_only: 1,
    modelname: "MNIST",
    workernum: 2,
    psnum: 1,
    existing_servers: false,
    output_path: "/tmp/output/",
    data_dir: "/tmp/data/",
    log_dir: "/tmp/log/",
    sync_replicas: 0,
    n_gpus: 2,
    train_steps: 120,
    cephfsstoragename: "tensorflow",
    containerpath: "/tmp",
    cephfsstoragesize: "1Gi",
  },

  zookeeper: {
    image:  $.registry + "/tools/dep-centos7-zookeeper3.5.3:beta-lbsheng",
    instancecount: 3,
    exservicetype: $.exservicetype,
    datapvcstoragesize: "1Gi",
    datalogpvcstoragesize: "1Gi",
    requestcpu: "300m",
    requestmem: "1Gi",
    limitcpu: "1",
    limitmem: "2Gi",
    externalports: {
      clientports: [22181 + i for i in std.range(0,$.zookeeper.instancecount - 1)],
      adminserverports: [38080 + i for i in std.range(0,$.zookeeper.instancecount - 1)],
    },
    nodeports: {
      clientports: [29475,29476,29477],
      adminserverports: ["" for count in std.range(1, $.zookeeper.instancecount)],
    },

    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-zookeeper-3.5.3:ary-beta-1.0.5",
      exservicetype: $.exservicetype,
      zkinstancecount: $.zookeeper.instancecount,
      replicas: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        amahports:[8084,],
      },
      nodeports: {
        amahports:["",],
      },
     },
  },

  ping: {
    image: $.registry + "/tools/ping:0.4-lbsheng",
    instancecount: 1,
    datastoragesize: "1Gi",
    requestcpu: "0",
    requestmem: "0",
    limitcpu: "0",
    limitmem: "0",
  },
  redis: {
    image: $.registry + "/tools/redis-cluster:0.5-lbsheng",
    zkinstancecount: $.zookeeper.instancecount,
    exservicetype: $.exservicetype,
    redisdatastoragesize: "100Mi",
    instancecount: 3,
    externalports: {
      redisports:["6379",],
    },
    nodeports: {
      redisports:["",],
    },
    master: {
      replicas: $.redis.instancecount,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
    },
    slave: {
      replicas: $.redis.instancecount,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
    },
   },

  bitmap: {
    image: "127.0.0.1:30100/library/bitmap:0.1",
    exservicetype: $.exservicetype,
    instancecount: 1,
    replicas: 1,
    requestcpu: "1",
    requestmem: "4Gi",
    limitcpu: "2",
    limitmem: "8Gi",
    externalports: {
      httpports:[9313 + i for i in std.range(0,$.bitmap.instancecount - 1)],

    },
    nodeports: {
      httpports:["" for count in std.range(1, $.bitmap.instancecount)],

    },
   },

  lookupservice: {
    image: $.registry + "/library/dojoyn2.0:0.2",
    exservicetype: "None",
    instancecount: 1,
    replicas: 1,
    requestcpu: "1",
    requestmem: "2Gi",
    limitcpu: "2",
    limitmem: "4Gi",
    externalports: {
      rpcports:[50051 + i for i in std.range(0,$.lookupservice.instancecount - 1)],

    },
    nodeports: {
      rpcports:["" for count in std.range(1, $.lookupservice.instancecount)],

    },
   },

  joiner: {
    image: $.registry + "/library/dojoyn2.0:0.2",
    exservicetype: "None",
    instancecount: 1,
    replicas: 1,
    requestcpu: "1",
    requestmem: "2Gi",
    limitcpu: "2",
    limitmem: "4Gi",
    externalports: {
      rpcports:[23377 + i for i in std.range(0,$.joiner.instancecount - 1)],

    },
    nodeports: {
      rpcports:["" for count in std.range(1, $.joiner.instancecount)],

    },
   },

  statemanager: {
    image: $.registry + "/library/dojoyn2.0:0.2",
    exservicetype: "None",
    instancecount: 1,
    replicas: 1,
    requestcpu: "1",
    requestmem: "2Gi",
    limitcpu: "2",
    limitmem: "4Gi",
    externalports: {

    },
    nodeports: {

    },
   },

  mongodb: {
    image: $.registry + "/library/mongo:docker.io",
    exservicetype: $.exservicetype,
    instancecount: 1,
    replicas: 1,
    mongodbdatapvcstoragesize: "1Gi",
    requestcpu: "0.5",
    requestmem: "1Gi",
    limitcpu: "0.5",
    limitmem: "2Gi",
    externalports: {
      ports:[27017 + i for i in std.range(0,$.mongodb.instancecount - 1)],

    },
    nodeports: {
      ports:[29487],

    },
   },
}
