{
  // yarn deploy global variables
  _rminstancecount:: 2,
  _nminstancecount:: 3,
  _mrjobhistoryinstancecount:: 1,
  _tmpdirstoragecount:: 4,
  _datadirstoragecount:: 4,
  _zkinstancecount:: 3,
  _jninstancecount:: 3,
  _zkservers:: std.join(",", [$._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]),
  _journalnodeservers::  std.join(";", [$._suiteprefix + "-" + "journalnode" + jnnum + ":8485" for jnnum in std.range(1,$._jninstancecount)]),
  _tmpdirlist:: std.join(",", ["file:/mnt/tmp" + tmpdirnum + "/tmp" for tmpdirnum in std.range(1,$._tmpdirstoragecount)]),
  _datadirlist:: std.join(",", ["file:/mnt/data" + datadirnum + "/data" for datadirnum in std.range(1,$._datadirstoragecount)]),
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _rmrequestcpu:: "0",
  _rmrequestmem:: "0",
  _rmlimitcpu:: "0",
  _rmlimitmem:: "0",
  _nmrequestcpu:: "0",
  _nmrequestmem:: "0",
  _nmlimitcpu:: "0",
  _nmlimitmem:: "0",
  _mrjobhistoryrequestcpu:: "0",
  _mrjobhistoryrequestmem:: "0",
  _mrjobhistorylimitcpu:: "0",
  _mrjobhistorylimitmem:: "0",
  _yarndockerimage:: "10.19.248.12:30100/tools/dep-centos7-hadoop-2.7.3:0.1",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _rmpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _externalports:: {
    yarnhttpports: [],
    jhshttpports: [],
  },
  _yarnnodeports:: {
    yarnhttpports: [],
    jhshttpports: [],
  },
  _yarnexservicetype:: "ClusterIP",
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
                       "utilsconf:configMap:" + storageprefix + "-hadooputils-conf",
                       "utilsentry:configMap:" + storageprefix + "-hadooputils-entry",
                       "utilsscripts:configMap:" + storageprefix + "-hadooputils-scripts",
                     ]
                   else if $._utilsstoretype == "FS" then
                     [],
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local rmtmpdir = "rmtmpdir",
  local nmtmpdir = "nmtmpdir",
  local nmuserlogs = "nmuserlogs",
  local cephbasename = [ 
    "hadooputils",
  ],  
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  local utils = import "../../../common/utils/utils.libsonnet",
  local externalyarnhttpports = $._externalports.yarnhttpports,
  local externaljhshttpports = $._externalports.jhshttpports,
  local nodeyarnhttpports = $._yarnnodeports.yarnhttpports,
  local nodejhshttpports = $._yarnnodeports.jhshttpports,

  kind: "List",
  apiVersion: "v1",
  items: (if $._yarnexservicetype != "None" then
  [
    (import "../resourcemanagerservice.jsonnet") + {
      // override resourcemanagerservice global variables
      _rmprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._rmprefix + "-" + super._mname + rmnum + "-ex",
      _sname: self._rmprefix + "-" + super._mname + rmnum,
      _servicetype: $._yarnexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "yarnhttpport" + utils.addcolonforport(externalyarnhttpports[rmnum - 1]) + ":8088",
      ],
      _nodeports: [
        "yarnhttpport" + utils.addcolonforport(nodeyarnhttpports[rmnum - 1]) + ":8088",
      ],
    } for rmnum in std.range(1, $._rminstancecount)
  ]
  else
  []) + [
    (import "../resourcemanagerservice.jsonnet") + {
      // override resourcemanagerservice global variables
      _rmprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._rmprefix + "-" + super._mname + rmnum,

    } for rmnum in std.range(1, $._rminstancecount)
  ] + [
    (import "../resourcemanager.jsonnet") + {
      // override resourcemanager global variables
      _rmprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._rmprefix + "-" + super._mname + rmnum,
      _dockerimage: $._yarndockerimage,
      _containerrequestcpu: $._rmrequestcpu,
      _containerrequestmem: $._rmrequestmem,
      _containerlimitcpu: $._rmlimitcpu,
      _containerlimitmem: $._rmlimitmem,
      _podantiaffinitytype: $._rmpodantiaffinitytype,
      _podantiaffinitytag: self._rmprefix + "-" + "resourcemanager",
      _podantiaffinityns: [self._mnamespace,],
      _envs: [
        "HADOOP_SERVER_TYPE:resourcemanager" + rmnum,
        "BD_SUITE_PREFIX:" + self._rmprefix,
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
        "BD_JOURNALNODE_SERVERS:" + $._journalnodeservers,
        "BD_TMPDIRLIST:" + $._tmpdirlist,
        "BD_DATADIRLIST:" + $._datadirlist,
      ],
      _volumemounts:: $._volumemountscommon + [
                        storageprefix + "-" + rmtmpdir + tmpdirnum + ":/mnt/tmp" + tmpdirnum for tmpdirnum in std.range(1, $._tmpdirstoragecount)
                      ],
      _storages:: $._storagescommon + [
                    storageprefix + "-" + rmtmpdir + tmpdirnum for tmpdirnum in std.range(1, $._tmpdirstoragecount)
                  ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh",],
    } for rmnum in std.range(1, $._rminstancecount) if rmnum < 3
  ] + [
    (import "../nodemanager.jsonnet") + {
      // override nodemanager global variables
      _nmprefix: $._suiteprefix,
      _replicacount: $._nminstancecount,
      _mnamespace: $._namespace,
      _mname: self._nmprefix + "-" + super._mname,
      _dockerimage: $._yarndockerimage,
      _containerrequestcpu: $._nmrequestcpu,
      _containerrequestmem: $._nmrequestmem,
      _containerlimitcpu: $._nmlimitcpu,
      _containerlimitmem: $._nmlimitmem,
      _envs: [
        "HADOOP_SERVER_TYPE:nodemanager",
        "BD_SUITE_PREFIX:" + self._nmprefix,
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
        "BD_JOURNALNODE_SERVERS:" + $._journalnodeservers,
        "BD_TMPDIRLIST:" + $._tmpdirlist,
        "BD_DATADIRLIST:" + $._datadirlist,
      ],
      _volumemounts:: $._volumemountscommon + [
                         storageprefix + "-" + nmuserlogs + ":/opt/hadoop/logs/userlogs",
                      ] + [
                            storageprefix + "-" + nmtmpdir + tmpdirnum + ":/mnt/tmp" + tmpdirnum for tmpdirnum in std.range(1, $._tmpdirstoragecount)
                          ],
      _storages:: $._storagescommon + [
                    storageprefix + "-" + nmuserlogs,
                  ] + [
                        storageprefix + "-" + nmtmpdir + tmpdirnum for tmpdirnum in std.range(1, $._tmpdirstoragecount)
                      ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh",],
    },
  ] + [
    (import "../mrjobhistory.jsonnet") + {
      // override mrjobhistory global variables
      _mrjobhistoryprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._mrjobhistoryprefix + "-" + super._mname,
      _dockerimage: $._yarndockerimage,
      _replicacount: $._mrjobhistoryinstancecount,
      _containerrequestcpu: $._mrjobhistoryrequestcpu,
      _containerrequestmem: $._mrjobhistoryrequestmem,
      _containerlimitcpu: $._mrjobhistorylimitcpu,
      _containerlimitmem: $._mrjobhistorylimitmem,
      _envs: [
        "HADOOP_SERVER_TYPE:mrjobhistory",
        "BD_SUITE_PREFIX:" + self._mrjobhistoryprefix,
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
        "BD_JOURNALNODE_SERVERS:" + $._journalnodeservers,
        "BD_TMPDIRLIST:" + $._tmpdirlist,
        "BD_DATADIRLIST:" + $._datadirlist,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh",],
    },
  ] + (if $._yarnexservicetype != "None" then
  [
    (import "../mrjobhistoryservice.jsonnet") + {
      // override mrjobhistoryservice global variables
      _mrjobhistoryprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._mrjobhistoryprefix + "-" + super._mname,
      _servicetype: $._yarnexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "jhshttpport" + utils.addcolonforport(externaljhshttpports[0]) + ":19888",
      ],
      _nodeports: [
        "jhshttpport" + utils.addcolonforport(nodejhshttpports[0]) + ":19888",
      ],
    },
  ]
  else
  []),
}
