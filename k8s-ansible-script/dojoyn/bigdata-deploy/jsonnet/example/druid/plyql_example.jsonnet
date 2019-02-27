{
  // mysql deploy global variables

  local globalconf = import "../global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local ceph = globalconf.ceph,

  local plyqlstorages = (import "../../druid/plyql/deploy/plyqlstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local plyqlpodservice = (import "../../druid/plyql/deploy/plyqlpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    local plyql = globalconf.druid.plyql,
    _utilsstoretype:: globalconf.utilsstoretype,
    _plyqlexservicetype:: plyql.exservicetype,
    _plyqldockerimage:: plyql.image,
    _externalports:: plyql.externalports,
    _plyqlnodeports:: plyql.nodeports,
    _plyqlinstancecount:: plyql.instancecount,
    _plyqlrequestcpu:: plyql.requestcpu,
    _plyqlrequestmem:: plyql.requestmem,
    _plyqllimitcpu:: plyql.limitcpu,
    _plyqllimitmem:: plyql.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           plyqlstorages.items
         else if deploytype == "podservice" then
           plyqlpodservice.items
         else
           error "Unknow deploytype",
}
