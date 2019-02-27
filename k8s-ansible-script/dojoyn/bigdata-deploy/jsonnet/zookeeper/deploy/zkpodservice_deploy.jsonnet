{
  // zookeeper deploy global variables
  _zkinstancecount:: 3,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _zkdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _zkrequestcpu:: "0",
  _zkrequestmem:: "0",
  _zklimitcpu:: "0",
  _zklimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _zkpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _externalports::{
    clientports:: [],
    adminserverports:: [],
  },
  _zknodeports::{
    clientports: [],
    adminserverports: [],
  },
  _zkexservicetype:: "ClusterIP",
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
  local utils = import "../../common/utils/utils.libsonnet",
  local externalclientports = $._externalports.clientports,
  local externaladminserverports = $._externalports.adminserverports,
  local nodeclientports = $._zknodeports.clientports,
  local nodeadminserverports = $._zknodeports.adminserverports,
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,

  local cephbasename = ["zkutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._zkexservicetype != "None" then
  [
    (import "../zookeeperservice.jsonnet") + {
      // override zookeeperservice global variables
      _zkprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._zkprefix + "-" + super._mname + znum + "-ex",
      _sname: self._zkprefix + "-" + super._mname + znum,
      _servicetype: $._zkexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips
               }
             else
               {},
      _nameports: [
        "clientport" + utils.addcolonforport(externalclientports[znum - 1]) + ":2181",
        "adminserverport" + utils.addcolonforport(externaladminserverports[znum - 1]) + ":8080",
      ],
      _nodeports: [
        "clientport" + utils.addcolonforport(nodeclientports[znum - 1]) + ":2181",
        "adminserverport" + utils.addcolonforport(nodeadminserverports[znum - 1]) + ":8080",
      ],
    } for znum in std.range(1, $._zkinstancecount)
  ]
  else
  []) + [
    (import "../zookeeperservice.jsonnet") + {
      // override zookeeperservice global variables
      _zkprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._zkprefix + "-" + super._mname + znum,
    } for znum in std.range(1, $._zkinstancecount)
  ] + [
    (import "../zookeeper.jsonnet") + {
      // override zookeeper global variables
      _zkprefix: $._suiteprefix,
      _serverid: znum,
      _maxservers: $._zkinstancecount,
      _mnamespace: $._namespace,
      _mname: self._zkprefix + "-" + super._mname + znum,
      _dockerimage: $._zkdockerimage,
      _containerrequestcpu:: $._zkrequestcpu,
      _containerrequestmem:: $._zkrequestmem,
      _containerlimitcpu:: $._zklimitcpu,
      _containerlimitmem:: $._zklimitmem,
      _podantiaffinitytype: $._zkpodantiaffinitytype,
      _podantiaffinitytag: self._zkprefix + "-" + "zookeeper",
      _podantiaffinityns: [self._mnamespace,],
      _volumemounts:: $._volumemountscommon + [
                        storageprefix + "-" + "zk" + znum + "data:/data",
                        storageprefix + "-" + "zk" + znum + "datalog:/datalog",
                      ],
      _storages:: $._storagescommon + [
                    storageprefix + "-" + "zk" + znum + "data",
                    storageprefix + "-" + "zk" + znum + "datalog",
                  ],
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for znum in std.range(1, $._zkinstancecount)
  ],
}
