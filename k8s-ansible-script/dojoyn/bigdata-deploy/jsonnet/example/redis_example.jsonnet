{
  // redis deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local redisstorages = (import "../redis/deploy/redisstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
    _redisdatastoragesize:: globalconf.redis.redisdatastoragesize,
  },

  local redispodservice = (import "../redis/deploy/redispodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local redis = globalconf.redis,
    local redismaster = redis.master,
    local redisslave = redis.slave,
    _zkinstancecount:: redis.zkinstancecount,
    _redisexservicetype:: redis.exservicetype,
    _redisdockerimage:: redis.image,
    _redisexternalports:: redis.externalports,
    _redisnodeports:: redis.nodeports,
    _redismasterreplicas:: redismaster.replicas,
    _redismasterrequestcpu:: redismaster.requestcpu,
    _redismasterrequestmem:: redismaster.requestmem,
    _redismasterlimitcpu:: redismaster.limitcpu,
    _redismasterlimitmem:: redismaster.limitmem,
    _redisslavereplicas:: redisslave.replicas,
    _redisslaverequestcpu:: redisslave.requestcpu,
    _redisslaverequestmem:: redisslave.requestmem,
    _redisslavelimitcpu:: redisslave.limitcpu,
    _redisslavelimitmem:: redisslave.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           redisstorages.items
         else if deploytype == "podservice" then
           redispodservice.items
         else
           error "Unknow deploytype",
}
