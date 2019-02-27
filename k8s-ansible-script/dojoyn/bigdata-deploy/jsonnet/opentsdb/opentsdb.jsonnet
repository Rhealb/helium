(import "../common/deployment.jsonnet") {
  // override super global variables
  _mname: "opentsdb",
  _mnamespace: "hadoop-jsonnet",
  _dockerimage:: "10.19.132.184:30100/tools/dep-centos7-opentsdb-2.11-0.10.1.1:0.1",
  spec+: {
    template+: {
      metadata+: {
        annotations: {
          "io.enndata.dns/pod.enable":"true",
        }
      }
    }
  },
}
