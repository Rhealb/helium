{
  // kafka deploy global variables
  local globalconf = import "global_config.jsonnet",
  local deploytype = globalconf.deploytype,
  local componentoramah = globalconf.kafka.componentoramah,
  local ceph = globalconf.ceph,

  local kafkastorages = (import "../kafka/deploy/kafkastorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local kafka = globalconf.kafka,
    _utilsstoretype:: globalconf.utilsstoretype,
    _kafkainstancecount:: kafka.instancecount,
    _kafkalogstoragesize :: kafka.logpvcstoragesize,
  },

  local kafkapodservice = (import "../kafka/deploy/kafkapodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _location:: globalconf.location,
    _zkinstancecount: globalconf.zookeeper.instancecount,
    local kafka = globalconf.kafka,
    _utilsstoretype:: globalconf.utilsstoretype,
    _kafkaexservicetype:: kafka.exservicetype,
    _kafkadockerimage:: kafka.image,
    _kafkainstancecount:: kafka.instancecount,
    _kafkarequestcpu:: kafka.requestcpu,
    _kafkarequestmem:: kafka.requestmem,
    _kafkalimitcpu:: kafka.limitcpu,
    _kafkalimitmem:: kafka.limitmem,
    _externalports:: kafka.externalports,
    _nodeportip:: kafka.nodeportip,
    _kafkanodeports:: kafka.nodeports,
  },

  local amahkafkastorages = (import "../kafka/deploy/amahkafkastorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    _utilsstoretype:: globalconf.utilsstoretype,
  },

  local amahkafkapodservice = (import "../kafka/deploy/amahkafkapodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    _utilsstoretype:: globalconf.utilsstoretype,
    local amahkafka = globalconf.kafka.amah,
    _kafkainstancecount:: amahkafka.kafkainstancecount,
    _amahkafkaexservicetype:: amahkafka.exservicetype,
    _amahkafkadockerimage:: amahkafka.image,
    _amahkafkaexternalports:: amahkafka.externalports,
    _amahkafkanodeports:: amahkafka.nodeports,
    _amahkafkareplicas:: amahkafka.replicas,
    _amahkafkarequestcpu:: amahkafka.requestcpu,
    _amahkafkarequestmem:: amahkafka.requestmem,
    _amahkafkalimitcpu:: amahkafka.limitcpu,
    _amahkafkalimitmem:: amahkafka.limitmem,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           if componentoramah == "amah" then
             amahkafkastorages.items
           else
             kafkastorages.items
         else if deploytype == "podservice" then
           if componentoramah == "component" then
             kafkapodservice.items
           else if componentoramah == "amah" then
             amahkafkapodservice.items
           else if componentoramah == "both" then
             kafkapodservice.items + amahkafkapodservice.items
           else
             error "Unknow componentoramah type"
         else
           error "Unknow deploytype",
}
