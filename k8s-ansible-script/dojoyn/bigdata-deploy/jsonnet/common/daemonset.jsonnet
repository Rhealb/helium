(import "deployment.jsonnet") + {
  // override super global variables
  _mlabel: "ds",

  kind: "DaemonSet",
  spec+: {
    replicas:: super.replicas,
  }
}
