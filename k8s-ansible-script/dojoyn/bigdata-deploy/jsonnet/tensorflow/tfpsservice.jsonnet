( import "../common/service.jsonnet" ) {
  // global variables
  _tfpsprefix:: "",

  // override super global variables
  _mname: "tfps",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "tfpsport:2222",
  ]
}