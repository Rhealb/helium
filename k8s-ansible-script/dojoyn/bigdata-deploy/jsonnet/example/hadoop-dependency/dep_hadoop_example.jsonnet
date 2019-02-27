{
  // hadoop deploy global variables
  local zookeeper = import "../zookeeper_example.jsonnet",
  local hadoop = import "../hadoop_example.jsonnet",
  local hadoopdependencies = import "hadoopdependencies.jsonnet",

  kind: "List",
  apiVersion: "v1",
  resources: zookeeper.items + hadoop.items,
  dependencies: hadoopdependencies.items,

}
