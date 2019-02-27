( import "../common/deployment.jsonnet" ) + {
  // override super global variables
  _mname: "mysql",
  _mysqlprefix:: "pre",
  _dockerimage:: "10.19.140.200:30100/tools/dep-centos7-mysql-5.7.18-liye:0.1",
  _envs:: [
    "MYSQL_ROOT_PASSWORD:123456",
    "BD_SUITE_PREFIX:" + $._mysqlprefix,
  ],
  _volumemounts:: [
  ],
  _volumes:: [
  ],
  _cephhostports:: [
    "10.19.248.27:6789",
    "10.19.248.28:6789",
    "10.19.248.29:6789",
    "10.19.248.30:6789",
  ],
  _command:: ["docker-entrypoint.sh", "mysqld"],
  _cephuser:: "admin",
  _cephsecretref:: "ceph-secret-jsonnet",
}
