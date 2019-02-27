{
  // %NAME% deploy global variables
  _%NAME%instancecount:: 1,
  _%NAME%replicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _%NAME%dockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _%NAME%requestcpu:: "0",
  _%NAME%requestmem:: "0",
  _%NAME%limitcpu:: "0",
  _%NAME%limitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _%NAME%externalports:: [],
  _%NAME%nodeports:: [],
  _%NAME%exservicetype:: "ClusterIP",
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
  %LOCALEXPORTSTEMPLATE%
  %LOCALNODEPORTSTEMPLATE%
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["%NAME%utils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._%NAME%exservicetype != "None" then
  [
    (import "../%NAME%service.jsonnet") + {
      // override %NAME%service global variables
      _%NAME%prefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._%NAME%prefix + "-" + super._mname + num + "-ex",
      _sname: self._%NAME%prefix + "-" + super._mname + num,
      _servicetype: $._%NAME%exservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        %EXPORTSTEMPLATE%
      ],
      _nodeports: [
        %NODEPORTSTEMPLATE%
      ],
    } for num in std.range(1, $._%NAME%instancecount)
  ]
  else
  []) + [
    (import "../%NAME%service.jsonnet") + {
      // override %NAME%service global variables
      _%NAME%prefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._%NAME%prefix + "-" + super._mname + num,
    } for num in std.range(1, $._%NAME%instancecount)
  ] + [
    (import "../%NAME%.jsonnet") + {
      // override %NAME% global variables
      _%NAME%prefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._%NAME%prefix + "-" + super._mname + num,
      _dockerimage: $._%NAME%dockerimage,
      _replicacount: $._%NAME%replicas,
      _containerrequestcpu:: $._%NAME%requestcpu,
      _containerrequestmem:: $._%NAME%requestmem,
      _containerlimitcpu:: $._%NAME%limitcpu,
      _containerlimitmem:: $._%NAME%limitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._%NAME%prefix,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._%NAME%instancecount)
  ],
}
