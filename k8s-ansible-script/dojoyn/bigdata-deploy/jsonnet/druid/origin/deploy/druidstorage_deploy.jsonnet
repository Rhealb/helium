{
// mysql deploy global variables
  _namespace:: "bigdata-jsonnet",
  _suiteprefix:: "pre1",
  _histsegmentcachestoragesize:: "200Mi",
  _mmsegmentsstoragesize:: "200Mi",
  _zkinstancecount:: 3,
  _mountdevtype:: "CephFS",
  _utilsstoretype:: "FS",
  local storageprefix = $._suiteprefix,

  local cephfsbasename = ["druidutils"],
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
      _mname: storageprefix + "-histsegmentcache",
      _storagesize: $._histsegmentcachestoragesize,
      _storagetype: "HostPath",
      _persisted: false,
    }
  ] + [
    (import "../../../common/storage.jsonnet") + {
      // override storage global variables
      _mnamespace: $._namespace,
      _mname: storageprefix + "-mmsegments",
      _storagesize: $._mmsegmentsstoragesize,
      _storagetype: "HostPath",
      _persisted: false,
    }
  ],
}
