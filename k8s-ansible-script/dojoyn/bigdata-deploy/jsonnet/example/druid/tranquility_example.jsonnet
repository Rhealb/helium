{
  // tranquility deploy global variables

  local globalconf = import "../global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local tranquilitystorages = (import "../../druid/tranquility/deploy/tranquilitystorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },


  local tranquilitypodservice = (import "../../druid/tranquility/deploy/tranquilitypodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    local tranquility = globalconf.druid.tranquility,
    _utilsstoretype:: globalconf.utilsstoretype,
    _tranquilitydockerimage:: tranquility.image,
    _tranquilityinstancecount:: tranquility.instancecount,
    _tranquilityrequestcpu:: tranquility.requestcpu,
    _tranquilityrequestmem:: tranquility.requestmem,
    _tranquilitylimitcpu:: tranquility.limitcpu,
    _tranquilitylimitmem:: tranquility.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           tranquilitystorages.items
         else if deploytype == "podservice" then
           tranquilitypodservice.items
         else
           error "Unknow deploytype",
}
