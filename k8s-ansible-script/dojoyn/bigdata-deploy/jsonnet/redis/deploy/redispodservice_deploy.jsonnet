{
  // redismaster deploy global variables
  _redismasterinstancecount:: 1,
  _redismasterreplicas:: 1,
  _zkinstancecount: 3,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _redisdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _redismasterrequestcpu:: "0",
  _redismasterrequestmem:: "0",
  _redismasterlimitcpu:: "0",
  _redismasterlimitmem:: "0",
  _redisslaverequestcpu:: "0",
  _redisslaverequestmem:: "0",
  _redisslavelimitcpu:: "0",
  _redisslavelimitmem:: "0",
  _zkservers:: std.join(",", [self._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]),
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _redisexternalports:: [],
  _redisnodeports:: [],
  _redisexservicetype:: "ClusterIP",
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
  local externalredisports = $._redisexternalports.redisports,

  local noderedisports = $._redisnodeports.redisports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["redisutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._redisexservicetype != "None" then
  [
    (import "../redisservice.jsonnet") + {
      // override redisservice global variables
      _redisprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._redisprefix + "-" + super._mname + "-ex",
      _sname: self._redisprefix + "-" + super._mname,
      _servicetype: $._redisexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "redisport" + utils.addcolonforport(externalredisports[0]) + ":6379",
      ],
      _nodeports: [
        "redisport" + utils.addcolonforport(noderedisports[0]) + ":6379",
      ],
    },
  ]
  else
  []) + [
    (import "../redisservice.jsonnet") + {
      // override redisservice global variables
      _redisprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._redisprefix + "-" + super._mname,
      spec+: {
        clusterIP: "None",
      },
    },
  ] + [
    (import "../redismaster.jsonnet") + {
      // override redismaster global variables
      _redismasterprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._redismasterprefix + "-" + super._mname,
      _dockerimage: $._redisdockerimage,
      _replicacount: $._redismasterreplicas,
      _containerrequestcpu:: $._redismasterrequestcpu,
      _containerrequestmem:: $._redismasterrequestmem,
      _containerlimitcpu:: $._redismasterlimitcpu,
      _containerlimitmem:: $._redismasterlimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._redismasterprefix,
        "MASTER:true",
        "BD_ZK_SERVERS:" + $._zkservers,
      ],
      _volumemounts:: $._volumemountscommon + [
                        storageprefix + "-" + "redisdata:/redis-cluster-data",
                      ],
      _storages:: $._storagescommon + [
                    storageprefix + "-" + "redisdata",
                  ],
      _volumes:: $._volumescommon,
      _volumeclaimtemplates: [],
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    }
  ] + [
    (import "../redisslave.jsonnet") + {
      // override redismaster global variables
      _redisslaveprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._redisslaveprefix + "-" + super._mname,
      _dockerimage: $._redisdockerimage,
      _replicacount: $._redisslavereplicas,
      _containerrequestcpu:: $._redisslaverequestcpu,
      _containerrequestmem:: $._redisslaverequestmem,
      _containerlimitcpu:: $._redisslavelimitcpu,
      _containerlimitmem:: $._redisslavelimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._redisslaveprefix,
        "SLAVE:true",
        "BD_ZK_SERVERS:" + $._zkservers,
      ],
      _volumemounts:: $._volumemountscommon + [
                        storageprefix + "-" + "redisdata:/redis-cluster-data",
                      ],
      _storages:: $._storagescommon + [
                    storageprefix + "-" + "redisdata",
                  ],
      _volumes:: $._volumescommon,
      _volumeclaimtemplates: [],
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    }
  ],
}
