(import "../common/deployment.jsonnet") {
  // global variables
  _kafkaprefix:: "tbd",
  _brokerid:: 1,
  _zookeeperservers:: "zookeeper1:2181,zookeeper2:2181,zookeeper3:2181",
  _kafkaadvertizedlisternersenv:: "kafka:9092",
  local utils = import "../common/utils/utils.libsonnet",
  _podantiaffinitytag:: self._kafkaprefix + "-" + "kafka",
  _podantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _podantiaffinityns:: [super._mnamespace,],
  _kafkaexservicetypeenv:: "ClusterIP",
  _exbrokerportenv:: "",

  // override super global variables
  _mname: "kafka",
  _mnamespace: "hadoop-jsonnet",
  _dockerimage:: "10.19.132.184:30100/tools/dep-centos7-kafka-2.11-0.10.1.1:0.1",
  _envs: [
    "KAFKA_BROKER_ID:" + $._brokerid,
    "ZOOKEEPER_SERVERS:" + $._zookeeperservers,
    "BD_KAFKA_AD_LISTERNERS:" + $._kafkaadvertizedlisternersenv,
    "BD_KAFKA_JMX_PORT:9999",
    "BD_KAFKA_EXSERVICETYPE:" + $._kafkaexservicetypeenv,
    "BD_KAFKA_EXBROKERPORT:" + $._exbrokerportenv,
    "BD_NAMESPACE:" + $._mnamespace,
  ],
  _nameports: [
    "brokerport:9092",
  ],
  _cephuser:: "admin",
  _cephsecretref:: "ceph-secret-jsonnet",
  spec+: {
    template+: {
      metadata+: {
        labels+: {
          "podantiaffinitytag": $._podantiaffinitytag,
        },
      },
      spec+: {
        affinity: utils.podantiaffinity($._podantiaffinitytag, $._podantiaffinitytype, $._podantiaffinityns),
        hostname: $._mname,
      },
    },
  },
}
