{
  // statemanager deploy global variables
  _statemanagerinstancecount:: 1,
  _statemanagerreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _statemanagerdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _statemanagerrequestcpu:: "0",
  _statemanagerrequestmem:: "0",
  _statemanagerlimitcpu:: "0",
  _statemanagerlimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _statemanagerexternalports:: [],
  _statemanagernodeports:: [],
  _statemanagerexservicetype:: "ClusterIP",
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
  
  
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["statemanagerutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._statemanagerexservicetype != "None" then
  [
    (import "../statemanagerservice.jsonnet") + {
      // override statemanagerservice global variables
      _statemanagerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._statemanagerprefix + "-" + super._mname + num + "-ex",
      _sname: self._statemanagerprefix + "-" + super._mname + num,
      _servicetype: $._statemanagerexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        
      ],
      _nodeports: [
        
      ],
    } for num in std.range(1, $._statemanagerinstancecount)
  ]
  else
  []) + [
    (import "../statemanagerservice.jsonnet") + {
      // override statemanagerservice global variables
      _statemanagerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._statemanagerprefix + "-" + super._mname + num,
    } for num in std.range(1, $._statemanagerinstancecount)
  ] + [
    (import "../statemanager.jsonnet") + {
      // override statemanager global variables
      _statemanagerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._statemanagerprefix + "-" + super._mname + num,
      _dockerimage: $._statemanagerdockerimage,
      _replicacount: $._statemanagerreplicas,
      _containerrequestcpu:: $._statemanagerrequestcpu,
      _containerrequestmem:: $._statemanagerrequestmem,
      _containerlimitcpu:: $._statemanagerlimitcpu,
      _containerlimitmem:: $._statemanagerlimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._statemanagerprefix,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._statemanagerinstancecount)
  ],
}
