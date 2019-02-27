( import "../common/service.jsonnet" ) {
  // global variables
  _joinerprefix:: "",

  // override super global variables
  _mname: "joiner",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "rpcport:23377",

  ],
}
