(import "../common/deployment.jsonnet") {
  // global variables

  // override super global variables
  _mname: "ecej",
  _mnamespace: "langfang-jsonnet",
  _suiteprefix:: "pre1",
  _dockerimage:: "10.38.240.34:30100/tools/dep-centos7-spark-and-hadoop:0.2",

  _cephuser:: "admin",
  _cephsecretref:: "ceph-secret-jsonnet",
  _volumemounts: [
    "cephconf:/opt/hadoop/etc/hadoop",
  ],
  _volumes: [
    "cephconf:cephfs:/k8s/" + $._mnamespace + "/" + $._suiteprefix + "/hadoop/hdfs/namenode1",
  ],
  _cephhostports:: [
    "10.38.240.29:6789",
    "10.38.240.30:6789",
    "10.38.240.31:6789",
    "10.38.240.32:6789",
    "10.38.240.33:6789",
  ],
  _command:: ["tail", "-f", "/var/log/lastlog"],
}
