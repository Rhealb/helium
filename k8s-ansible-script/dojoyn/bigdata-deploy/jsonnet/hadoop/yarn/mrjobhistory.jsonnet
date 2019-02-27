( import "../../common/deployment.jsonnet" ) + {
  // global variables
  _mrjobhistoryprefix:: "tbd",

  // override super global variables
  _mname: "mrjobhistory",
  _dockerimage:: "10.19.248.12:30100/tools/dep-centos7-hadoop-2.7.3:0.1",
  _envs:: [
    "HADOOP_SERVER_TYPE:mrjobhistory",
    "BD_SUITE_PREFIX:" + $._mrjobhistoryprefix,
  ],
  _cephuser:: "admin",
  _cephsecretref:: "ceph-secret-jsonnet",

  spec+: {
    template+: {
      spec+: {
        hostname: $._mname,
      },
    },
  },
}
