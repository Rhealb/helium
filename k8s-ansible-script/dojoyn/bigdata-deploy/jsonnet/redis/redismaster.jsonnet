(import "../common/statefulset.jsonnet") {
  // global variables
  _redismasterprefix:: "tbd",

  // override super global variables
  _mname: "redismaster",
  _mnamespace: "hadoop-jsonnet",
  _dockerimage:: "10.19.248.12:30100/tools/dep-centos7-plyql-0.11.2:0.1",
  _envs: [
  ],
  spec+: {
    serviceName: $._redismasterprefix + "-redis",
    podManagementPolicy: "Parallel",
    template+: {
      metadata+: {
        annotations: {
          "io.enndata.dns/pod.enable":"true",
        },
        labels+: {
          "rediscluster-node": "true",
        }, 
      },
    },
  },
  _command:: ["/opt/entrypoint.sh", ],
}
