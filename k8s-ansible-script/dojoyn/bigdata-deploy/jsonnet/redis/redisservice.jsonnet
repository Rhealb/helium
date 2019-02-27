( import "../common/service.jsonnet" ) {
  // global variables
  _redisprefix:: "",

  // override super global variables
  _mname: "redis",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "redisport:6379",
  ],
  spec+: {
    //clusterIP: "None",
    selector: {
      "rediscluster-node": "true",  
    },
  },
}
