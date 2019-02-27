(import "common.jsonnet") + {
  // global variables
  _storagesize:: "tbd",
  _pvreclaimpolicy:: "tbd",
  _accessmodes:: ["ReadOnlyMany",],

  // override super global variables
  _mlabel: "pv",

  apiVersion: "v1",
  kind: "PersistentVolume",
  spec: {
    persistentVolumeReclaimPolicy: $._pvreclaimpolicy,
    capacity: {
      storage: $._storagesize,
    },
    accessModes: $._accessmodes,
  },
}
