{
  // ping deploy global variables
  _pinginstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _pingdockerimage:: "127.0.0.1:30100/tools/ping:0.1",
  _pingrequestcpu:: "0",
  _pingrequestmem:: "0",
  _pinglimitcpu:: "0",
  _pinglimitmem:: "0",
  _zkinstancecount:: 3,
  _jninstancecount:: 3,
  _kafkainstancecount:: 3,
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _pingpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
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
  _externalports::{
    httpport:: "9092",
  },
  local utils = import "../../common/utils/utils.libsonnet",
  local externalip = $._externalips,
  local storageprefix = $._suiteprefix,

  local cephbasename = ["pingutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: [
    (import "../ping.jsonnet") + {
      // override ping global variables
      _pingprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._pingprefix + "-" + super._mname + pingnum,
      _dockerimage: $._pingdockerimage,
      _containerrequestcpu:: $._pingrequestcpu,
      _containerrequestmem:: $._pingrequestmem,
      _containerlimitcpu:: $._pinglimitcpu,
      _containerlimitmem:: $._pinglimitmem,
      _podantiaffinitytype: $._pingpodantiaffinitytype,
      _podantiaffinitytag: self._pingprefix + "-" + "ping",
      _podantiaffinityns: [self._mnamespace,],
      _envs: [
         "BD_SUITE_PREFIX:" + self._pingprefix,
         "BD_ZOOKEEPER_SERVERS:" + std.join(",", [$._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]),
         "BD_JOURNALNODE_SERVERS:" + std.join(";", [$._suiteprefix + "-" + "journalnode" + jnnum + ":8485" for jnnum in std.range(1,$._jninstancecount)]),
         "BD_KAFKA_SERVERS:" + std.join(",", [$._suiteprefix + "-" + "kafka" + kafkanum + ":9092" for kafkanum in std.range(1,$._kafkainstancecount)]),
      ],
      _volumemounts:: $._volumemountscommon + [
                        storageprefix + "-" + "pingdata:/opt/ping/data",
                      ],
      _storages:: $._storagescommon + [
                    storageprefix + "-" + "pingdata",
                  ],
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh",],
    } for pingnum in std.range(1, $._pinginstancecount)
  ],
}
