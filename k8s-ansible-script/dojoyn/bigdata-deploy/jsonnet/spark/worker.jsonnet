(import "../common/deployment.jsonnet") {
  // global variables
  _workerprefix:: "tbd",

  // override super global variables
  _mname: "worker",
  _mnamespace: "hadoop-jsonnet",
  _dockerimage:: "10.19.132.184:30100/tools/dep-centos7-spark-2.11-hadoop-2.7:0.1",
  _envs:: [
    "SPARK_SERVER_TYPE:worker",
    "BD_SUITE_PREFIX:" + $._workerprefix,
  ],
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