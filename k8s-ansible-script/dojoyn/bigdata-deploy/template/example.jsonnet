{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local %NAME%storages = (import "../%NAME%/deploy/%NAME%storage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local %NAME%podservice = (import "../%NAME%/deploy/%NAME%podservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local %NAME% = globalconf.%NAME%,
    _%NAME%exservicetype:: %NAME%.exservicetype,
    _%NAME%dockerimage:: %NAME%.image,
    _%NAME%externalports:: %NAME%.externalports,
    _%NAME%nodeports:: %NAME%.nodeports,
    _%NAME%instancecount:: %NAME%.instancecount,
    _%NAME%replicas:: %NAME%.replicas,
    _%NAME%requestcpu:: %NAME%.requestcpu,
    _%NAME%requestmem:: %NAME%.requestmem,
    _%NAME%limitcpu:: %NAME%.limitcpu,
    _%NAME%limitmem:: %NAME%.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           %NAME%storages.items
         else if deploytype == "podservice" then
           %NAME%podservice.items
         else
           error "Unknow deploytype",
}
