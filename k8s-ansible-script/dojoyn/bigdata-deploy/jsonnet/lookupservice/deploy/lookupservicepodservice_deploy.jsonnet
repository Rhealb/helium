{
  // lookupservice deploy global variables
  _lookupserviceinstancecount:: 1,
  _lookupservicereplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _lookupservicedockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _lookupservicerequestcpu:: "0",
  _lookupservicerequestmem:: "0",
  _lookupservicelimitcpu:: "0",
  _lookupservicelimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _lookupserviceexternalports:: [],
  _lookupservicenodeports:: [],
  _lookupserviceexservicetype:: "ClusterIP",
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
  local externalrpcports = $._lookupserviceexternalports.rpcports,

  local noderpcports = $._lookupservicenodeports.rpcports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["lookupserviceutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._lookupserviceexservicetype != "None" then
  [
    (import "../lookupserviceservice.jsonnet") + {
      // override lookupserviceservice global variables
      _lookupserviceprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._lookupserviceprefix + "-" + super._mname + num + "-ex",
      _sname: self._lookupserviceprefix + "-" + super._mname + num,
      _servicetype: $._lookupserviceexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "rpcport" + utils.addcolonforport(externalrpcports[num - 1]) + ":50051",

      ],
      _nodeports: [
        "rpcport" + utils.addcolonforport(noderpcports[num - 1]) + ":50051",

      ],
    } for num in std.range(1, $._lookupserviceinstancecount)
  ]
  else
  []) + [
    (import "../lookupserviceservice.jsonnet") + {
      // override lookupserviceservice global variables
      _lookupserviceprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._lookupserviceprefix + "-" + super._mname + num,
    } for num in std.range(1, $._lookupserviceinstancecount)
  ] + [
    (import "../lookupservice.jsonnet") + {
      // override lookupservice global variables
      _lookupserviceprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._lookupserviceprefix + "-" + super._mname + num,
      _dockerimage: $._lookupservicedockerimage,
      _replicacount: $._lookupservicereplicas,
      _containerrequestcpu:: $._lookupservicerequestcpu,
      _containerrequestmem:: $._lookupservicerequestmem,
      _containerlimitcpu:: $._lookupservicelimitcpu,
      _containerlimitmem:: $._lookupservicelimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._lookupserviceprefix,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._lookupserviceinstancecount)
  ],
}
