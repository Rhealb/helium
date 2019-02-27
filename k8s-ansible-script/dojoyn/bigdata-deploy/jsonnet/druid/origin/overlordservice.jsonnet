(import "../../common/service.jsonnet") + {
  // override super global variables
  _overlordprefix:: "tbd",
  _mname: "overlord",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "overlordport:8090",
  ],
}
