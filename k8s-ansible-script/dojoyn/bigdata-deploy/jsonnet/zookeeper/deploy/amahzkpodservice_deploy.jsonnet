{
  // amahzk deploy global variables
  _amahzkreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _zkinstancecount:: 1,
  _zkurls:: std.join(",", [$._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]),
  _jmxservers:: std.join(",", [$._suiteprefix + "-" + "zookeeper" + zknum + ":9999" for zknum in std.range(1,$._zkinstancecount)]),
  _amahzkdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahzkrequestcpu:: "0",
  _amahzkrequestmem:: "0",
  _amahzklimitcpu:: "0",
  _amahzklimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahzkexternalports:: [],
  _amahzknodeports:: [],
  _amahzkexservicetype:: "ClusterIP",
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
  local externalamahports = $._amahzkexternalports.amahports,

  local nodeamahports = $._amahzknodeports.amahports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["zkutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahzkexservicetype != "None" then
  [
    (import "../amahzkservice.jsonnet") + {
      // override amahzkservice global variables
      _amahzkprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahzkprefix + "-" + super._mname + "-ex",
      _sname: self._amahzkprefix + "-" + super._mname,
      _servicetype: $._amahzkexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "amahport" + utils.addcolonforport(externalamahports[0]) + ":8084",

      ],
      _nodeports: [
        "amahport" + utils.addcolonforport(nodeamahports[0]) + ":8084",

      ],
    }
  ]
  else
  []) + [
    (import "../amahzkservice.jsonnet") + {
      // override amahzkservice global variables
      _amahzkprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahzkprefix + "-" + super._mname,
    }
  ] + [
    (import "../amahzk.jsonnet") + {
      // override amahzk global variables
      _amahzkprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahzkprefix + "-" + super._mname,
      _dockerimage: $._amahzkdockerimage,
      _replicacount: $._amahzkreplicas,
      _containerrequestcpu:: $._amahzkrequestcpu,
      _containerrequestmem:: $._amahzkrequestmem,
      _containerlimitcpu:: $._amahzklimitcpu,
      _containerlimitmem:: $._amahzklimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahzkprefix,
        "BD_ZK_SERVERS:" + $._zkurls,
        "BD_JMX_SERVERS:" + $._jmxservers,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    }
  ],
}
