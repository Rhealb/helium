{
  // kfaka deploy global variables
  _kafkainstancecount:: 3,
  _zkinstancecount:: 3,
  _zkservers:: std.join(",", [self._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]) + "/" + $._suiteprefix + "-kafka",
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _kafkadockerimage:: "10.19.132.184:30100/tools/dep-centos7-kafka-2.11-0.10.1.1:0.1",
  _kafkarequestcpu:: "0",
  _kafkarequestmem:: "0",
  _kafkalimitcpu:: "0",
  _kafkalimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _location:: "yancheng",
  _nodeportip:: "10.19.248.200",

  _kafkapodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _externalports:: {
    brokerports: [],
    jmxports: [],
  },
  _kafkanodeports:: {
    brokerports: [],
    jmxports: [],
  },
  _kafkaexservicetype:: "ClusterIP",
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
  local externalbrokerports = $._externalports.brokerports,
  local externaljmxports = $._externalports.jmxports,

  local nodebrokerports = $._kafkanodeports.brokerports,
  local nodejmxports = $._kafkanodeports.jmxports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["kafkautils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],

  kind: "List",
  apiVersion: "v1",
  items: (if $._kafkaexservicetype != "None" then
  [
    (import "../kafkaservice.jsonnet") + {
      // override kafkaservice global variables
      _kafkaprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._kafkaprefix + "-" + super._mname + kafkanum + '-ex',
      _sname: self._kafkaprefix + "-" + super._mname + kafkanum,
      _servicetype: $._kafkaexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: [
                                externalips[0],
                              ],
               }
             else
               {},
      _nameports: [
        "brokerport" + utils.addcolonforport(externalbrokerports[kafkanum - 1]) + ":9092",
        "jmxport" + utils.addcolonforport(externaljmxports[kafkanum - 1]) + ":9999",
      ],
      _nodeports: [
        "brokerport" + utils.addcolonforport(nodebrokerports[kafkanum - 1]) + ":9092",
        "jmxport" + utils.addcolonforport(nodejmxports[kafkanum - 1]) + ":9999",
      ],
    } for kafkanum in std.range(1, $._kafkainstancecount)
  ]
  else
  []) + [
    (import "../kafkaservice.jsonnet") + {
      // override kafkaservice global variables
      _kafkaprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._kafkaprefix + "-" + super._mname + kafkanum,
    } for kafkanum in std.range(1, $._kafkainstancecount)
  ] + [
    (import "../kafka.jsonnet") + {
      // override kafka global variables
      _kafkaprefix:: $._suiteprefix,
      _brokerid: kafkanum,
      _zookeeperservers: $._zkservers,

      _kafkaadvertizedlisternersenv: if $._kafkaexservicetype == "ClusterIP" then
                                       (if externalbrokerports[kafkanum - 1] != "" then
                                          externalips[0] + ":" + externalbrokerports[kafkanum - 1]
                                        else
                                          externalips[0] + ":9092")
                                     else if $._kafkaexservicetype == "NodePort" then
                                            (if nodebrokerports[kafkanum - 1] != "" then
                                               $._nodeportip + ":" + nodebrokerports[kafkanum - 1])
                                     else
                                        "",
      _kafkaexservicetypeenv: $._kafkaexservicetype,
      _exbrokerportenv: if $._kafkaexservicetype == "ClusterIP" then
                           $._externalports.brokerports[kafkanum - 1]
                        else if $._kafkaexservicetype == "NodePort" then
                               nodebrokerports[kafkanum - 1]
                        else if $._kafkaexservicetype == "None" then
                               "",
      _mnamespace: $._namespace,
      _mname: self._kafkaprefix + "-" + super._mname + kafkanum,
      _dockerimage: $._kafkadockerimage,
      _containerrequestcpu:: $._kafkarequestcpu,
      _containerrequestmem:: $._kafkarequestmem,
      _containerlimitcpu:: $._kafkalimitcpu,
      _containerlimitmem:: $._kafkalimitmem,
      _podantiaffinitytype: $._kafkapodantiaffinitytype,
      _podantiaffinitytag: self._kafkaprefix + "-" + "kafka",
      _podantiaffinityns: [self._mnamespace,],
      _volumemounts:: $._volumemountscommon + [
                        storageprefix + "-kafka" + kafkanum + "log:/tmp",
                      ],
      _storages:: $._storagescommon + [
                    storageprefix + "-kafka" + kafkanum + "log",
                  ],
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh"],
    } for kafkanum in std.range(1, $._kafkainstancecount)
  ],
}
