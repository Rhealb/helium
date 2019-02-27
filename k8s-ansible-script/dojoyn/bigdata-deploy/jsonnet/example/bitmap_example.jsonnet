{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local bitmapstorages = (import "../bitmap/deploy/bitmapstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local bitmappodservice = (import "../bitmap/deploy/bitmappodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local bitmap = globalconf.bitmap,
    _bitmapexservicetype:: bitmap.exservicetype,
    _bitmapdockerimage:: bitmap.image,
    _bitmapexternalports:: bitmap.externalports,
    _bitmapnodeports:: bitmap.nodeports,
    _bitmapinstancecount:: bitmap.instancecount,
    _bitmapreplicas:: bitmap.replicas,
    _bitmaprequestcpu:: bitmap.requestcpu,
    _bitmaprequestmem:: bitmap.requestmem,
    _bitmaplimitcpu:: bitmap.limitcpu,
    _bitmaplimitmem:: bitmap.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           bitmapstorages.items
         else if deploytype == "podservice" then
           bitmappodservice.items
         else
           error "Unknow deploytype",
}
