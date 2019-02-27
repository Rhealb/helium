(import "../../common/service.jsonnet") + {
  // global variables
  _rmprefix:: "tbd",

  // override super global variables
  _mname: "resourcemanager",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "rmscheduleipcport:8030",
    "rmipcport:8031",
    "rmasmport:8032",
    "rmadminport:8033",
    "yarnhttpport:8088",
    "rmcheckport:8888",
  ],
}
