( import "../../common/deployment.jsonnet" ) + {
  // global variables
  _rmprefix:: "tbd",
  local utils = import "../../common/utils/utils.libsonnet",
  _podantiaffinitytag:: self._rmprefix + "-" + "resourcemanager",
  _podantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _podantiaffinityns:: [super._mnamespace,],

  // override super global variables
  _mname: "resourcemanager",
  _dockerimage:: "10.19.248.12:30100/tools/dep-centos7-hadoop-2.7.3:0.1",
  _envs:: [
    "HADOOP_SERVER_TYPE:resourcemanager",
    "BD_SUITE_PREFIX:" + $._rmprefix,
  ],
  _volumemounts:: [
    "ssd1:/mnt/ssd1/rm/",
    "hdd1:/mnt/hdd1/rm/",
    "cephconf:/opt/hadoop/etc/hadoop",
  ],
  _volumes:: [
    "ssd1:hostPath:/mnt/ssd1/" + $._mnamespace + "/rm",
    "hdd1:hostPath:/mnt/hdd1/" + $._mnamespace + "/rm",
    "cephconf:cephfs:/user/hadoop-jsonnet/conf/hadoop/yarn/resourcemanager",
    "pvc1:persistentVolumeClaim:tmpdirpvc",
  ],
  _cephhostports:: [
    "10.19.248.27:6789",
    "10.19.248.28:6789",
    "10.19.248.29:6789",
    "10.19.248.30:6789",
  ],
  _command:: ["/opt/hadoop/mntconf/entrypoint.sh", "2>&1"],
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
