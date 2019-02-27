( import "../common/deployment.jsonnet" ) + {
  // global variables
  _rsprefix:: "tbd",

  // override super global variables
  _mname: "regionserver",
  _dockerimage:: "10.19.132.184:30100/tools/dep-centos7-hbase-1.2.5:0.1:0.1",
  _envs:: [
    "HBASE_SERVER_TYPE:regionserver",
    "BD_SUITE_PREFIX:" + $._rsprefix,
  ] + [
    "ZKNAME:" + std.join(",", [
      $._rsprefix + "-" + "zookeeper" + zknum + ":2181"
        for zknum in std.range(1,3)
    ])
  ],
  _volumemounts:: [
    "cephconf:/opt/hbase/conf",
  ],
  _volumes:: [
    "cephconf:cephfs:/user/hadoop-jsonnet/conf/hbase/regionserver",
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
        annotations: {
          "io.enndata.dns/pod.enable":"true",
        }
      }
    }
  }
}