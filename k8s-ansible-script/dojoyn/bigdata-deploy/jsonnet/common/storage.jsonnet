
(import "common.jsonnet") + {
  // global variables
  _storagesize:: "tbd",
  _accessmodes:: "ReadWriteMany",
  _storagetype:: "bigdata-tbd",
  _mlabel: "storage",
  _persisted:: true,
  _unshared:: true,

  apiVersion: "v1",
  kind: "Storage",
  spec: {
    type: if $._storagetype == "bigdata-tbd" then
            error "storage type unkonw"
          else 
            $._storagetype,
    accessModes: $._accessmodes,
    persisted: $._persisted,
    unshared: $._unshared,
    resources: {
      requests: {
        storage: $._storagesize,
      }
    }
  },
}
