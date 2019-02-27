(import "../../common/service.jsonnet") + {
  // override super global variables
  _brokerprefix:: "tbd",
  _mname: "broker",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "brokerport:8082",
  ],
}
