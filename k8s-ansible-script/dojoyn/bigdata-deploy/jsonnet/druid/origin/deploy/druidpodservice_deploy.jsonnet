{
  // druid deploy global variables
  _brokerinstancecount:: 1,
  _coordinatorinstancecount:: 1,
  _historicalinstancecount:: 1,
  _middlemanagerinstancecount:: 1,
  _overlordinstancecount:: 1,
  _zkinstancecount:: 3,
  _jninstancecount:: 3,
  _zkservers:: std.join(",", [$._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]),
  _journalnodeservers::  std.join(";", [$._suiteprefix + "-" + "journalnode" + jnnum + ":8485" for jnnum in std.range(1,$._jninstancecount)]),
  _mysqlpasswd:: "123456",
  _mysqlusername:: "root",
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _druiddockerimage:: "10.19.140.200:30100/tools/dep-centos7-druid-0.10.0-liye:0.1",
  _brokerrequestcpu:: "0",
  _brokerrequestmem:: "0",
  _brokerlimitcpu:: "0",
  _brokerlimitmem:: "0",
  _coordinatorrequestcpu:: "0",
  _coordinatorrequestmem:: "0",
  _coordinatorlimitcpu:: "0",
  _coordinatorlimitmem:: "0",
  _historicalrequestcpu:: "0",
  _historicalrequestmem:: "0",
  _historicallimitcpu:: "0",
  _historicallimitmem:: "0",
  _middlemanagerrequestcpu:: "0",
  _middlemanagerrequestmem:: "0",
  _middlemanagerlimitcpu:: "0",
  _middlemanagerlimitmem:: "0",
  _overlordrequestcpu:: "0",
  _overlordrequestmem:: "0",
  _overlordlimitcpu:: "0",
  _overlordlimitmem:: "0",

  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _overlordpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _coordinatorpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _histsegmentcachepvcstoragesize:: "200Mi",
  _externalports:: {
    brokerports: [],
    coordports: [],
    overlordports: [],
  },
  _druidnodeports:: {
    brokerports: [],
    coordports: [],
    overlordports: [],
  },
  _druidexservicetype:: "ClusterIP",
  _utilsstoretype:: "FS",
  _volumemountscommon:: if $._utilsstoretype == "ConfigMap" then
                          [
                            "utilsconfbroker:/opt/mntcephutils/conf/broker:true",
                            "utilsconfcommon:/opt/mntcephutils/conf/_common:true",
                            "utilsconfcoordinator:/opt/mntcephutils/conf/coordinator:true",
                            "utilsconfhistorical:/opt/mntcephutils/conf/historical:true",
                            "utilsconfmiddlemanager:/opt/mntcephutils/conf/middleManager:true",
                            "utilsconfoverlord:/opt/mntcephutils/conf/overlord:true",
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
                       "utilsconfbroker:configMap:" + storageprefix + "-" + cephbasename[0] + "-confbroker",
                       "utilsconfcommon:configMap:" + storageprefix + "-" + cephbasename[0] + "-confcommon",
                       "utilsconfcoordinator:configMap:" + storageprefix + "-" + cephbasename[0] + "-confcoordinator",
                       "utilsconfhistorical:configMap:" + storageprefix + "-" + cephbasename[0] + "-confhistorical",
                       "utilsconfmiddlemanager:configMap:" + storageprefix + "-" + cephbasename[0] + "-confmiddlemanager",
                       "utilsconfoverlord:configMap:" + storageprefix + "-" + cephbasename[0] + "-confoverlord",
                       "utilsentry:configMap:" + storageprefix + "-" + cephbasename[0] + "-entry",
                       "utilsscripts:configMap:" + storageprefix + "-" + cephbasename[0] + "-scripts",
                     ]
                   else if $._utilsstoretype == "FS" then
                     [],
  local externalips = $._externalips,
  local histsegmentcache = "histsegmentcache",
  local mmsegments = "mmsegments",
  local storageprefix = $._suiteprefix,

  local cephbasename = ["druidutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  local utils = import "../../../common/utils/utils.libsonnet",
  local externalbrokerports = $._externalports.brokerports,
  local externalcoordports = $._externalports.coordports,
  local externaloverlordports = $._externalports.overlordports,

  local nodebrokerports = $._druidnodeports.brokerports,
  local nodecoordports = $._druidnodeports.coordports,
  local nodeoverlordports = $._druidnodeports.overlordports,

  kind: "List",
  apiVersion: "v1",
  items: (if $._druidexservicetype != "None" then
  [
    (import "../brokerservice.jsonnet") + {
      // override brokerservice global variables
      _brokerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._brokerprefix + "-" + super._mname + "-ex",
      _sname: self._brokerprefix + "-" + super._mname,
      _servicetype: $._druidexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "brokerport" + utils.addcolonforport(externalbrokerports[0]) + ":8082",
      ],
      _nodeports: [
        "brokerport" + utils.addcolonforport(nodebrokerports[0]) + ":8082",
      ],
    },
  ]
  else
  []) + [
    (import "../brokerservice.jsonnet") + {
      // override brokerservice global variablesConfigMap
      _brokerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._brokerprefix + "-" + super._mname,
    },
  ] + [
    (import "../broker.jsonnet") + {
      // override broker global variables
      _brokerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._brokerprefix + "-" + super._mname,
      _dockerimage: $._druiddockerimage,
      _replicacount: $._brokerinstancecount,
      _containerrequestcpu:: $._brokerrequestcpu,
      _containerrequestmem:: $._brokerrequestmem,
      _containerlimitcpu:: $._brokerlimitcpu,
      _containerlimitmem:: $._brokerlimitmem,
      _envs: [
        "DRUID_SERVER_TYPE:broker",
        "BD_SUITE_PREFIX:" + self._brokerprefix,
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
        "BD_JOURNALNODE_SERVERS:" + $._journalnodeservers,
        "BD_MYSQL_PASSWD:" + $._mysqlpasswd,
        "BD_MYSQL_USERNAME:" + $._mysqlusername,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
    },
  ] + (if $._druidexservicetype != "None" then
  [
    (import "../coordinatorservice.jsonnet") + {
      // override coordinatorservice global variables
      _coordinatorprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._coordinatorprefix + "-" + super._mname + coordinatornum + "-ex",
      _sname: self._coordinatorprefix + "-" + super._mname + coordinatornum,
      _servicetype: $._druidexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "coordport" + utils.addcolonforport(externalcoordports[coordinatornum - 1]) + ":8081",
      ],
      _nodeports: [
        "coordport" + utils.addcolonforport(nodecoordports[coordinatornum - 1]) + ":8081",
      ],
    } for coordinatornum in std.range(1, $._coordinatorinstancecount)
  ]
  else
  []) + [
    (import "../coordinatorservice.jsonnet") + {
      // override coordinatorservice global variables
      _coordinatorprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._coordinatorprefix + "-" + super._mname + coordinatornum,
    } for coordinatornum in std.range(1, $._coordinatorinstancecount)
  ] + [
    (import "../coordinator.jsonnet") + {
      // override coordinator global variables
      _coordinatorprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._coordinatorprefix + "-" + super._mname + coordinatornum,
      _dockerimage: $._druiddockerimage,
      _containerrequestcpu:: $._coordinatorrequestcpu,
      _containerrequestmem:: $._coordinatorrequestmem,
      _containerlimitcpu:: $._coordinatorlimitcpu,
      _containerlimitmem:: $._coordinatorlimitmem,
      _podantiaffinitytype: $._coordinatorpodantiaffinitytype,
      _podantiaffinitytag: self._coordinatorprefix + "-" + "coordinator",
      _podantiaffinityns: [self._mnamespace,],
      _envs: [
        "DRUID_SERVER_TYPE:coordinator",
        "BD_SUITE_PREFIX:" + self._coordinatorprefix,
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
        "BD_JOURNALNODE_SERVERS:" + $._journalnodeservers,
        "BD_MYSQL_PASSWD:" + $._mysqlpasswd,
        "BD_MYSQL_USERNAME:" + $._mysqlusername,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
    } for coordinatornum in std.range(1, $._coordinatorinstancecount)
  ] + [
    (import "../historical.jsonnet") + {
      // override historical global variables
      _historicalprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._historicalprefix + "-" + super._mname,
      _dockerimage: $._druiddockerimage,
      _replicacount: $._historicalinstancecount,
      _containerrequestcpu:: $._historicalrequestcpu,
      _containerrequestmem:: $._historicalrequestmem,
      _containerlimitcpu:: $._historicallimitcpu,
      _containerlimitmem:: $._historicallimitmem,
      _envs: [
        "DRUID_SERVER_TYPE:historical",
        "BD_SUITE_PREFIX:" + self._historicalprefix,
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
        "BD_JOURNALNODE_SERVERS:" + $._journalnodeservers,
        "BD_MYSQL_PASSWD:" + $._mysqlpasswd,
        "BD_MYSQL_USERNAME:" + $._mysqlusername,
      ],
      _volumemounts:: $._volumemountscommon + [
                            storageprefix + "-" + histsegmentcache + ":/opt/druid/var/druid",
                          ],
      _storages:: $._storagescommon + [
                        storageprefix + "-" + histsegmentcache,
                      ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
    },
  ] + [
    (import "../middlemanager.jsonnet") + {
      // override middlemanager global variables
      _middlemanagerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._middlemanagerprefix + "-" + super._mname,
      _dockerimage: $._druiddockerimage,
      _replicacount: $._middlemanagerinstancecount,
      _containerrequestcpu:: $._middlemanagerrequestcpu,
      _containerrequestmem:: $._middlemanagerrequestmem,
      _containerlimitcpu:: $._middlemanagerlimitcpu,
      _containerlimitmem:: $._middlemanagerlimitmem,
      _envs: [
        "DRUID_SERVER_TYPE:middlemanager",
        "BD_SUITE_PREFIX:" + self._middlemanagerprefix,
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
        "BD_JOURNALNODE_SERVERS:" + $._journalnodeservers,
        "BD_MYSQL_PASSWD:" + $._mysqlpasswd,
        "BD_MYSQL_USERNAME:" + $._mysqlusername,
      ],
      _volumemounts:: $._volumemountscommon + [
                            storageprefix + "-" + mmsegments + ":/opt/druid/var",
                          ],
      _storages:: $._storagescommon + [
                        storageprefix + "-" + mmsegments,
                      ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
    },
  ] + (if $._druidexservicetype != "None" then
  [
    (import "../overlordservice.jsonnet") + {
      // override overlordservice global variables
      _overlordprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._overlordprefix + "-" + super._mname + overlordnum + "-ex",
      _sname: self._overlordprefix + "-" + super._mname + overlordnum,
      _servicetype: $._druidexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "overlordport" + utils.addcolonforport(externaloverlordports[overlordnum - 1]) + ":8090",
      ],
      _nodeports: [
        "overlordport" + utils.addcolonforport(nodeoverlordports[overlordnum - 1]) + ":8090",
      ],
    } for overlordnum in std.range(1, $._overlordinstancecount)
  ]
  else
  []) + [
    (import "../overlordservice.jsonnet") + {
      // override overlordservice global variables
      _overlordprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._overlordprefix + "-" + super._mname + overlordnum,
    } for overlordnum in std.range(1, $._overlordinstancecount)
  ] + [
    (import "../overlord.jsonnet") + {
      // override overlord global variables
      _overlordprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._overlordprefix + "-" + super._mname + overlordnum,
      _dockerimage: $._druiddockerimage,
      _containerrequestcpu:: $._overlordrequestcpu,
      _containerrequestmem:: $._overlordrequestmem,
      _containerlimitcpu:: $._overlordlimitcpu,
      _containerlimitmem:: $._overlordlimitmem,
      _podantiaffinitytype: $._overlordpodantiaffinitytype,
      _podantiaffinitytag: self._overlordprefix + "-" + "overlord",
      _podantiaffinityns: [self._mnamespace,],
      _envs: [
        "DRUID_SERVER_TYPE:overlord",
        "BD_SUITE_PREFIX:" + self._overlordprefix,
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
        "BD_JOURNALNODE_SERVERS:" + $._journalnodeservers,
        "BD_MYSQL_PASSWD:" + $._mysqlpasswd,
        "BD_MYSQL_USERNAME:" + $._mysqlusername,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
    } for overlordnum in std.range(1, $._overlordinstancecount)
  ],
}
