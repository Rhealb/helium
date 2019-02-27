( import "../common/deployment.jsonnet" ) + {
  // global variables
  
  local utils = import "../common/utils/utils.libsonnet",
  _podantiaffinitytag:: self._esmasterprefix + "-" + "esmaster",
  _podantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _podantiaffinityns:: [super._mnamespace,],

  // override super global variables
  _mname: "esmaster",
  _dockerimage:: "",
  _volumemounts:: [
    "cephconf:/opt/mntcephutils",
  ],
  _volumes:: [
    "",
  ],
  _command:: ["/opt/entrypoint.sh"],
  spec+: {
    template+: {
      metadata+: {
        labels+: {
          "podantiaffinitytag": $._podantiaffinitytag,
        },
      },
      spec+: {
        affinity: utils.podantiaffinity($._podantiaffinitytag, $._podantiaffinitytype, $._podantiaffinityns),
        hostname: $._mname,
      },
    },
  },
}
