{
  // kfaka deploy global variables
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _kafkamanagerinstancecount:: 1,
  _zkinstancecount:: 3,
  _zkservers:: std.join(",", [$._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]),
  _kafkamanagerdockerimage:: "10.19.132.184:30100/tools/dep-centos7-kafka-2.11-0.10.1.1:0.1",
  _kafkamanagerrequestcpu:: "0",
  _kafkamanagerrequestmem:: "0",
  _kafkamanagerlimitcpu:: "0",
  _kafkamanagerlimitmem:: "0",
  _externalips:: ["10.37.151.21", "10.37.151.22", "10.37.151.23"],
  _externalports:: {
    httpports: [],
  },
  _kafkamanagernodeports:: {
    httpports: [],
  },
  _kafkamanagerexservicetype:: "ClusterIP",
  _utilsstoretype:: "ConfigMap",
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
  local cephbasename = ["kafkamanagerutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  local utils = import "../../common/utils/utils.libsonnet",
  local externalhttpports = $._externalports.httpports,
  local nodehttpports = $._kafkamanagernodeports.httpports,
  kind: "List",
  apiVersion: "v1",
  items: (if $._kafkamanagerexservicetype != "None" then
  [
    (import "../kafkamanagerservice.jsonnet") + {
      // override kafkamanagerservice global variables
      _kafkamanagerprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._kafkamanagerprefix + "-" + super._mname,
      _servicetype: $._kafkamanagerexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "httpport" + utils.addcolonforport(externalhttpports[0]) + ":9000",
      ],
      _nodeports: [
        "httpport" + utils.addcolonforport(nodehttpports[0]) + ":9000",
      ],
    },
  ]
  else
  []) + [
    (import "../kafkamanager.jsonnet") + {
      // override kafkamanager global variables
      _kafkamanagerprefix:: $._suiteprefix,
      _replicacount: $._kafkamanagerinstancecount,
      _mnamespace: $._namespace,
      _mname: self._kafkamanagerprefix + "-" + super._mname,
      _dockerimage: $._kafkamanagerdockerimage,
      _containerrequestcpu:: $._kafkamanagerrequestcpu,
      _containerrequestmem:: $._kafkamanagerrequestmem,
      _containerlimitcpu:: $._kafkamanagerlimitcpu,
      _containerlimitmem:: $._kafkamanagerlimitmem,
      _envs: [
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh",],
    },
  ],
}
