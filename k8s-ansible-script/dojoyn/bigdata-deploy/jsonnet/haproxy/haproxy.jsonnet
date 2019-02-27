( import "../common/deployment.jsonnet" ) + {
  // global variables
  _haproxyprefix:: "tbd",
  local utils = import "../common/utils/utils.libsonnet",
  _podantiaffinitytag:: self._haproxyprefix + "-" + "haproxy",
  _podantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _podantiaffinityns:: [super._mnamespace,],

  // override super global variables
  _mname: "haproxy",
  _dockerimage:: "10.19.132.184:30100/tools/dockerio-haproxy-1.7.0-alpine:0.1",
  _envs:: [
    "CONF_FILE:/opt/mntcephutils/conf/haproxy.cfg",
  ],
  _volumemounts:: [
    "cephconf:/mnt/conf",
  ],
  _volumes:: [
    "cephconf:cephfs:/user/hadoop-jsonnet/conf/haproxy/conf/",
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
