{
  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local haproxystorages = (import "../haproxy/deploy/haproxystorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local haproxypodservice = (import "../haproxy/deploy/haproxypodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    local haproxy = globalconf.haproxy,
    _utilsstoretype:: globalconf.utilsstoretype,
    _haproxydockerimage:: haproxy.image,
    _haproxyexservicetype:: haproxy.exservicetype,
    _haproxyrequestcpu:: haproxy.requestcpu,
    _haproxyrequestmem:: haproxy.requestmem,
    _haproxylimitcpu:: haproxy.limitcpu,
    _haproxylimitmem:: haproxy.limitmem,
    _externalports:: haproxy.externalports,
    _haproxynodeports:: haproxy.nodeports,
    _haproxyinstancecount:: haproxy.instancecount,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           haproxystorages.items
         else if deploytype == "podservice" then
           haproxypodservice.items
         else
           error "Unknow deploytype",
}
