{
  // kfaka deploy global variables
  _opentsdbinstancecount:: 3,
  _zkinstancecount:: 3,
  _zkservers:: std.join(",", [self._suiteprefix + "-" + "zookeeper" + zknum + ":2181" for zknum in std.range(1,$._zkinstancecount)]),
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _opentsdbdockerimage:: "10.19.132.184:30100/enncloud/opentsdb-2.4.0:beta-0.1",
  _opentsdbrequestcpu:: "0",
  _opentsdbrequestmem:: "0",
  _opentsdblimitcpu:: "0",
  _opentsdblimitmem:: "0",
  _opentsdbjavaxmx:: "2g",
  _opentsdbjavaxms:: "2g",
  _externalips:: ["10.19.248.13", "10.19.248.14", "10.19.248.25"],
  _opentsdbpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _externalports:: {
    httpports: [],
    jmxports: [],
  },
  _opentsdbnodeports:: {
    httpports: [],
    jmxports: [],
  },
  _opentsdbexservicetype:: "ClusterIP",
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
  local externalhttpports = $._externalports.httpports,
  local externaljmxports = $._externalports.jmxports,

  local nodehttpports = $._opentsdbnodeports.httpports,
  local nodejmxports = $._opentsdbnodeports.jmxports,

  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["opentsdbutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],

  kind: "List",
  apiVersion: "v1",
  items: (if $._opentsdbexservicetype != "None" then
  [
    (import "../opentsdbservice.jsonnet") + {
      // override opentsdbservice global variables
      _opentsdbprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._opentsdbprefix + "-" + super._mname  + '-ex',
      _sname: self._opentsdbprefix + "-" + super._mname ,
      _servicetype: $._opentsdbexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "httpport" + utils.addcolonforport(externalhttpports[0]) + ":4242",
        "jmxport"+ utils.addcolonforport(externaljmxports[0]) + ":9100",
      ],
      _nodeports: [
        "httpport" + utils.addcolonforport(nodehttpports[0]) + ":4242",
        "jmxport"+ utils.addcolonforport(nodejmxports[0]) + ":9100",
      ],
    },
  ]
  else
  []) + [
    (import "../opentsdbservice.jsonnet") + {
      // override opentsdbservice global variables
      _opentsdbprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._opentsdbprefix + "-" + super._mname ,
    },
  ] + [
    (import "../opentsdb.jsonnet") + {
      // override opentsdb global variables
      _opentsdbprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._opentsdbprefix + "-" + super._mname,
      _dockerimage: $._opentsdbdockerimage,
      _containerrequestcpu:: $._opentsdbrequestcpu,
      _replicacount: $._opentsdbinstancecount,
      _containerrequestmem:: $._opentsdbrequestmem,
      _containerlimitcpu:: $._opentsdblimitcpu,
      _containerlimitmem:: $._opentsdblimitmem,
      _envs: [
        "ZOOKEEPER_SERVERS:" + $._zkservers,
        "LOGPATTERN:^(?<dateTime>[\\d\\-\\s\\d\\:]*),(?<millsSecond>[\\d]*)[\\s]*(?<logLevel>[^\\s]*)[\\s]*\\[(?<threadName>[^\\]]*)\\][\\s]*(?<log>.*)$",
        "LOGASSEMBLE:<dateTime>%dateTime%.%millsSecond%,%logLevel%,%log%,%threadName%",
        "JVMARGS:-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9100 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dhadoop.home.dir=/ -Xloggc:/var/log/opentsdb/gc.log -Xmx" + $._opentsdbjavaxmx + " -Xms" + $._opentsdbjavaxms,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
    },
  ],
}
