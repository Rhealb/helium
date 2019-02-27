{
  // mongodb deploy global variables
  _mongodbinstancecount:: 1,
  _mongodbreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _mongodbdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _mongodbrequestcpu:: "0",
  _mongodbrequestmem:: "0",
  _mongodblimitcpu:: "0",
  _mongodblimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _mongodbexternalports:: [],
  _mongodbnodeports:: [],
  _mongodbexservicetype:: "ClusterIP",
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
  local externalports = $._mongodbexternalports.ports,
  
  local nodeports = $._mongodbnodeports.ports,
  
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["mongodbutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._mongodbexservicetype != "None" then
  [
    (import "../mongodbservice.jsonnet") + {
      // override mongodbservice global variables
      _mongodbprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._mongodbprefix + "-" + super._mname + num + "-ex",
      _sname: self._mongodbprefix + "-" + super._mname + num,
      _servicetype: $._mongodbexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "port" + utils.addcolonforport(externalports[num - 1]) + ":27017",
        
      ],
      _nodeports: [
        "port" + utils.addcolonforport(nodeports[num - 1]) + ":27017",
        
      ],
    } for num in std.range(1, $._mongodbinstancecount)
  ]
  else
  []) + [
    (import "../mongodbservice.jsonnet") + {
      // override mongodbservice global variables
      _mongodbprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._mongodbprefix + "-" + super._mname + num,
    } for num in std.range(1, $._mongodbinstancecount)
  ] + [
    (import "../mongodb.jsonnet") + {
      // override mongodb global variables
      _mongodbprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._mongodbprefix + "-" + super._mname + num,
      _dockerimage: $._mongodbdockerimage,
      _replicacount: $._mongodbreplicas,
      _containerrequestcpu:: $._mongodbrequestcpu,
      _containerrequestmem:: $._mongodbrequestmem,
      _containerlimitcpu:: $._mongodblimitcpu,
      _containerlimitmem:: $._mongodblimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._mongodbprefix,
      ],
      _volumemounts:: $._volumemountscommon + [
                        storageprefix + "-" + "mongodbdata:/data/db",
                      ],
      _storages:: $._storagescommon + [
                    storageprefix + "-" + "mongodbdata",
                  ],
      _volumes:: $._volumescommon,
      _command:: [ "sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._mongodbinstancecount)
  ],
}
