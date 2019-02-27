{
  // kafka deploy global variables
  local zookeeper = import "../zookeeper_example.jsonnet",
  local kafka = import "../kafka_example.jsonnet",
  local kafkadependencies = import "kafkadependencies.jsonnet",

  kind: "List",
  apiVersion: "v1",
  resources: zookeeper.items + kafka.items,
  dependencies: kafkadependencies.items,
}
