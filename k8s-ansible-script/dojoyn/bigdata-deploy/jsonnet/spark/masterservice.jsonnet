(import "../common/service.jsonnet") + {
  // global variables
  _masterprefix:: "tbd",

  // override super global variables
  _mname: "master",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "masteruiport:8080",
    "masterport:7077",
    "applicationuiport:4040",
    "restport:6066",
    "mastercheckport:8888",
  ],
}
