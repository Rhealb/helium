{
  // mysql deploy global variables
  _mysqlinstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _mysqldockerimage:: "10.19.140.200:30100/tools/dep-centos7-mysql-5.7.18-liye:0.1",
  _mysqlrequestcpu:: "0",
  _mysqlrequestmem:: "0",
  _mysqllimitcpu:: "0",
  _mysqllimitmem:: "0",
  _mysqlpassword:: "123456",
  _creatdbstart:: "true",
  _databases:: "",

  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _externalports:: {
    mysqlports: [],
  },
  _mysqlnodeports:: {
    mysqlports: [],
  },
  _mysqlexservicetype:: "ClusterIP",
  _utilsstoretype:: "FS",
  _volumemountscommon:: if $._utilsstoretype == "ConfigMap" then
                          [
                            "utilsconf:/opt/mntcephutils/conf:true",
                            "utilsentry:/opt/mntcephutils/entry:true",
                            "utilsscripts:/opt/mntcephutils/scripts:true",
                          ]
                        else if $._utilsstoretype == "FS" then
                          [
                            cephstoragename[0] + ":/opt/mntcephutils:true",
                          ],
  _storagescommon:: if $._utilsstoretype == "ConfigMap" then
                      []
                    else if $._utilsstoretype == "FS" then
                      [
                        cephstoragename[0],
                      ],
  _volumescommon:: if $._utilsstoretype == "ConfigMap" then
                     [
                       "utilsconf:configMap:" + storageprefix + "-" + cephbasename[0] + "-conf",
                       "utilsentry:configMap:" + storageprefix + "-" + cephbasename[0] + "-entry",
                       "utilsscripts:configMap:" + storageprefix + "-" + cephbasename[0] + "-scripts",
                     ]
                   else if $._utilsstoretype == "FS" then
                     [],
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,

  local cephbasename = ["mysqlutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  local utils = import "../../common/utils/utils.libsonnet",
  local externalmysqlports = $._externalports.mysqlports,
  local nodemysqlports = $._mysqlnodeports.mysqlports,
  kind: "List",
  apiVersion: "v1",
  items: (if $._mysqlexservicetype != "None" then
  [
    (import "../mysqlservice.jsonnet") + {
      // override mysqlservice global variables
      _mysqlprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._mysqlprefix + "-" +super._mname + mysqlnum + "-ex",
      _sname: self._mysqlprefix + "-" +super._mname + mysqlnum,
      _servicetype: $._mysqlexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
                {
                  externalIPs: externalips,
                }
             else
                {},
      _nameports: [
        "mysqlport" + utils.addcolonforport(externalmysqlports[mysqlnum - 1]) + ":3306",
      ],
      _nodeports: [
        "mysqlport" + utils.addcolonforport(nodemysqlports[mysqlnum - 1]) + ":3306",
      ],
    } for mysqlnum in std.range(1, $._mysqlinstancecount)
  ]
  else
  []) + [
    (import "../mysqlservice.jsonnet") + {
      // override mysqlservice global variables
      _mysqlprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._mysqlprefix + "-" +super._mname + mysqlnum,
    } for mysqlnum in std.range(1, $._mysqlinstancecount)
  ] + [
    (import "../mysql.jsonnet") + {
      // override mysql global variables
      _mysqlprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._mysqlprefix + "-" + super._mname + mysqlnum,
      _dockerimage: $._mysqldockerimage,
      _containerrequestcpu:: $._mysqlrequestcpu,
      _containerrequestmem:: $._mysqlrequestmem,
      _containerlimitcpu:: $._mysqllimitcpu,
      _containerlimitmem:: $._mysqllimitmem,
      _envs: [
        "MYSQL_ROOT_PASSWORD:" + $._mysqlpassword,
        "BD_SUITE_PREFIX:" + self._mysqlprefix,
        "BD_CREATEDB_START:" + $._creatdbstart,
        "BD_DATABASES:" + std.join(",", [$._databases[num] for num in std.range(0, std.length($._databases) - 1)]),
      ],
      _volumemounts:: $._volumemountscommon + [
                        storageprefix + "-" + "mysqldata:/var/lib/mysql",
                      ],
      _storages:: $._storagescommon + [
                    storageprefix + "-" + "mysqldata",
                  ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh", "mysqld",],
    } for mysqlnum in std.range(1, $._mysqlinstancecount)
  ],
}
