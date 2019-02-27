( import "../common/deployment.jsonnet" ) + {
  // global variables
  _hmasterprefix:: "tbd",
  local utils = import "../common/utils/utils.libsonnet",
  _podantiaffinitytag:: self._hmasterprefix + "-" + "hmaster",
  _podantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _podantiaffinityns:: [super._mnamespace,],

  
  // override super global variables
  _mname: "hmaster",
  _dockerimage:: "10.19.132.184:30100/tools/dep-centos7-hbase-1.2.5:0.1",
  _envs:: [
    "HBASE_SERVER_TYPE:master",
    "BD_SUITE_PREFIX:" + $._hmasterprefix,
  ] + [
    "ZKNAME:" + std.join(",", [
      $._hmasterprefix + "-" + "zookeeper" + zknum + ":2181"
        for zknum in std.range(1,3)
    ])
  ],
  _volumemounts:: [
    "cephconf:/opt/hbase/mntconf",
  ],
  _volumes:: [
    "cephconf:cephfs:/user/hadoop-jsonnet/conf/hbase/hmaster",
  ],
  _cephhostports:: [
    "10.19.248.27:6789",
    "10.19.248.28:6789",
    "10.19.248.29:6789",
    "10.19.248.30:6789",
  ],
  _command:: ["/opt/entrypoint.sh"],
  _cephuser:: "admin",
  _cephsecretref:: "ceph-secret-jsonnet",
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
