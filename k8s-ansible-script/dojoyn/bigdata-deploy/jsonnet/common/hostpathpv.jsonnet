(import "pv.jsonnet") + {
  // global variables
  _hostpath:: "/this/is/useless",
  _accessmodes: ["ReadWriteMany",],
  _hostpathpvmountpolicy:: "keep",
  // override super global variables
  _mannotations: [
    "io.enndata.user/alpha-pvhostpathmountpolicy:" + $._hostpathpvmountpolicy,
    "io.enndata.user/alpha-pvhostpathquotaforonepod:true",
  ],

  spec+: {
    hostPath: {
      path: $._hostpath,
    },
  },
}
