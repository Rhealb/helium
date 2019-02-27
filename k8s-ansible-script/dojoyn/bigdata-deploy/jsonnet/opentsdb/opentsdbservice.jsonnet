( import "../common/service.jsonnet" ) {
  // global variables
  _opentsdbprefix:: "tbd",

  // override super global variables
  _mname: "opentsdb",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "httpport:4242",
    "jmxport:9100",
  ]
}
