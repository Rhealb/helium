{
// mongodb deploy global variables
  _namespace:: "bigdata-jsonnet",
  _suiteprefix:: "pre1",
  _mountdevtype:: "CephFS",
  _mongodbdatastoragesize:: "1Gi",
  _utilsstoretype:: "ConfigMap",
  local storageprefix = $._suiteprefix,
  local cephfsbasename = ["mongodbutils"],
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
  []) +[
(import "../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-mongodbdata",
     _storagesize: $._mongodbdatastoragesize,
     _storagetype: "HostPath",
   }
 ],
}
