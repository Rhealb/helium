( import "../common/service.jsonnet" ) {
  // global variables
  _esclientprefix:: "",

  // override super global variables
  _mname: "esclient",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "httpport:9200",
    "transport:9300",
  ]
}