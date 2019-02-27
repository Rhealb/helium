( import "../common/service.jsonnet" ) {
  // global variables
  _lookupserviceprefix:: "",

  // override super global variables
  _mname: "lookupservice",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "rpcport:50051",

  ],
}
