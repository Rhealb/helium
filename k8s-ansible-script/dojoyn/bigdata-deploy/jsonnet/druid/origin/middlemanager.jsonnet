( import "../../common/deployment.jsonnet" ) + {
  // override super global variables
  _mname: "middlemanager",
  _middlemanagerprefix:: "pre",
  _dockerimage:: "10.19.140.200:30100/tools/dep-centos7-druid-0.10.0-liye:0.1",
  _envs:: [
    "DRUID_SERVER_TYPE:middlemanager",
    "BD_SUITE_PREFIX:" + $._middlemanagerprefix,
  ],
  _volumemounts:: [
    "cephconf:/opt/druid/mntconf",
    "cephentry:/opt/entry",
  ],
  _volumes:: [
    "cephconf:cephfs:/k8s/" + super._mnamespace + "/" + $._prefix + "/druid/conf",
    "cephentry:cephfs:/k8s/" + super._mnamespace + "/" + $._prefix + "/druid/entry",
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
