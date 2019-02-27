( import "../common/deployment.jsonnet" ) + {
  // global variables
  spec+: {
    template+: {
      metadata+: {
        annotations: {
          "io.enndata.dns/pod.enable":"true",
        }
      }
    }
  }
}
