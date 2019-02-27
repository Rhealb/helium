{
  // spark deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local sparkstorages = (import "../spark/deploy/sparkstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local spark = globalconf.spark,
    _utilsstoretype:: globalconf.utilsstoretype,
    _workerworkdirstoragesize:: spark.workerworkdirpvcstoragesize,
    _localdirstoragesize:: spark.localdirpvcstoragesize,
  },

  local sparkpodservice = (import "../spark/deploy/sparkpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _zkinstancecount:: globalconf.zookeeper.instancecount,
    _jninstancecount:: globalconf.hadoop.hdfs.journalnode.instancecount,
    local spark = globalconf.spark,
    local master = spark.master,
    local worker = spark.worker,
    local historyserver = spark.historyserver,
    _utilsstoretype:: globalconf.utilsstoretype,
    _sparkdockerimage:: spark.image,
    _sparkexservicetype:: spark.exservicetype,
    _externalports:: spark.externalports,
    _sparknodeports:: spark.nodeports,
    _masterinstancecount:: master.instancecount,
    _workerinstancecount:: worker.instancecount,
    _historyserverinstancecount:: historyserver.instancecount,
    _masterrequestcpu:: master.requestcpu,
    _masterrequestmem:: master.requestmem,
    _masterlimitcpu:: master.limitcpu,
    _masterlimitmem:: master.limitmem,
    _workerrequestcpu:: worker.requestcpu,
    _workerrequestmem:: worker.requestmem,
    _workerlimitcpu:: worker.limitcpu,
    _workerlimitmem:: worker.limitmem,
    _sparkworkercores:: worker.sparkworkercores,
    _historyserverrequestcpu:: historyserver.requestcpu,
    _historyserverrequestmem:: historyserver.requestmem,
    _historyserverlimitcpu:: historyserver.limitcpu,
    _historyserverlimitmem:: historyserver.limitmem,
    _sparkeventlogdir:: historyserver.sparkeventlogdir,
    _cephhostports:: ceph.hostports,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           sparkstorages.items
         else if deploytype == "podservice" then
           sparkpodservice.items
         else
           error "Unknow deploytype",
}
