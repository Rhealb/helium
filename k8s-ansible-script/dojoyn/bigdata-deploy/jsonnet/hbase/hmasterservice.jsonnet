(import "../common/service.jsonnet") + {
  // global variables
  _hmasterprefix:: "tbd",

  // override super global variables
  _mname: "hmaster",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "masteripcport:16000",
    "masterhttpport:16010",
    "hmcheckportport:8888",
  ],
}
