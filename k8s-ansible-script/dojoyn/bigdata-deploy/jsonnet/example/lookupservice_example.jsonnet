{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local lookupservicestorages = (import "../lookupservice/deploy/lookupservicestorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local lookupservicepodservice = (import "../lookupservice/deploy/lookupservicepodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local lookupservice = globalconf.lookupservice,
    _lookupserviceexservicetype:: lookupservice.exservicetype,
    _lookupservicedockerimage:: lookupservice.image,
    _lookupserviceexternalports:: lookupservice.externalports,
    _lookupservicenodeports:: lookupservice.nodeports,
    _lookupserviceinstancecount:: lookupservice.instancecount,
    _lookupservicereplicas:: lookupservice.replicas,
    _lookupservicerequestcpu:: lookupservice.requestcpu,
    _lookupservicerequestmem:: lookupservice.requestmem,
    _lookupservicelimitcpu:: lookupservice.limitcpu,
    _lookupservicelimitmem:: lookupservice.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           lookupservicestorages.items
         else if deploytype == "podservice" then
           lookupservicepodservice.items
         else
           error "Unknow deploytype",
}
