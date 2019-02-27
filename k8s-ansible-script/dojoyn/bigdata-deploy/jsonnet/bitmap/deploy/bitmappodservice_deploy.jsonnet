{
  // bitmap deploy global variables
  _bitmapinstancecount:: 1,
  _bitmapreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _bitmapdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _bitmaprequestcpu:: "0",
  _bitmaprequestmem:: "0",
  _bitmaplimitcpu:: "0",
  _bitmaplimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _bitmapexternalports:: [],
  _bitmapnodeports:: [],
  _bitmapexservicetype:: "ClusterIP",
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
  local externalhttpPorts = $._bitmapexternalports.httpPorts,
  
  local nodehttpPorts = $._bitmapnodeports.httpPorts,
  
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["bitmaputils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._bitmapexservicetype != "None" then
  [
    (import "../bitmapservice.jsonnet") + {
      // override bitmapservice global variables
      _bitmapprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._bitmapprefix + "-" + super._mname + num + "-ex",
      _sname: self._bitmapprefix + "-" + super._mname + num,
      _servicetype: $._bitmapexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "httpport" + utils.addcolonforport(externalhttpPorts[num - 1]) + ":9313",
        
      ],
      _nodeports: [
        "httpport" + utils.addcolonforport(nodehttpPorts[num - 1]) + ":9313",
        
      ],
    } for num in std.range(1, $._bitmapinstancecount)
  ]
  else
  []) + [
    (import "../bitmapservice.jsonnet") + {
      // override bitmapservice global variables
      _bitmapprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._bitmapprefix + "-" + super._mname + num,
    } for num in std.range(1, $._bitmapinstancecount)
  ] + [
    (import "../bitmap.jsonnet") + {
      // override bitmap global variables
      _bitmapprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._bitmapprefix + "-" + super._mname + num,
      _dockerimage: $._bitmapdockerimage,
      _replicacount: $._bitmapreplicas,
      _containerrequestcpu:: $._bitmaprequestcpu,
      _containerrequestmem:: $._bitmaprequestmem,
      _containerlimitcpu:: $._bitmaplimitcpu,
      _containerlimitmem:: $._bitmaplimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._bitmapprefix,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._bitmapinstancecount)
  ],
}
