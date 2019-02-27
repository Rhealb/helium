{
  // joiner deploy global variables
  _joinerinstancecount:: 1,
  _joinerreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _joinerdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _joinerrequestcpu:: "0",
  _joinerrequestmem:: "0",
  _joinerlimitcpu:: "0",
  _joinerlimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _joinerexternalports:: [],
  _joinernodeports:: [],
  _joinerexservicetype:: "ClusterIP",
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
  local utils = import "../../common/utils/utils.libsonnet",
  local externalrpcports = $._joinerexternalports.rpcports,

  local noderpcports = $._joinernodeports.rpcports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["joinerutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._joinerexservicetype != "None" then
  [
    (import "../joinerservice.jsonnet") + {
      // override joinerservice global variables
      _joinerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._joinerprefix + "-" + super._mname + num + "-ex",
      _sname: self._joinerprefix + "-" + super._mname + num,
      _servicetype: $._joinerexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "rpcport" + utils.addcolonforport(externalrpcports[num - 1]) + ":23377",

      ],
      _nodeports: [
        "rpcport" + utils.addcolonforport(noderpcports[num - 1]) + ":23377",

      ],
    } for num in std.range(1, $._joinerinstancecount)
  ]
  else
  []) + [
    (import "../joinerservice.jsonnet") + {
      // override joinerservice global variables
      _joinerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._joinerprefix + "-" + super._mname + num,
    } for num in std.range(1, $._joinerinstancecount)
  ] + [
    (import "../joiner.jsonnet") + {
      // override joiner global variables
      _joinerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._joinerprefix + "-" + super._mname + num,
      _dockerimage: $._joinerdockerimage,
      _replicacount: $._joinerreplicas,
      _containerrequestcpu:: $._joinerrequestcpu,
      _containerrequestmem:: $._joinerrequestmem,
      _containerlimitcpu:: $._joinerlimitcpu,
      _containerlimitmem:: $._joinerlimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._joinerprefix,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._joinerinstancecount)
  ],
}
