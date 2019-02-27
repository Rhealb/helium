(import "../common/deployment.jsonnet") {
  // global variables
  _masterprefix:: "tbd",
  local utils = import "../common/utils/utils.libsonnet",
  _podantiaffinitytag:: self._masterprefix + "-" + "master",
  _podantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _podantiaffinityns:: [super._mnamespace,],

  // override super global variables
  _mname: "master",
  _mnamespace: "hadoop-jsonnet",
  _dockerimage:: "10.19.132.184:30100/tools/dep-centos7-spark-2.11-hadoop-2.7:0.1",
  _envs:: [
    "SPARK_SERVER_TYPE:master",
    "HADOOP_CONF_DIR:/opt/spark/conf",
    "BD_SUITE_PREFIX:" + $._masterprefix,
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
