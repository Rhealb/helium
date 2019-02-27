(import "pv.jsonnet") + {
  // global variables
  _path:: "/path/in/cephfs",
  _cephhostports:: [
    "0.0.0.0:6789",
  ],
  _cephuser:: "tbd",
  _cephsecretref:: "tbd",
  _readonly:: true,

  spec+: {
    cephfs: {
      monitors: $._cephhostports,
      user: $._cephuser,
      path: $._path,
      readOnly: $._readonly,
      secretRef: {
        name: $._cephsecretref,
      },
    },
  },
}
