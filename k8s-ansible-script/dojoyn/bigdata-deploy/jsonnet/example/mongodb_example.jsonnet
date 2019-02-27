{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local mongodbstorages = (import "../mongodb/deploy/mongodbstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local mongodbpodservice = (import "../mongodb/deploy/mongodbpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local mongodb = globalconf.mongodb,
    _mongodbexservicetype:: mongodb.exservicetype,
    _mongodbdockerimage:: mongodb.image,
    _mongodbexternalports:: mongodb.externalports,
    _mongodbnodeports:: mongodb.nodeports,
    _mongodbinstancecount:: mongodb.instancecount,
    _mongodbreplicas:: mongodb.replicas,
    _mongodbrequestcpu:: mongodb.requestcpu,
    _mongodbrequestmem:: mongodb.requestmem,
    _mongodblimitcpu:: mongodb.limitcpu,
    _mongodblimitmem:: mongodb.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           mongodbstorages.items
         else if deploytype == "podservice" then
           mongodbpodservice.items
         else
           error "Unknow deploytype",
}
