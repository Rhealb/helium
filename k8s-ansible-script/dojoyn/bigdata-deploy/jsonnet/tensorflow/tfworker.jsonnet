(import "../common/job.jsonnet") + {
  // global variables
  _tfworkerprefix:: "tbd",
  _workerjobname:: "jobname",
  local utils = import "../common/utils/utils.libsonnet",
  _podantiaffinitytag:: self._tfworkerprefix + "-" + "tfworker" + self._workerjobname,
  _podantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _podantiaffinityns:: [super._mnamespace,],

  // override super global variables
  _mname: "tfworker",
  _mnamespace: "hadoop-jsonnet",
  _dockerimage:: "127.0.0.1:30100/tensorflow/tf_grpc_test_server-gpu:platform",
  _envs:: [
    "CUDA_VISIBLE_DEVICES:0,1"
  ],
  _command:: ["/tmp/scripts/python/mnist_replica.py"],
  _cephuser:: "admin",
  _cephsecretref:: "ceph-secret-jsonnet",
  spec+: {
    template+: {
      metadata+: {
        labels+: {
          "podantiaffinitytag": $._podantiaffinitytag,
        },
      },
      spec+: {
        affinity: utils.podantiaffinity($._podantiaffinitytag, $._podantiaffinitytype, $._podantiaffinityns),
        nodeSelector: {
          "addition": "GPU",
        },
      },
    },
  },
}
