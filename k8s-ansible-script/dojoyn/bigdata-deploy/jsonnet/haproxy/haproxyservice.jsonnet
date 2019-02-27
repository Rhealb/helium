(import "../common/service.jsonnet") + {
  // global variables
  _hmasterprefix:: "tbd",

  // override super global variables
  _mname: "haproxy",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "hawebport:10800",
  ],
}
