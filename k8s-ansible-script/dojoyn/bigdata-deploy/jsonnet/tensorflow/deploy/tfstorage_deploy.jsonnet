{
// tf deploy global variables
  _namespace:: "bigdata-jsonnet",
  _suiteprefix:: "pre1",
  _mountdevtype:: "CephFS",
  _cephfsstoragename:: "tensorflow",
  _cephfsstoragesize:: "1Gi",
  local storageprefix = $._suiteprefix,

  local cephfsbasename = [$._cephfsstoragename,],
  local cephfsstoragesize = [$._cephfsstoragesize,],
  local cephfsstoragename=[storageprefix + "-" + name for name in cephfsbasename],

  kind: "List",
  apiVersion: "v1",
  items: [
   (import "../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: cephfsstoragename[storagenum],
     _storagesize: cephfsstoragesize[storagenum],
     _storagetype: $._mountdevtype,
   } for storagenum in std.range(0, std.length(cephfsstoragename) - 1)
  ],
}
