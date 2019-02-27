{
  // amahkafka deploy global variables
  _amahkafkareplicas:: 1,
  _kafkainstancecount:: 3,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _kafkaservers:: std.join(",", [$._suiteprefix + "-" + "kafka" + num + ":9092" for num in std.range(1,$._kafkainstancecount)]),
  _jmxservers:: std.join(",", [$._suiteprefix + "-" + "kafka" + num + ":9999" for num in std.range(1,$._kafkainstancecount)]),
  _amahkafkadockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _amahkafkarequestcpu:: "0",
  _amahkafkarequestmem:: "0",
  _amahkafkalimitcpu:: "0",
  _amahkafkalimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _amahkafkaexternalports:: [],
  _amahkafkanodeports:: [],
  _amahkafkaexservicetype:: "ClusterIP",
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
  local externalamahports = $._amahkafkaexternalports.amahports,

  local nodeamahports = $._amahkafkanodeports.amahports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["kafkautils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._amahkafkaexservicetype != "None" then
  [
    (import "../amahkafkaservice.jsonnet") + {
      // override amahkafkaservice global variables
      _amahkafkaprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahkafkaprefix + "-" + super._mname + "-ex",
      _sname: self._amahkafkaprefix + "-" + super._mname,
      _servicetype: $._amahkafkaexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "amahport" + utils.addcolonforport(externalamahports[0]) + ":8084",

      ],
      _nodeports: [
        "amahport" + utils.addcolonforport(nodeamahports[0]) + ":8084",

      ],
    }
  ]
  else
  []) + [
    (import "../amahkafkaservice.jsonnet") + {
      // override amahkafkaservice global variables
      _amahkafkaprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahkafkaprefix + "-" + super._mname,
    }
  ] + [
    (import "../amahkafka.jsonnet") + {
      // override amahkafka global variables
      _amahkafkaprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._amahkafkaprefix + "-" + super._mname,
      _dockerimage: $._amahkafkadockerimage,
      _replicacount: $._amahkafkareplicas,
      _containerrequestcpu:: $._amahkafkarequestcpu,
      _containerrequestmem:: $._amahkafkarequestmem,
      _containerlimitcpu:: $._amahkafkalimitcpu,
      _containerlimitmem:: $._amahkafkalimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._amahkafkaprefix,
        "BD_KAFKA_SERVERS:" + $._kafkaservers,
        "BD_JMX_SERVERS:" + $._jmxservers,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/amahentrypoint.sh" ],
    }
  ],
}
