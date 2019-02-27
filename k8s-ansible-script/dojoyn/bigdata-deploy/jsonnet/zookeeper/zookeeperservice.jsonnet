( import "../common/service.jsonnet" ) {
  // global variables
  _zkprefix:: "",

  // override super global variables
  _mname: "zookeeper",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "clientport:2181",
    "peerport:2888",
    "leaderport:3888",
    "adminserverport:8080",
    "jmxport:9999",
  ]
}
