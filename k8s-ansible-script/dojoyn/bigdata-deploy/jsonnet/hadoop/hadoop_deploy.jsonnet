{
  // hadoop deploy global variables
  _namespace:: "hadoop-jsonnet",

  local hdfs = (import "hdfs/deploy/hdfs_deploy.jsonnet") + {
    _namespace: $._namespace,
  },
  local yarn = (import "yarn/deploy/yarn_deploy.jsonnet") + {
    _namespace: $._namespace,
  },

  kind: "List",
  apiVersion: "v1",
  items: hdfs.items + yarn.items,
}