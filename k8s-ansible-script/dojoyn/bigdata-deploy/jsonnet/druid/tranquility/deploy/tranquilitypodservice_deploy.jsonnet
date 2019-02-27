{
  // tranquility deploy global variables
  _tranquilityinstancecount:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _tranquilitydockerimage:: "10.19.140.200:30100/tools/dep-centos7-tranquility-0.8.2-liye:0.1",
  _tranquilityrequestcpu:: "0",
  _tranquilityrequestmem:: "0",
  _tranquilitylimitcpu:: "0",
  _tranquilitylimitmem:: "0",
  _utilsstoretype:: "ConfigMap",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
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
  local externalip = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["tranquilityutils",],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],

  kind: "List",
  apiVersion: "v1",
  items: [
    (import "../tranquility.jsonnet") + {
      // override tranquility global variables
      _mnamespace: $._namespace,
      _mname: super._mname + tranquilitymnum,
      _dockerimage: $._tranquilitydockerimage,
      _containerrequestcpu:: $._tranquilityrequestcpu,
      _containerrequestmem:: $._tranquilityrequestmem,
      _containerlimitcpu:: $._tranquilitylimitcpu,
      _containerlimitmem:: $._tranquilitylimitmem,
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: ["/opt/entrypoint.sh","/opt/mntcephutils/entry/entrypoint.sh"],
    } for tranquilitymnum in std.range(1, $._tranquilityinstancecount)
  ],
}
