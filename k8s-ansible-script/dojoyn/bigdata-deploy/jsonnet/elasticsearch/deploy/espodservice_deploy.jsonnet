{
  // elasticsearch deploy global variables
  _esdatainstancecount:: 3,
  _esclientinstancecount:: 3,
  _esmasterinstancecount:: 3,

  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _esmasterservers:: std.join(",", [self._suiteprefix + "-" + "esmaster" + esmasternum for esmasternum in std.range(1,$._esmasterinstancecount)]),
  _esdatarequestcpu:: "0",
  _esdatarequestmem:: "0",
  _esdatalimitcpu:: "0",
  _esdatalimitmem:: "0",
  _esdatajavaxms:: "2g",
  _esdatajavaxmx:: "2g",
  _escientrequestcpu:: "0",
  _escientrequestmem:: "0",
  _escientlimitcpu:: "0",
  _escientlimitmem:: "0",
  _escientjavaxms:: "2g",
  _escientjavaxmx:: "2g",
  _esmasterrequestcpu:: "0",
  _esmasterrequestmem:: "0",
  _esmasterlimitcpu:: "0",
  _esmasterlimitmem:: "0",
  _esmasterjavaxms:: "2g",
  _esmasterjavaxmx:: "2g",
  _esprivileged:: true,
  _esdockerimage:: "",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _esmasterpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _esexternalports:: {
    httpports: [],
    transports: [],
  },
  _esnodeports:: {
    httpports: [],
    transports: [],
  },
  _esexservicetype:: "ClusterIP",
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
  local datadir = "datadir",
  local cephbasename = [
    "esutils"
  ],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  local utils = import "../../common/utils/utils.libsonnet",
  local externalhttpports = $._esexternalports.httpports,
  local externaltransports = $._esexternalports.transports,
  local nodehttpports = $._esnodeports.httpports,
  local nodetransports = $._esnodeports.transports,

  kind: "List",
  apiVersion: "v1",
  items: [
    (import "../esmasterservice.jsonnet") + {
      // override esmasterservice global variables
      _mnamespace: $._namespace,
      _mname: $._suiteprefix + "-esmaster" + esmasternum,
    } for esmasternum in std.range(1, $._esmasterinstancecount)
  ] + [
    (import "../esmaster.jsonnet") + {
      // override esmaster global variables
      _mnamespace: $._namespace,
      _mname: $._suiteprefix + "-esmaster" + esmasternum,
      _dockerimage: $._esdockerimage,
      _containerrequestcpu: $._esmasterrequestcpu,
      _containerrequestmem: $._esmasterrequestmem,
      _containerlimitcpu: $._esmasterlimitcpu,
      _containerlimitmem: $._esmasterlimitmem,
      _podantiaffinitytype: $._esmasterpodantiaffinitytype,
      _podantiaffinitytag: $._suiteprefix + "-esmaster",
      _podantiaffinityns: [self._mnamespace,],
      _privileged: $._esprivileged,
      _envs: [
        "BD_NODE_MASTER:true",
        "BD_NODE_DATA:false",
        "BD_NODE_INGEST:false",
        "BD_SEARCH_REMOTE_CONNECT:true",
        "BD_ESMASTER_SERVERS:" + $._esmasterservers,
        "BD_DISCOVERY_MINIMUM_MASTER_NODES:" + std.floor($._esmasterinstancecount/2 + 1),
        "BD_PUBLISH_HOST:0.0.0.0",
        "BD_PUBLISH_PORT:9300",
        "BD_JAVA_XMS:" + "-Xms" + $._esmasterjavaxms,
        "BD_JAVA_XMX:" + "-Xmx" + $._esmasterjavaxmx,
        "BD_MAX_MAP_COUNT:655360",
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh",],
    } for esmasternum in std.range(1, $._esmasterinstancecount)
  ] + (if $._esexservicetype != "None" then
  [
    (import "../esclientservice.jsonnet") + {
      // override esclientservice global variables
      _mnamespace: $._namespace,
      _mname: $._suiteprefix + "-esclient-ex",
      _sname: $._suiteprefix + "-esclient",
      _servicetype: $._esexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "httpport" + utils.addcolonforport(externalhttpports[0]) + ":9200",
        "transport" + utils.addcolonforport(externaltransports[0]) + ":9300",
      ],
      _nodeports: [
        "httpport" + utils.addcolonforport(nodehttpports[0]) + ":9200",
        "transport" + utils.addcolonforport(nodetransports[0]) + ":9300",
      ],
    },
  ]
  else
  []) + [
    (import "../esdataclient.jsonnet") + {
      // override esclient global variables
      _replicacount: $._esclientinstancecount,
      _mnamespace: $._namespace,
      _mname: $._suiteprefix + "-esclient",
      _dockerimage: $._esdockerimage,
      _containerrequestcpu: $._esclientrequestcpu,
      _containerrequestmem: $._esclientrequestmem,
      _containerlimitcpu: $._esclientlimitcpu,
      _containerlimitmem: $._esclientlimitmem,
      _privileged: $._esprivileged,
      _envs: [
        "BD_NODE_MASTER:false",
        "BD_NODE_DATA:false",
        "BD_NODE_INGEST:true",
        "BD_SEARCH_REMOTE_CONNECT:true",
        "BD_ESMASTER_SERVERS:" + $._esmasterservers,
        "BD_DISCOVERY_MINIMUM_MASTER_NODES:" + std.floor($._esmasterinstancecount/2 + 1),
        "BD_PUBLISH_HOST:0.0.0.0",
        "BD_PUBLISH_PORT:9300",
        "BD_JAVA_XMS:" +  "-Xms" + $._esclientjavaxms,
        "BD_JAVA_XMX:" +  "-Xmx" + $._esclientjavaxmx,
        "BD_MAX_MAP_COUNT:655360",
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh",],
    },
  ] + [
    (import "../esdataclient.jsonnet") + {
      // override esdata global variables
      _replicacount: $._esdatainstancecount,
      _mnamespace: $._namespace,
      _mname: $._suiteprefix + "-esdata",
      _dockerimage: $._esdockerimage,
      _containerrequestcpu: $._esdatarequestcpu,
      _containerrequestmem: $._esdatarequestmem,
      _containerlimitcpu: $._esdatalimitcpu,
      _containerlimitmem: $._esdatalimitmem,
      _privileged: $._esprivileged,
      _envs: [
        "BD_NODE_MASTER:false",
        "BD_NODE_DATA:true",
        "BD_NODE_INGEST:false",
        "BD_SEARCH_REMOTE_CONNECT:true",
        "BD_ESMASTER_SERVERS:" + $._esmasterservers,
        "BD_DISCOVERY_MINIMUM_MASTER_NODES:" + std.floor($._esmasterinstancecount/2 + 1),
        "BD_PUBLISH_HOST:0.0.0.0",
        "BD_PUBLISH_PORT:9300",
        "BD_JAVA_XMS:" +  "-Xms" + $._esdatajavaxms,
        "BD_JAVA_XMX:" +  "-Xmx" + $._esdatajavaxmx,
        "BD_MAX_MAP_COUNT:655360",
      ],
      _volumemounts:: $._volumemountscommon + [
                                                storageprefix + "-" + "esdatadir" + ":/opt/elasticsearch/data",
                                              ],
      _storages:: $._storagescommon + [
                                        storageprefix + "-" + "esdatadir",
                                      ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh",],
    },
  ],
}
