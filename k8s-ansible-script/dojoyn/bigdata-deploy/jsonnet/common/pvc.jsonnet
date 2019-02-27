(import "common.jsonnet") + {
  // global variables
  _storagesize:: "tbd",
  _accessmodes:: ["ReadOnlyMany",],
  _sname:: $._mname,

  // override super global variables
  _mlabel:: "pvc",
  _slabel:: "pv",

  apiVersion: "v1",
  kind: "PersistentVolumeClaim",
  spec: {
    accessModes: $._accessmodes,
    resources: {
      requests: {
        storage: $._storagesize,
      },
    },
    selector: {
      matchLabels: {
        app: $._sname + "-" + $._slabel,
        name: $._sname,
      },
    },
  },
}
