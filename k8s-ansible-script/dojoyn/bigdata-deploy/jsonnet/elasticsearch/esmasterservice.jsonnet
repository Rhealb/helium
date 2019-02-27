( import "../common/service.jsonnet" ) {
  // global variables
  _esmasterprefix:: "",

  // override super global variables
  _mname: "esmaster",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "httpport:9200",
    "transport:9300",
  ]
}