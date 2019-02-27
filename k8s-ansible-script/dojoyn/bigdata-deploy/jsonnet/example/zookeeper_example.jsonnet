{
  // zookeeper deploy global variables
  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local componentoramah = globalconf.zookeeper.componentoramah,

  local zkstorages = (import "../zookeeper/deploy/zkstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local zookeeper = globalconf.zookeeper,
    _utilsstoretype:: globalconf.utilsstoretype,
    _zkinstancecount:: zookeeper.instancecount,
    _zkdatastoragesize:: zookeeper.datapvcstoragesize,
    _zkdatalogstoragesize:: zookeeper.datalogpvcstoragesize,
  },

  local zkpodservice = (import "../zookeeper/deploy/zkpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    local zookeeper = globalconf.zookeeper,
    _utilsstoretype:: globalconf.utilsstoretype,
    _zkexservicetype:: zookeeper.exservicetype,
    _zknodeports :: zookeeper.nodeports,
    _zkdockerimage:: zookeeper.image,
    _externalports:: zookeeper.externalports,
    _zkinstancecount:: zookeeper.instancecount,
    _zkrequestcpu:: zookeeper.requestcpu,
    _zkrequestmem:: zookeeper.requestmem,
    _zklimitcpu:: zookeeper.limitcpu,
    _zklimitmem:: zookeeper.limitmem,
  },

  local amahzkstorages = (import "../zookeeper/deploy/amahzkstorage_deploy.jsonnet") + {
   _namespace:: globalconf.namespace,
   _suiteprefix:: globalconf.suiteprefix,
   _mountdevtype:: globalconf.mountdevtype,
   _utilsstoretype:: globalconf.utilsstoretype,
 },
  local amahzkpodservice = (import "../zookeeper/deploy/amahzkpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local amahzk = globalconf.zookeeper.amah,
    _zkinstancecount:: amahzk.zkinstancecount,
    _amahzkexservicetype:: amahzk.exservicetype,
    _amahzkdockerimage:: amahzk.image,
    _amahzkexternalports:: amahzk.externalports,
    _amahzknodeports:: amahzk.nodeports,
    _amahzkreplicas:: amahzk.replicas,
    _amahzkrequestcpu:: amahzk.requestcpu,
    _amahzkrequestmem:: amahzk.requestmem,
    _amahzklimitcpu:: amahzk.limitcpu,
    _amahzklimitmem:: amahzk.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           if componentoramah == "amah" then
             amahzkstorages.items
           else
             zkstorages.items
         else if deploytype == "podservice" then
           if componentoramah == "component" then
             zkpodservice.items
           else if componentoramah == "amah" then
             amahzkpodservice.items
           else if componentoramah == "both" then
             zkpodservice.items + amahzkpodservice.items
          else
             error "Unknow componentoramah type"
         else
           error "Unknow deploytype",
}
