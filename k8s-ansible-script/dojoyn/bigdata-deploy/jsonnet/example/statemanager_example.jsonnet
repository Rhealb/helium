{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local statemanagerstorages = (import "../statemanager/deploy/statemanagerstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local statemanagerpodservice = (import "../statemanager/deploy/statemanagerpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local statemanager = globalconf.statemanager,
    _statemanagerexservicetype:: statemanager.exservicetype,
    _statemanagerdockerimage:: statemanager.image,
    _statemanagerexternalports:: statemanager.externalports,
    _statemanagernodeports:: statemanager.nodeports,
    _statemanagerinstancecount:: statemanager.instancecount,
    _statemanagerreplicas:: statemanager.replicas,
    _statemanagerrequestcpu:: statemanager.requestcpu,
    _statemanagerrequestmem:: statemanager.requestmem,
    _statemanagerlimitcpu:: statemanager.limitcpu,
    _statemanagerlimitmem:: statemanager.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           statemanagerstorages.items
         else if deploytype == "podservice" then
           statemanagerpodservice.items
         else
           error "Unknow deploytype",
}
