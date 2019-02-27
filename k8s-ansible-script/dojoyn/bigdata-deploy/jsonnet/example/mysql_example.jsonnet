{
  // mysql deploy global variables

  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local mysqlstorages = (import "../mysql/deploy/mysqlstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local mysql = globalconf.mysql,
    _utilsstoretype:: globalconf.utilsstoretype,
    _mysqldatastoragesize:: mysql.mysqldatapvcstoragesize,
  },

  local mysqlpodservice = (import "../mysql/deploy/mysqlpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    local mysql = globalconf.mysql,
    _utilsstoretype:: globalconf.utilsstoretype,
    _creatdbstart:: mysql.creatdbstart,
    _databases:: mysql.databases,
    _mysqlpassword:: mysql.password,
    _mysqlexservicetype:: mysql.exservicetype,
    _mysqldockerimage:: mysql.image,
    _externalports:: mysql.externalports,
    _mysqlnodeports:: mysql.nodeports,
    _mysqlinstancecount:: mysql.instancecount,
    _mysqlrequestcpu:: mysql.requestcpu,
    _mysqlrequestmem:: mysql.requestmem,
    _mysqllimitcpu:: mysql.limitcpu,
    _mysqllimitmem:: mysql.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           mysqlstorages.items
         else if deploytype == "podservice" then
           mysqlpodservice.items
         else
           error "Unknow deploytype",
}
