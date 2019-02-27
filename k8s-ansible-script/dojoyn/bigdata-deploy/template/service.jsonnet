( import "../common/service.jsonnet" ) {
  // global variables
  _%NAME%prefix:: "",

  // override super global variables
  _mname: "%NAME%",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    %SERVICEPORTS%
  ],
}
