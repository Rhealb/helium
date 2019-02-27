(import "../common/deployment.jsonnet") {
  // global variables
  _zkprefix:: "tbd",
  _serverid:: 1,
  _maxservers:: 3,
  local utils = import "../common/utils/utils.libsonnet",
  _podantiaffinitytag:: self._zkprefix + "-" + "zookeeper",
  _podantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _podantiaffinityns:: [super._mnamespace,],

  // override super global variables
  _mname: "zookeeper",
  _mnamespace: "hadoop-jsonnet",
  _dockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _envs: [
    "SERVER_ID:" + $._serverid,
    "MAX_SERVERS:" + $._maxservers,
    "BD_SUITE_PREFIX:" + $._zkprefix,
    "JMXPORT:9999",
  ],
  _cephhostports:: [
    "10.19.248.27:6789",
    "10.19.248.28:6789",
    "10.19.248.29:6789",
    "10.19.248.30:6789",
  ],
  _command:: ["/opt/entrypoint.sh", "2>&1"],
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
