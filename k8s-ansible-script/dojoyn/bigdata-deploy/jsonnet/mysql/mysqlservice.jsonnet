(import "../common/service.jsonnet") + {
  // override super global variables
  _mname: "mysql",
  _mysqlprefix:: "pre",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "mysql-port:3306",
  ],
}
