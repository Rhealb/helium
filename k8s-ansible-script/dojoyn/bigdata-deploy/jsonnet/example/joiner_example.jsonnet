{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local joinerstorages = (import "../joiner/deploy/joinerstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local joinerpodservice = (import "../joiner/deploy/joinerpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local joiner = globalconf.joiner,
    _joinerexservicetype:: joiner.exservicetype,
    _joinerdockerimage:: joiner.image,
    _joinerexternalports:: joiner.externalports,
    _joinernodeports:: joiner.nodeports,
    _joinerinstancecount:: joiner.instancecount,
    _joinerreplicas:: joiner.replicas,
    _joinerrequestcpu:: joiner.requestcpu,
    _joinerrequestmem:: joiner.requestmem,
    _joinerlimitcpu:: joiner.limitcpu,
    _joinerlimitmem:: joiner.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           joinerstorages.items
         else if deploytype == "podservice" then
           joinerpodservice.items
         else
           error "Unknow deploytype",
}
