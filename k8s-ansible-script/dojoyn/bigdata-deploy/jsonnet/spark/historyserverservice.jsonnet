(import "../common/service.jsonnet") + {
  // global variables
  _historyserverprefix:: "tbd",

  // override super global variables
  _mname: "historyserver",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "historyuiport:18080",
  ],
}
