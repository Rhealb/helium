(import "../../common/service.jsonnet") + {
  // override super global variables
  _coordinatorprefix:: "tbd",
  _mname: "coordinator",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "coordport:8081",
  ],
}
