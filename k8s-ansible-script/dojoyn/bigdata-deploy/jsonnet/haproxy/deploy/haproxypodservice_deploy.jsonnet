{
  // haproxy deploy global variables
  _haproxyinstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _haproxydockerimage:: "10.19.248.12:30100/tools/dockerio-haproxy-1.7.0-alpine:0.3-lbsheng",
  _haproxyrequestcpu:: "0.5",
  _haproxyrequestmem:: "1Gi",
  _haproxylimitcpu:: "0.5",
  _haproxylimitmem:: "1Gi",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _haproxypodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _externalports:: {
    hawebports: [],
    sparkuiports: [],
    hdfsuiports: [],
    hbaseuiports: [],
    overlorduiports: [],
    coordinatoruiports: [],
  },
  _haproxynodeports:: {
    hawebports: [],
    sparkuiports: [],
    hdfsuiports: [],
    hbaseuiports: [],
    overlorduiports: [],
    coordinatoruiports: [],
  },
  _haproxyexservicetype:: "ClusterIP",
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
  local cephbasename = ["haproxyutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  local utils = import "../../common/utils/utils.libsonnet",
  local externalhawebports = $._externalports.hawebports,
  local externalsparkuiports = $._externalports.sparkuiports,
  local externalhdfsuiports = $._externalports.hdfsuiports,
  local externalhbaseuiports = $._externalports.hbaseuiports,
  local externaldruidoverlorduiports = $._externalports.overlorduiports,
  local externaldruidcoordinatoruiports = $._externalports.coordinatoruiports,

  local nodehawebports = $._haproxynodeports.hawebports,
  local nodesparkuiports = $._haproxynodeports.sparkuiports,
  local nodehdfsuiports = $._haproxynodeports.hdfsuiports,
  local nodehbaseuiports = $._haproxynodeports.hbaseuiports,
  local nodedruidoverlorduiports = $._haproxynodeports.overlorduiports,
  local nodedruidcoordinatoruiports = $._haproxynodeports.coordinatoruiports,

  kind: "List",
  apiVersion: "v1",
  items: (if $._haproxyexservicetype != "None" then
  [
    (import "../haproxyservice.jsonnet") + {
      // override haproxyservice global variables
      _haproxyprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._haproxyprefix + "-" + super._mname + hpnum + "-ex",
      _sname: self._haproxyprefix + "-" + super._mname + hpnum,
      _servicetype: $._haproxyexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "hawebport" + utils.addcolonforport(externalhawebports[hpnum - 1]) +":10800",
        "sparkuiport" + utils.addcolonforport(externalsparkuiports[hpnum - 1]) +":9999",
        "hdfsuiport" + utils.addcolonforport(externalhdfsuiports[hpnum - 1]) +":9998",
        "hbaseuiportsi" + utils.addcolonforport(externalhbaseuiports[hpnum - 1]) +":9997",
        "overlorduiport" + utils.addcolonforport(externaldruidoverlorduiports[hpnum - 1]) +":8090",
        "coordinatoruiport" + utils.addcolonforport(externaldruidcoordinatoruiports[hpnum - 1]) +":8081",
      ],
      _nodeports: [
        "hawebport" + utils.addcolonforport(nodehawebports[hpnum - 1]) +":10800",
        "sparkuiport" + utils.addcolonforport(nodesparkuiports[hpnum - 1]) +":9999",
        "hdfsuiport" + utils.addcolonforport(nodehdfsuiports[hpnum - 1]) +":9998",
        "hbaseuiport" + utils.addcolonforport(nodehbaseuiports[hpnum - 1]) +":9997",
        "overlorduiport" + utils.addcolonforport(nodedruidoverlorduiports[hpnum - 1]) +":8090",
        "coordinatoruiport" + utils.addcolonforport(nodedruidcoordinatoruiports[hpnum - 1]) +":8081",
      ],
    } for hpnum in std.range(1, $._haproxyinstancecount)
  ]
  else
  []) + [
    (import "../haproxy.jsonnet") + {
      // override haproxy global variables
      _haproxyprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._haproxyprefix + "-" + super._mname + hpnum,
      _dockerimage: $._haproxydockerimage,
      _containerrequestcpu:: $._haproxyrequestcpu,
      _containerrequestmem:: $._haproxyrequestmem,
      _containerlimitcpu:: $._haproxylimitcpu,
      _containerlimitmem:: $._haproxylimitmem,
      _podantiaffinitytype: $._haproxypodantiaffinitytype,
      _podantiaffinitytag: self._haproxyprefix + "-" + "haproxy",
      _podantiaffinityns: [self._mnamespace,],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
      _args::["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"],
    } for hpnum in std.range(1, $._haproxyinstancecount)
  ],
}
