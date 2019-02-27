(import "../../common/service.jsonnet") + {
  // global variables
  _mrjobhistoryprefix:: "tbd",

  // override super global variables
  _mname: "mrjobhistory",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "jhsipcport:10020",
    "jhshttpport:19888",
  ],
}
