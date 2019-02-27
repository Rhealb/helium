(import "../common/job.jsonnet") + {
  // global variables
  _tfpsprefix:: "tbd",
  _psjobname:: "jobname",
  local utils = import "../common/utils/utils.libsonnet",
  _podantiaffinitytag:: self._tfpsprefix + "-" + "tfps" + super._jobname,
  _podantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _podantiaffinityns:: [super._mnamespace,],

  // override super global variables
  _mname: "tfps",
  _mnamespace: "hadoop-jsonnet",
  _dockerimage:: "127.0.0.1:30100/tensorflow/tf_grpc_test_server-gpu:platform",
  _envs:: [
    "CUDA_VISIBLE_DEVICES:0,1",
  ],
  _command:: ["/tmp/scripts/python/mnist_replica.py"],
  _args:: [],
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
          "purpose": "dedicate",
        },
      },
    },
  },
}
