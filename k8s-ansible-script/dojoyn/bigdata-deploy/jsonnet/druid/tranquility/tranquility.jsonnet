( import "../../common/deployment.jsonnet" ) + {
  // override super global variables
  _mname: "tranquility",
  _prefix:: "pre",
  _dockerimage:: "10.19.140.200:30100/tools/dep-centos7-tranquility-0.8.2-liye:0.1",
  _envs:: [
  ],
  _volumemounts:: [
    "cephconf:/opt/tranquility/mntconf",
    "cephentry:/opt/entry",
  ],
  _volumes:: [
    "cephconf:cephfs:/k8s/" + super._mnamespace + "/" + $._prefix + "/tranquility/conf",
    "cephentry:cephfs:/k8s/" + super._mnamespace + "/" + $._prefix + "/tranquility/entry",
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
}