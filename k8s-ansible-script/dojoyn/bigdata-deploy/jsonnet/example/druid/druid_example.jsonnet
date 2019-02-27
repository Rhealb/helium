{
  // druid deploy global variables

  local globalconf = import "../global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local druidstorages = (import "../../druid/origin/deploy/druidstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local druid = globalconf.druid.origin,
    local historical = druid.historical,
    local middlemanager = druid.middlemanager,
    _utilsstoretype:: globalconf.utilsstoretype,
    _histsegmentcachestoragesize:: historical.histsegmentcachepvcstoragesize,
    _mmsegmentsstoragesize:: middlemanager.mmsegmentsstoragesize,
  },

  local druidpodservice = (import "../../druid/origin/deploy/druidpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    local druid = globalconf.druid.origin,
    local broker = druid.broker,
    local coordinator = druid.coordinator,
    local historical = druid.historical,
    local middlemanager = druid.middlemanager,
    local overlord = druid.overlord,
    _utilsstoretype:: globalconf.utilsstoretype,
    _mysqlpasswd:: druid.mysqlpasswd,
    _mysqlusername:: druid.mysqlusername,
    _druidexservicetype:: druid.exservicetype,
    _druiddockerimage:: druid.image,
    _externalports:: druid.externalports,
    _druidnodeports:: druid.nodeports,
    _brokerinstancecount:: broker.instancecount,
    _coordinatorinstancecount:: coordinator.instancecount,
    _historicalinstancecount:: historical.instancecount,
    _middlemanagerinstancecount:: middlemanager.instancecount,
    _overlordinstancecount:: overlord.instancecount,
    _brokerrequestcpu:: broker.requestcpu,
    _brokerrequestmem:: broker.requestmem,
    _brokerlimitcpu:: broker.limitcpu,
    _brokerlimitmem:: broker.limitmem,
    _coordinatorrequestcpu:: coordinator.requestcpu,
    _coordinatorrequestmem:: coordinator.requestmem,
    _coordinatorlimitcpu:: coordinator.limitcpu,
    _coordinatorlimitmem:: coordinator.limitmem,
    _historicalrequestcpu:: historical.requestcpu,
    _historicalrequestmem:: historical.requestmem,
    _historicallimitcpu:: historical.limitcpu,
    _historicallimitmem:: historical.limitmem,
    _middlemanagerrequestcpu:: middlemanager.requestcpu,
    _middlemanagerrequestmem:: middlemanager.requestmem,
    _middlemanagerlimitcpu:: middlemanager.limitcpu,
    _middlemanagerlimitmem:: middlemanager.limitmem,
    _overlordrequestcpu:: overlord.requestcpu,
    _overlordrequestmem:: overlord.requestmem,
    _overlordlimitcpu:: overlord.limitcpu,
    _overlordlimitmem:: overlord.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           druidstorages.items
         else if deploytype == "podservice" then
           druidpodservice.items
         else
           error "Unknow deploytype",
}
