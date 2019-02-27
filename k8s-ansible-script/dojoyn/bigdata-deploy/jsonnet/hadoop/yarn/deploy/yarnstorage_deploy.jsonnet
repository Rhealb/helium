{
// mysql deploy global variables
  _namespace:: "bigdata-jsonnet",
  _suiteprefix:: "pre1",
  _hostpathstoragesize:: "500Mi",
  _rmtmpdirstoragesize:: "100Mi",
  _nmtmpdirstoragesize:: "100Mi",
  _tmpdirstoragecount:: 4,
  local storageprefix = $._suiteprefix,

  kind: "List",
  apiVersion: "v1",
  items: [
   (import "../../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-nmuserlogs",
     _storagesize: $._hostpathstoragesize,
     _storagetype: "HostPath",
   }
  ] + [
   (import "../../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-rmtmpdir" + tmpdirnum ,
     _storagesize: $._rmtmpdirstoragesize,
     _storagetype: "HostPath",
     _persisted: false,
   } for tmpdirnum in std.range(1,$._tmpdirstoragecount)
  ] + [
   (import "../../../common/storage.jsonnet") + {
     // override storage global variables
     _mnamespace: $._namespace,
     _mname: storageprefix + "-nmtmpdir" + tmpdirnum ,
     _storagesize: $._nmtmpdirstoragesize,
     _storagetype: "HostPath",
     _persisted: false,
   } for tmpdirnum in std.range(1,$._tmpdirstoragecount)
  ],
}
