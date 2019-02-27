(import "../common/deployment.jsonnet") {
  // global variables
  _pingprefix:: "tbd",
  local utils = import "../common/utils/utils.libsonnet",
  _podantiaffinitytag:: self._pingprefix + "-" + "ping",
  _podantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _podantiaffinityns:: [super._mnamespace,],

  // override super global variables
  _mname: "ping",
  _mnamespace: "hadoop-jsonnet",
  _dockerimage:: "127.0.0.1:30100/tools/dep-centos7-spark-and-hadoop:0.1",
  _envs:: [
    "BD_SUITE_PREFIX:" + $._pingprefix,
  ],
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
