(import "../../common/pvc.jsonnet") + {
  // override super global variables
  _mnamespace: "hadoop-jsonnet",
  _mname: "tmpdirpvc",
  _mlabel: "pvc",
  _storagesize:: "50Mi",
  _accessmodes:: ["ReadWriteMany",],
}