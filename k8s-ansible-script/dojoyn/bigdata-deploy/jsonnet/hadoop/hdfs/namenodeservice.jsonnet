(import "../../common/service.jsonnet") + {
  // global variables
  _nnprefix:: "tbd",

  // override super global variables
  _mname: "namenode",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "nnhttpport:50070",
    "nnhttpsport:50470",
    "defaultfs:8020",
    "zkfc:8019",
    "nncheckport:8888",
  ],
}
