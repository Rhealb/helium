{
  // kafka deploy global variables
  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local kafkamanagerstorages = (import "../kafka-manager/deploy/kafkamanagerstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local kafkamanagerpodservice = (import "../kafka-manager/deploy/kafkamanagerpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _zkinstancecount:: globalconf.zookeeper.instancecount,
    local kafkamanager = globalconf.kafkamanager,
    _utilsstoretype:: globalconf.utilsstoretype,
    _kafkamanagerexservicetype:: kafkamanager.exservicetype,
    _kafkamanagerdockerimage:: kafkamanager.image,
    _kafkamanagerrequestcpu:: kafkamanager.requestcpu,
    _kafkamanagerrequestmem:: kafkamanager.requestmem,
    _kafkamanagerlimitcpu:: kafkamanager.limitcpu,
    _kafkamanagerlimitmem:: kafkamanager.limitmem,
    _externalports:: kafkamanager.externalports,
    _kafkamanagerinstancecount:: kafkamanager.instancecount,
    _kafkamanagernodeports:: kafkamanager.nodeports,

  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           kafkamanagerstorages.items
         else if deploytype == "podservice" then
           kafkamanagerpodservice.items
         else
           error "Unknow deploytype",
}
