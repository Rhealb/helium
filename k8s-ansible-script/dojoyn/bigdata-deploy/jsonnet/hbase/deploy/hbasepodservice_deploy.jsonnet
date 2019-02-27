{
  // hbase deploy global variables
  _hminstancecount:: 3,
  _rsinstancecount:: 3,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _zknum:: 3,
  _hbasedockerimage:: "10.19.132.184:30100/tools/dep-centos7-hbase-1.2.5:0.1",
  _hmrequestcpu:: "0",
  _hmrequestmem:: "0",
  _hmlimitcpu:: "0",
  _hmlimitmem:: "0",
  _rsrequestcpu:: "0",
  _rsrequestmem:: "0",
  _rslimitcpu:: "0",
  _rslimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _hmasterpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _hmasterpermsize:: "128m",
  _hmastermaxpermsize:: "128m",
  _hmasterjavaxmx:: "2g",
  _hregionserverpermsize:: "128m",
  _hregionservermaxpermsize:: "128m",
  _hregionserverjavaxmx:: "2g",
  _tsdbttl:: 2592000,
  _externalports::{
    masterhttpports: [],
  },

  _hbasenodeports::{
    masterhttpports: [],
  },
  _hbaseexservicetype:: "ClusterIP",
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
  local cephbasename = ["hbaseutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  local utils = import "../../common/utils/utils.libsonnet",
  local externalmasterhttpports = $._externalports.masterhttpports,
  local nodemasterhttpports = $._hbasenodeports.masterhttpports,
  kind: "List",
  apiVersion: "v1",
  items: (if $._hbaseexservicetype != "None" then
  [
    (import "../hmasterservice.jsonnet") + {
      // override hmasterservice global variables
      _hmasterprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._hmasterprefix + "-" + super._mname + hmnum + "-ex",
      _sname: self._hmasterprefix + "-" + super._mname + hmnum,
      _servicetype: $._hbaseexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "masterhttpport" + utils.addcolonforport(externalmasterhttpports[hmnum - 1]) + ":16010",
      ],
      _nodeports: [
        "masterhttpport" + utils.addcolonforport(nodemasterhttpports[hmnum - 1]) + ":16010",
      ],
    } for hmnum in std.range(1, $._hminstancecount)
  ]
  else
  []) + [
    (import "../hmasterservice.jsonnet") + {
      // override hmasterservice global variables
      _hmasterprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._hmasterprefix + "-" + super._mname + hmnum,

    } for hmnum in std.range(1, $._hminstancecount)
  ] + [
    (import "../hmaster.jsonnet") + {
      // override hmaster global variables
      _hmasterprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._hmasterprefix + "-" + super._mname + hmnum,
      _dockerimage: $._hbasedockerimage,
      _containerrequestcpu:: $._hmrequestcpu,
      _containerrequestmem:: $._hmrequestmem,
      _containerlimitcpu:: $._hmlimitcpu,
      _containerlimitmem:: $._hmlimitmem,
      _podantiaffinitytype: $._hmasterpodantiaffinitytype,
      _podantiaffinitytag: self._hmasterprefix + "-" + "hmaster",
      _podantiaffinityns: [self._mnamespace,],
      _envs: [
        "HBASE_SERVER_TYPE:master",
        "BD_SUITE_PREFIX:" + self._hmasterprefix,
        "BD_HMASTER_PERMSIZE:" + $._hmasterpermsize,
        "BD_HMASTER_MAXPERMSIZE:" + $._hmastermaxpermsize,
        "BD_HMASTER_XMX:" + $._hmasterjavaxmx,
        "BD_HREGIONSERVER_PERMSIZE:" + $._hregionserverpermsize,
        "BD_HREGIONSERVER_MAXPERMSIZE:" + $._hregionservermaxpermsize,
        "BD_HREGIONSERVER_XMX:" + $._hregionserverjavaxmx,
        "BD_TSDB_TTL:" + $._tsdbttl,
      ] + [
        "ZKNAME:" + std.join(",", [
          self._hmasterprefix + "-" + "zookeeper" + zknum + ":2181"
            for zknum in std.range(1,$._zknum)
        ])
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
    } for hmnum in std.range(1, $._hminstancecount)
  ] + [
    (import "../regionserver.jsonnet") + {
      // override regionserver global variables
      _rsprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._rsprefix + "-" + super._mname,
      _dockerimage: $._hbasedockerimage,
      _replicacount: $._rsinstancecount,
      _containerrequestcpu:: $._rsrequestcpu,
      _containerrequestmem:: $._rsrequestmem,
      _containerlimitcpu:: $._rslimitcpu,
      _containerlimitmem:: $._rslimitmem,
      _envs: [
        "HBASE_SERVER_TYPE:regionserver",
        "BD_SUITE_PREFIX:" + self._rsprefix,
        "BD_HMASTER_PERMSIZE:" + $._hmasterpermsize,
        "BD_HMASTER_MAXPERMSIZE:" + $._hmastermaxpermsize,
        "BD_HMASTER_XMX:" + $._hmasterjavaxmx,
        "BD_HREGIONSERVER_PERMSIZE:" + $._hregionserverpermsize,
        "BD_HREGIONSERVER_MAXPERMSIZE:" + $._hregionservermaxpermsize,
        "BD_HREGIONSERVER_XMX:" + $._hregionserverjavaxmx,
        "BD_TSDB_TTL:" + $._tsdbttl,
      ] + [
        "ZKNAME:" + std.join(",", [
          self._rsprefix + "-" + "zookeeper" + zknum + ":2181"
            for zknum in std.range(1,$._zknum)
        ])
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
    },
  ],
}
