( import "../../common/deployment.jsonnet" ) + {
  // global variables
  _dnprefix:: "tbd",

  // override super global variables
  _mname: "datanode",
  _dockerimage:: "10.19.248.12:30100/tools/dep-centos7-hadoop-2.7.3:0.1",
  _envs:: [
    "HADOOP_SERVER_TYPE:datanode",
    "BD_SUITE_PREFIX:" + $._dnprefix,
  ],
  _volumemounts:: [
    "ssd1:/mnt/ssd1",
    "hdd1:/mnt/hdd1",
    "cephconf:/opt/hadoop/etc/hadoop",
    "pvc1:/mnt/pvc1/dn/",
  ],
  _volumes:: [
    "ssd1:hostPath:/mnt/ssd1/" + $._mnamespace + "/dn",
    "hdd1:hostPath:/mnt/hdd1/" + $._mnamespace + "/dn",
    "cephconf:cephfs:/user/hadoop-jsonnet/conf/hadoop/hdfs/datanode",
    "pvc1:persistentVolumeClaim:datadirpvc",
  ],
  _cephhostports:: [
    "10.19.248.27:6789",
    "10.19.248.28:6789",
    "10.19.248.29:6789",
    "10.19.248.30:6789",
  ],
  _command:: ["/opt/hadoop/mntconf/entrypoint.sh"],
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