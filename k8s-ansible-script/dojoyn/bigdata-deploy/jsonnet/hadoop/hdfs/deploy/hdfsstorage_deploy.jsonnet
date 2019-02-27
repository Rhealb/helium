{
// mysql deploy global variables
  _namespace:: "bigdata-jsonnet",
  _suiteprefix:: "pre1",
  _datadirstoragesize:: "500Mi",
  _specusestoragesize:: "500Mi",
  _nninstancecount:: 2,
  _jninstancecount:: 3,
  _datadirstoragecount:: 4,
  _mountdevtype:: "CephFS",
  _utilsstoretype:: "FS",

  local storageprefix = $._suiteprefix,
  local cephfsbasename = ["hadooputils"],
  local cephfsstoragesize = ["1Mi"],
  local cephfsstoragename=[storageprefix + "-" + name for name in cephfsbasename],

  kind: "List",
  apiVersion: "v1",
  items: (if $._utilsstoretype == "FS" then
  [
   (import "../../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: cephfsstoragename[storagenum],
     _storagesize: cephfsstoragesize[storagenum],
     _storagetype: $._mountdevtype,
   } for storagenum in std.range(0, std.length(cephfsstoragename) - 1)
  ]
  else
  []) + [
   (import "../../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-datadir" + num,
     _storagesize: $._datadirstoragesize,
     _storagetype: "HostPath",
   } for num in std.range(1,$._datadirstoragecount)
  ] + [
   (import "../../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-specuse" + num,
     _storagesize: $._specusestoragesize,
     _storagetype: "HostPath",
   } for num in std.range(1, $._jninstancecount + $._nninstancecount)
  ],
}
