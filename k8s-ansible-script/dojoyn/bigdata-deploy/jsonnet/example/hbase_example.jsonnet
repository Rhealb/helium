{
  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local hbasestorages = (import "../hbase/deploy/hbasestorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local hbasepodservice = (import "../hbase/deploy/hbasepodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _zknum:: globalconf.zookeeper.instancecount,
    local hbase = globalconf.hbase,
    local hmaster = hbase.master,
    local regionserver = hbase.regionserver,
    _utilsstoretype:: globalconf.utilsstoretype,
    _hbasedockerimage:: hbase.image,
    _hbaseexservicetype:: hbase.exservicetype,
    _externalports:: hbase.externalports,
    _hbasenodeports:: hbase.nodeports,
    _tsdbttl:: hbase.tsdbttl,
    _hminstancecount:: hmaster.instancecount,
    _rsinstancecount:: regionserver.instancecount,
    _hmrequestcpu:: hmaster.requestcpu,
    _hmrequestmem:: hmaster.requestmem,
    _hmlimitcpu:: hmaster.limitcpu,
    _hmlimitmem:: hmaster.limitmem,
    _hmasterpermsize:: hmaster.permsize,
    _hmastermaxpermsize:: hmaster.maxpermsize,
    _hmasterjavaxmx:: hmaster.javaxmx,
    _rsrequestcpu:: regionserver.requestcpu,
    _rsrequestmem:: regionserver.requestmem,
    _rslimitcpu:: regionserver.limitcpu,
    _rslimitmem:: regionserver.limitmem,
    _hregionserverpermsize:: regionserver.permsize,
    _hregionservermaxpermsize:: regionserver.maxpermsize,
    _hregionserverjavaxmx:: regionserver.javaxmx,
    _cephhostports:: ceph.hostports,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           hbasestorages.items
         else if deploytype == "podservice" then
           hbasepodservice.items
         else
           error "Unknow deploytype",
}
