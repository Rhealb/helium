( import "../../common/deployment.jsonnet" ) + {
  // global variables
  _jnprefix:: "tbd",
  local utils = import "../../common/utils/utils.libsonnet",
  _podantiaffinitytag:: self._jnprefix + "-" + "journalnode",
  _podantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _podantiaffinityns:: [super._mnamespace,],
  // override super global variables
  _mname: "journalnode",
  _dockerimage:: "10.19.248.12:30100/tools/dep-centos7-hadoop-2.7.3:0.1",
  _envs:: [
    "HADOOP_SERVER_TYPE:journalnode",
    "BD_SUITE_PREFIX:" + $._jnprefix,
  ],
  _volumemounts:: [
    "hdfs-storage:/hdfs",
    "tmp:/tmp",
    "cephconf:/opt/hadoop/etc/hadoop",
  ],
  _volumes:: [
    "hdfs-storage:hostPath:/tmp/hdfs/journal",
    "tmp:emptyDir:",
    "cephconf:cephfs:/user/hadoop-jsonnet/conf/hadoop/hdfs/journalnode",
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
