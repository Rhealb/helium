( import "../../common/deployment.jsonnet" ) + {
  // global variables
  _nmprefix:: "tbd",

  // override super global variables
  _mname: "nodemanager",
  _dockerimage:: "10.19.248.12:30100/tools/dep-centos7-hadoop-2.7.3:0.1",
  _envs:: [
    "HADOOP_SERVER_TYPE:nodemanager",
    "BD_SUITE_PREFIX:" + $._nmprefix,
  ],
  _volumemounts:: [
    "ssd1:/mnt/ssd1",
    "hdd1:/mnt/hdd1",
    "cephconf:/opt/hadoop/etc/hadoop",
    "pvc1:/mnt/pvc1/nm/",
  ],
  _volumes:: [
    "ssd1:hostPath:/mnt/ssd1/" + $._mnamespace + "/nm",
    "hdd1:hostPath:/mnt/hdd1/" + $._mnamespace + "/nm",
    "cephconf:cephfs:/user/hadoop-jsonnet/conf/hadoop/yarn/nodemanager",
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
        annotations: {
          "io.enndata.dns/pod.enable":"true",
        }
      }
    }
  }
}