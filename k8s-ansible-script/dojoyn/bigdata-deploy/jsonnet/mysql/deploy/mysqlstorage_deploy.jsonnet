{
// mysql deploy global variables
  _namespace:: "bigdata-jsonnet",
  _suiteprefix:: "pre1",
  _mysqldatastoragesize:: "1Gi",
  _mountdevtype:: "CephFS",
  _utilsstoretype:: "FS",
  local storageprefix = $._suiteprefix,

  local cephfsbasename = ["mysqlutils"],
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
     _mname: storageprefix + "-mysqldata",
     _storagesize: $._mysqldatastoragesize,
     _storagetype: "HostPath",
   }
  ],
}
