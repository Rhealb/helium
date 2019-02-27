(import "../../common/hostpathpv.jsonnet") + {
  // override super global variables
  _mnamespace: "hadoop-jsonnet",
  _mname: "tmpdirpv",
  _mlabel: "pv",
  _storagesize: "50Mi",
  _pvreclaimpolicy: "Recycle",
  _accessmodes: ["ReadWriteMany",],
  _hostpath: "/mnt/" + $._mname + "/hadoop/",
}