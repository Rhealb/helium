{
  // hdfs deploy global variables
  _nninstancecount:: 2,
  _jninstancecount:: 3,
  _dninstancecount:: 3,
  _datadirstoragecount:: 4,
  _tmpdirstoragecount:: 4,
  _zkinstancecount:: 3,
  _zkservers:: std.join(",", [$._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]),
  _journalnodeservers::  std.join(";", [$._suiteprefix + "-" + "journalnode" + jnnum + ":8485" for jnnum in std.range(1,$._jninstancecount)]),
  _datadirlist:: std.join(",", ["file:/mnt/data" + datadirnum + "/data" for datadirnum in std.range(1,$._datadirstoragecount)]),
  _tmpdirlist:: std.join(",", ["file:/mnt/tmp" + tmpdirnum + "/tmp" for tmpdirnum in std.range(1,$._tmpdirstoragecount)]),
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _nnrequestcpu:: "0",
  _nnrequestmem:: "0",
  _nnlimitcpu:: "0",
  _nnlimitmem:: "0",
  _jnrequestcpu:: "0",
  _jnrequestmem:: "0",
  _jnlimitcpu:: "0",
  _jnlimitmem:: "0",
  _dnrequestcpu:: "0",
  _dnrequestmem:: "0",
  _dnlimitcpu:: "0",
  _dnlimitmem:: "0",
  _hdfsdockerimage:: "10.19.248.12:30100/tools/dep-centos7-hadoop-2.7.3:0.1",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _nnpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _jnpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _externalports:: {
    nnhttpports:: [],
  },

  _hdfsnodeports:: {
    nnhttpports: [],
  },
  _hdfsexservicetype:: "ClusterIP",
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
  local specuse = "specuse",
  local cephbasename = [
    "hadooputils"
  ],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  local utils = import "../../../common/utils/utils.libsonnet",
  local externalnnhttpaddrports = $._externalports.nnhttpports,
  local nodennhttpaddrports = $._hdfsnodeports.nnhttpports,

  kind: "List",
  apiVersion: "v1",
  items: (if $._hdfsexservicetype != "None" then
  [
    (import "../namenodeservice.jsonnet") + {
      // override namenodeservice global variables
      _nnprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._nnprefix + "-" + super._mname + nnnum + "-ex",
      _sname: self._nnprefix + "-" + super._mname + nnnum,
      _servicetype: $._hdfsexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "nnhttpport" + utils.addcolonforport(externalnnhttpaddrports[nnnum - 1]) + ":50070",
      ],

      _nodeports: [
        "nnhttpport" + utils.addcolonforport(nodennhttpaddrports[nnnum - 1]) + ":50070",
      ],
    } for nnnum in std.range(1, $._nninstancecount)
  ]
  else
  []) + [
    (import "../namenodeservice.jsonnet") + {
      // override namenodeservice global variables
      _nnprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._nnprefix + "-" + super._mname + nnnum,
    } for nnnum in std.range(1, $._nninstancecount)
  ] + [
    (import "../namenode.jsonnet") + {
      // override namenode global variables
      _nnprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._nnprefix + "-" + super._mname + nnnum,
      _dockerimage: $._hdfsdockerimage,
      _containerrequestcpu: $._nnrequestcpu,
      _containerrequestmem: $._nnrequestmem,
      _containerlimitcpu: $._nnlimitcpu,
      _containerlimitmem: $._nnlimitmem,
      _podantiaffinitytype: $._nnpodantiaffinitytype,
      _podantiaffinitytag: self._nnprefix + "-" + "namenode",
      _podantiaffinityns: [self._mnamespace,],
      local nntype = ["namenode", "namenode-standby"],
      _envs: [
        "HADOOP_SERVER_TYPE:" + nntype[std.abs(nnnum) - 1],
        "BD_SUITE_PREFIX:" + self._nnprefix,
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
        "BD_JOURNALNODE_SERVERS:" + $._journalnodeservers,
        "BD_DATADIRLIST:" + $._datadirlist,
        "BD_TMPDIRLIST:" + $._tmpdirlist,
      ],
      _volumemounts:: $._volumemountscommon + [
                        storageprefix + "-" + specuse + nnnum + ":/hdfs",
                      ],
      _storages:: $._storagescommon + [
                    storageprefix + "-" + specuse + nnnum,
                  ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh", "2>&1"],
    } for nnnum in std.range(1, $._nninstancecount) if nnnum < 3
  ] + [
    (import "../journalnodeservice.jsonnet") + {
      // override journalnodeservice global variables
      _jnprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._jnprefix + "-" + super._mname + jnnum,
    } for jnnum in std.range(1, $._jninstancecount)
  ] + [
    (import "../journalnode.jsonnet") + {
      // override journalnode global variables
      _jnprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._jnprefix + "-" + super._mname + jnnum,
      _dockerimage: $._hdfsdockerimage,
      _containerrequestcpu: $._jnrequestcpu,
      _containerrequestmem: $._jnrequestmem,
      _containerlimitcpu: $._jnlimitcpu,
      _containerlimitmem: $._jnlimitmem,
      local pvcnum = jnnum + $._nninstancecount,
      _podantiaffinitytype: $._jnpodantiaffinitytype,
      _podantiaffinitytag: self._jnprefix + "-" + "journalnode",
      _podantiaffinityns: [self._mnamespace,],
      _envs: [
        "HADOOP_SERVER_TYPE:journalnode",
        "BD_SUITE_PREFIX:" + self._jnprefix,
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
        "BD_JOURNALNODE_SERVERS:" + $._journalnodeservers,
        "BD_DATADIRLIST:" + $._datadirlist,
        "BD_TMPDIRLIST:" + $._tmpdirlist,
      ],
      _volumemounts:: $._volumemountscommon  + [
                        storageprefix + "-" + specuse + pvcnum + ":/hdfs",
                      ],
      _storages:: $._storagescommon + [
                    storageprefix + "-" + specuse + pvcnum,
                  ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh", "2>&1"],
    } for jnnum in std.range(1, $._jninstancecount)
  ] + [
    (import "../datanode.jsonnet") + {
      // override datanode global variables
      _dnprefix: $._suiteprefix,
      _replicacount: $._dninstancecount,
      _mnamespace: $._namespace,
      _mname: self._dnprefix + "-" + super._mname,
      _dockerimage: $._hdfsdockerimage,
      _containerrequestcpu: $._dnrequestcpu,
      _containerrequestmem: $._dnrequestmem,
      _containerlimitcpu: $._dnlimitcpu,
      _containerlimitmem: $._dnlimitmem,
      _envs: [
        "HADOOP_SERVER_TYPE:datanode",
        "BD_SUITE_PREFIX:" + self._dnprefix,
        "BD_ZOOKEEPER_SERVERS:" + $._zkservers,
        "BD_JOURNALNODE_SERVERS:" + $._journalnodeservers,
        "BD_DATADIRLIST:" + $._datadirlist,
        "BD_TMPDIRLIST:" + $._tmpdirlist,
      ],
      _volumemounts:: $._volumemountscommon + [
                        storageprefix+ "-" + datadir + datadirnum + ":/mnt/data" + datadirnum for datadirnum in std.range(1, $._datadirstoragecount)
                      ],
      _storages:: $._storagescommon + [
                    storageprefix+ "-" + datadir + datadirnum for datadirnum in std.range(1, $._datadirstoragecount)
                  ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh", "2>&1"],
    },
  ],
}
