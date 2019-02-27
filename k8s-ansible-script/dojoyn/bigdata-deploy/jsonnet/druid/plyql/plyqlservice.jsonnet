( import "../../common/service.jsonnet" ) {
  // global variables
  _plyqlprefix:: "",

  // override super global variables
  _mname: "plyql",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "mysqlgatewayport:3306",
  ]
}
