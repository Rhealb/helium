{
  // spark deploy global variables
  _masterinstancecount:: 1,
  _workerinstancecount:: 1,
  _historyserverinstancecount:: 1,
  _localdirstoragecount:: 1,
  _zkinstancecount:: 3,
  _jninstancecount:: 3,
  _sparkeventlogdir:: "hdfs://enncloud-hadoop/var/log/spark",
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _sparkdockerimage:: "10.19.132.184:30100/tools/dep-centos7-spark-2.11-hadoop-2.7:0.1",
  _masterrequestcpu:: "0",
  _masterrequestmem:: "0",
  _masterlimitcpu:: "0",
  _masterlimitmem:: "0",
  _workerrequestcpu:: "0",
  _workerrequestmem:: "0",
  _workerlimitcpu:: "0",
  _workerlimitmem:: "0",
  _sparkworkercores:: "1",
  _historyserverrequestcpu:: "0",
  _historyserverrequestmem:: "0",
  _historyserverlimitcpu:: "0",
  _historyserverlimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _masterpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _externalports:: {
    masteruiports:[],
    masterports: [],
    applicationuiports: [],
    restports: [],
    historyuiports: [],
  },

  _sparknodeports:: {
    masteruiports: [],
    masterports: [],
    applicationuiports: [],
    restports: [],
    historyuiports: [],
  },
  _sparkexservicetype:: "ClusterIP",
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
  local cephbasename = ["sparkutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  local utils = import "../../common/utils/utils.libsonnet",
  local externalmasteruiports = $._externalports.masteruiports,
  local externalmasterports = $._externalports.masterports,
  local externalapplicationuiports = $._externalports.applicationuiports,
  local externalrestports = $._externalports.restports,
  local externalhistoryuiports = $._externalports.historyuiports,
  local nodemasteruiports = $._sparknodeports.masteruiports,
  local nodemasterports = $._sparknodeports.masterports,
  local nodeapplicationuiports = $._sparknodeports.applicationuiports,
  local noderestports = $._sparknodeports.restports,
  local nodehistoryuiports = $._sparknodeports.historyuiports,

  kind: "List",
  apiVersion: "v1",
  items: ( if $._sparkexservicetype != "None" then
  [
    (import "../masterservice.jsonnet") + {
      // override masterservice global variables
      _masterprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._masterprefix + "-" + super._mname + masternum + "-ex",
      _sname: self._masterprefix + "-" + super._mname + masternum,
      _servicetype: $._sparkexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "masteruiport" + utils.addcolonforport(externalmasteruiports[masternum - 1]) + ":8080",
        "masterport" + utils.addcolonforport(externalmasterports[masternum - 1]) + ":7077",
        "applicationuiport" + utils.addcolonforport(externalapplicationuiports[masternum - 1]) + ":4040",
        "restport" + utils.addcolonforport(externalrestports[masternum - 1]) + ":6066",
      ],
      _nodeports: [
        "masteruiport" + utils.addcolonforport(nodemasteruiports[masternum - 1]) + ":8080",
        "masterport" + utils.addcolonforport(nodemasterports[masternum - 1]) + ":7077",
        "applicationuiport" + utils.addcolonforport(nodeapplicationuiports[masternum - 1]) + ":4040",
        "restport" + utils.addcolonforport(noderestports[masternum - 1]) + ":6066",
      ],
    } for masternum in std.range(1, $._masterinstancecount)
  ]
  else
  []) + [
    (import "../masterservice.jsonnet") + {
      // override masterservice global variables
      _masterprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._masterprefix + "-" + super._mname + masternum,
    } for masternum in std.range(1, $._masterinstancecount)
  ] + [
    (import "../master.jsonnet") + {
      // override master global variables
      _masterprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._masterprefix + "-" + super._mname + mastermnum,
      _dockerimage: $._sparkdockerimage,
      _containerrequestcpu:: $._masterrequestcpu,
      _containerrequestmem:: $._masterrequestmem,
      _containerlimitcpu:: $._masterlimitcpu,
      _containerlimitmem:: $._masterlimitmem,
      _podantiaffinitytype: $._masterpodantiaffinitytype,
      _podantiaffinitytag: self._masterprefix + "-" + "master",
      _podantiaffinityns: [self._mnamespace,],
      _envs: [
        "SPARK_SERVER_TYPE:master",
        "HADOOP_CONF_DIR:/opt/spark/conf",
        "BD_SUITE_PREFIX:" + self._masterprefix,
        "BD_ZOOKEEPER_SERVERS:" + std.join(",", [$._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]),
        "BD_JOURNALNODE_SERVERS:" + std.join(";", [$._suiteprefix + "-" + "journalnode" + jnnum + ":8485" for jnnum in std.range(1,$._jninstancecount)]),
        "BD_ENENTLOG_DIR:" + $._sparkeventlogdir,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
    } for mastermnum in std.range(1, $._masterinstancecount)
  ] + [
    (import "../worker.jsonnet") + {
      // override worker global variables
      _workerprefix: $._suiteprefix,
	    _replicacount: $._workerinstancecount,
      _mnamespace: $._namespace,
      _mname: self._workerprefix + "-" + super._mname,
      _dockerimage: $._sparkdockerimage,
      _containerrequestcpu:: $._workerrequestcpu,
      _containerrequestmem:: $._workerrequestmem,
      _containerlimitcpu:: $._workerlimitcpu,
      _containerlimitmem:: $._workerlimitmem,
      _envs: [
        "SPARK_SERVER_TYPE:worker",
        "BD_SUITE_PREFIX:" + self._workerprefix,
        "BD_ZOOKEEPER_SERVERS:" + std.join(",", [$._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]),
        "BD_JOURNALNODE_SERVERS:" + std.join(";", [$._suiteprefix + "-" + "journalnode" + jnnum + ":8485" for jnnum in std.range(1,$._jninstancecount)]),
        "BD_ENENTLOG_DIR:" + $._sparkeventlogdir,
        "BD_SPARK_MASTER_SERVERS:" + std.join(",", [$._suiteprefix + "-" + "master" + masternum + ":7077" for masternum in std.range(1,$._masterinstancecount)]),
        "BD_SPARK_WORKER_CORES:" + $._sparkworkercores,
      ],
      _volumemounts::  $._volumemountscommon + [
                         storageprefix + "-spworkerworkdir:/opt/spark/work",
                       ] + [
                             storageprefix + "-spworkerlocaldir" + localdirnum + ":/tmp/local/dir" + localdirnum for localdirnum in std.range(1, $._localdirstoragecount)
                           ],
      _storages:: $._storagescommon + [
                    storageprefix + "-spworkerworkdir",
                  ] + [
                        storageprefix + "-spworkerlocaldir" + localdirnum for localdirnum in std.range(1, $._localdirstoragecount)
                      ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
    },
  ] + (if $._sparkexservicetype != "None" then
  [
    (import "../historyserverservice.jsonnet") + {
      // override historyserverservice global variables
      _historyserverprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._historyserverprefix + "-" + super._mname,
      _servicetype: $._sparkexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "historyuiport" + utils.addcolonforport(externalhistoryuiports[0]) + ":18080",
      ],
      _nodeports: [
        "historyuiport" + utils.addcolonforport(nodehistoryuiports[0]) + ":18080",
      ],
    },
  ]
  else
  []) + [
    (import "../historyserver.jsonnet") + {
      // override historyserver global variables
      _historyserverprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._historyserverprefix + "-" + super._mname,
      _dockerimage: $._sparkdockerimage,
      _replicacount: $._historyserverinstancecount,
      _containerrequestcpu:: $._historyserverrequestcpu,
      _containerrequestmem:: $._historyserverrequestmem,
      _containerlimitcpu:: $._historyserverlimitcpu,
      _containerlimitmem:: $._historyserverlimitmem,
      _envs: [
        "SPARK_SERVER_TYPE:historyserver",
        "SPARK_CONF_DIR:/opt/spark/conf",
        "HADOOP_CONF_DIR:/opt/spark/conf",
        "BD_SUITE_PREFIX:" + self._historyserverprefix,
        "BD_ZOOKEEPER_SERVERS:" + std.join(",", [$._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]),
        "BD_JOURNALNODE_SERVERS:" + std.join(";", [$._suiteprefix + "-" + "journalnode" + jnnum + ":8485" for jnnum in std.range(1,$._jninstancecount)]),
        "BD_ENENTLOG_DIR:" + $._sparkeventlogdir,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
     },
  ],
}
