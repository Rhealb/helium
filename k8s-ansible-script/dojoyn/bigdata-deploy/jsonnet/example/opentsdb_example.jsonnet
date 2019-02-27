{
  // opentsdb deploy global variables
  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local opentsdbstorages = (import "../opentsdb/deploy/opentsdbstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local opentsdb = globalconf.opentsdb,
    _utilsstoretype:: globalconf.utilsstoretype,
    _opentsdbinstancecount:: opentsdb.instancecount,
    _opentsdblogstoragesize :: opentsdb.logpvcstoragesize,
  },

  local opentsdbpodservice = (import "../opentsdb/deploy/opentsdbpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _zkinstancecount:: globalconf.zookeeper.instancecount,
    local opentsdb = globalconf.opentsdb,
    _utilsstoretype:: globalconf.utilsstoretype,
    _opentsdbdockerimage:: opentsdb.image,
    _opentsdbexservicetype:: opentsdb.exservicetype,
    _opentsdbinstancecount:: opentsdb.instancecount,
    _opentsdbrequestcpu:: opentsdb.requestcpu,
    _opentsdbrequestmem:: opentsdb.requestmem,
    _opentsdblimitcpu:: opentsdb.limitcpu,
    _opentsdblimitmem:: opentsdb.limitmem,
    _externalports:: opentsdb.externalports,
    _opentsdbnodeports:: opentsdb.nodeports,
    _opentsdbjavaxms:: opentsdb.javaxms,
    _opentsdbjavaxmx:: opentsdb.javaxmx,
  },
  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           opentsdbstorages.items
         else if deploytype == "podservice" then
           opentsdbpodservice.items
         else
           error "Unknow deploytype",
}
