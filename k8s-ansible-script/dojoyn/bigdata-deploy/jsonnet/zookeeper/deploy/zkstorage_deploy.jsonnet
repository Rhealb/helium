{
// mysql deploy global variables
  _namespace:: "bigdata-jsonnet",
  _suiteprefix:: "pre1",
  _zkdatastoragesize:: "50Mi",
  _zkdatalogstoragesize:: "50Mi",
  _zkinstancecount:: 3,
  _mountdevtype:: "CephFS",
  _utilsstoretype:: "FS",
  local storageprefix = $._suiteprefix,

  local cephfsbasename = ["zkutils"],
  local cephfsstoragesize = ["1Mi"],
  local cephfsstoragename=[storageprefix + "-" + name for name in cephfsbasename],

  kind: "List",
  apiVersion: "v1",
  items: (if $._utilsstoretype == "FS" then
  [
   (import "../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: cephfsstoragename[storagenum],
     _storagesize: cephfsstoragesize[storagenum],
     _storagetype: $._mountdevtype,
   } for storagenum in std.range(0, std.length(cephfsstoragename) - 1)
  ]
  else
  []) + [
   (import "../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-zk" + zknum + "data",
     _storagesize: $._zkdatastoragesize,
     _storagetype: "HostPath",
   } for zknum in std.range(1,$._zkinstancecount)
  ] + [
   (import "../../common/storage.jsonnet") + {
     // override pv global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-zk" + zknum + "datalog",
     _storagesize: $._zkdatalogstoragesize,
     _storagetype: "HostPath",
   } for zknum in std.range(1,$._zkinstancecount)
  ],
}
