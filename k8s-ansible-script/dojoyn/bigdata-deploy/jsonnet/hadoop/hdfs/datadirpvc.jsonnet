(import "../../common/pvc.jsonnet") + {
  // override super global variables
  _mnamespace: "hadoop-jsonnet",
  _mname: "datadirpvc",
  _mlabel: "pvc",
  _storagesize:: "100Mi",
  _accessmodes:: ["ReadWriteMany",],
}