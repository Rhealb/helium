(import "../../common/service.jsonnet") + {
  // global variables
  _jnprefix:: "tbd",

  // override super global variables
  _mname: "journalnode",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "journalrpcport:8485",
    "journalhttpport:8480",
  ],
}
