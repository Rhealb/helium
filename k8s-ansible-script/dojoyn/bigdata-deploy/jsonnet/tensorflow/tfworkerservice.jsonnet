( import "../common/service.jsonnet" ) {
  // global variables
  _tfworkerprefix:: "",

  // override super global variables
  _mname: "tfworker",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "tfworkerport:2222",
  ]
}