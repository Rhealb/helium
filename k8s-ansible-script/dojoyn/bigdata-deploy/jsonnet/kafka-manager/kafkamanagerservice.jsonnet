( import "../common/service.jsonnet" ) {
  // override super global variables
  _mname: "kafkamanager",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "httpport:9000",
  ]
}
