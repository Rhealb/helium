(import "../common/deployment.jsonnet") {
  // global variables
  _zookeeperservers:: "zookeeper1:2181,zookeeper2:2181,zookeeper3:2181",

  // override super global variables
  _mname: "kafkamanager",
  _mnamespace: "hadoop-jsonnet",
  _dockerimage:: "10.19.132.184:30100/tools/dep-centos7-kafka-2.11-0.10.1.1:0.1",
  _envs:: [
    "BD_ZOOKEEPER_SERVERS:" + $._zookeeperservers,
  ],
  _nameports: [
    "httpport:9000",
  ],
  _cephuser:: "admin",
  _cephsecretref:: "ceph-secret-jsonnet",
}
