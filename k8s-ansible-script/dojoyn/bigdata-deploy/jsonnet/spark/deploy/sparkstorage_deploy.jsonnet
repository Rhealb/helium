{
// mysql deploy global variables
  _namespace:: "bigdata-jsonnet",
  _suiteprefix:: "pre1",
  _workerworkdirstoragesize :: "200Mi",
  _localdirstoragesize :: "200Mi",
  _localdirstoragecount:: 1,
  _mountdevtype:: "CephFS",
  _utilsstoretype:: "FS",
  local storageprefix = $._suiteprefix,

  local cephfsbasename = ["sparkutils"],
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
     _mname: storageprefix + "-spworkerworkdir",
     _storagesize: $._workerworkdirstoragesize,
     _storagetype: "HostPath",
   }
  ] + [
   (import "../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-spworkerlocaldir" + storagenum,
     _storagesize: $._localdirstoragesize,
     _storagetype: "HostPath",
     _persisted: false,
   } for storagenum in std.range(1,$._localdirstoragecount)
  ],
}
