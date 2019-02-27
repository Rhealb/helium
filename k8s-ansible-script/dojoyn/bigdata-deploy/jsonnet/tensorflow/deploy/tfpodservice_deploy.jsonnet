{
  // hbase deploy global variables
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "",
  _grpcimage:: "127.0.0.1:30100/tensorflow/tf_grpc_test_server-gpu:cuda-8.0-v2",
  _jobname:: "tf-test-client-gpu",
  _modelname:: "MNIST",
  _workernum:: 2,
  _psnum:: 1,
  _setup_cluster_only:: 1,
  _cephfsstoragename:: "tensorflow",
  _containerpath:: "/tmp",

  _tfworkerrequestcpu:: "0.5",
  _tfworkerrequestmem:: "2Gi",
  _tfworkerlimitcpu:: "0.5",
  _tfworkerlimitmem:: "2Gi",

  _tfpsrequestcpu:: "0.5",
  _tfpsrequestmem:: "1Gi",
  _tfpslimitcpu:: "0.5",
  _tfpslimitmem:: "1Gi",

  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _tfworkerpodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _tfpspodantiaffinitytype:: "preferredDuringSchedulingIgnoredDuringExecution",
  _externalports:: {
    tfpsports:: [],
  },
  _tfnodeports:: {
    tfpsports:: [],
  },
  _tfexservicetype:: "ClusterIP",
  local externalips = $._externalips,
  local utils = import "../../common/utils/utils.libsonnet",
  local externaltfpsports = $._externalports.tfpsports,
  local nodetfpsports = $._tfnodeports.tfpsports,

  local externalip = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephpvpath = [
    $._cephpath,
  ],
  local cephbasename = [$._cephfsstoragename],
  local cephfsstoragename = [ name for name in cephbasename],

  _n_gpus:: 1,
  _existing_servers:: false,
  _output_path:: "/tmp/output",
  _data_dir:: "/tmp/data",
  _log_dir:: "/tmp/log/",
  _sync_replicas:: 1,
  _timeout:: 120,
  _train_steps:: 100,
  local worker_hosts = std.join(",", [$._suiteprefix + "-" + "tfworker"+ tfworkernum + "-" + $._jobname + ":2222" for tfworkernum in std.range(0,$._workernum - 1)]),
  local ps_hosts = std.join(";",[$._suiteprefix + "-" + "tfps" + tfpsnum + "-" + $._jobname + ":2222" for tfpsnum in std.range(0,$._psnum - 1)]),

  kind: "List",
  apiVersion: "v1",
  items: (if $._tfexservicetype != "None" then
  [
    (import "../tfpsservice.jsonnet") + {
      // override tfpsservice global variables
      _tfpsprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._tfpsprefix + "-" + super._mname + tfpsnum + "-" + $._jobname + "-ex",
      _sname: self._tfpsprefix + "-" + super._mname + tfpsnum + "-" + $._jobname,
      _servicetype: $._tfexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips
               }
             else
               {},
      _nameports: [
        "tfpsport" + utils.addcolonforport(externaltfpsports[tfpsnum]) + ":2222",
      ],
      _nodeports: [
        "tfpsport" + utils.addcolonforport(nodetfpsports[tfpsnum]) + ":2222",
      ],
    } for tfpsnum in std.range(0, $._psnum - 1)
  ]
  else
  []) + [
    (import "../tfpsservice.jsonnet") + {
      // override tfpsservice global variables
      _tfpsprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._tfpsprefix + "-" + super._mname + tfpsnum + "-" + $._jobname,

    } for tfpsnum in std.range(0, $._psnum - 1)
  ] + [
    (import "../tfps.jsonnet") + {
      // override tfps global variables
      _tfpsprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._tfpsprefix + "-" + super._mname + tfpsnum + "-" + $._jobname,
      _dockerimage: $._grpcimage,
      _containerrequestcpu:: $._tfpsrequestcpu,
      _containerrequestmem:: $._tfpsrequestmem,
      _containerlimitcpu:: $._tfpslimitcpu,
      _containerlimitmem:: $._tfpslimitmem,
      _podantiaffinitytype: $._tfpspodantiaffinitytype,
      _podantiaffinitytag: self._tfpsprefix + "-" + "tfps" + "-" + $._jobname,
      _podantiaffinityns: [self._mnamespace,],
      _psjobname: $._jobname,

      _nameports:: ["tfpsport:2222",],
      _volumemounts:: [
        "tfcephfs:" + $._containerpath,
        "nvidiadir:/opt/nvidia",
        "toolsdir:/opt/tools",
      ],
      _volumes:: [
        "tfcephfs:persistentVolumeClaim:" + cephfsstoragename[0],
        "nvidiadir:hostPath:/opt/lib/nvidia",
        "toolsdir:hostPath:/opt/lib/tools",
      ],
      _command:: ["/tmp/entrypoint.sh","ps" + tfpsnum + "-" + $._jobname + ".log",$._output_path,$._log_dir,
              "--existing_servers=" + $._existing_servers,
              "--ps_hosts=" + ps_hosts,
              "--worker_hosts=" + worker_hosts,
              "--job_name=ps",
              "--task_index=" + tfpsnum,
              "--num_gpus=" + $._n_gpus,
              "--data_dir=" + $._data_dir,
              "--output_path=" + $._output_path,
              "--sync_replicas=" + $._sync_replicas,
             ],
    } for tfpsnum in std.range(0, $._psnum - 1)
  ] + [
    (import "../tfworker.jsonnet") + {
      // override tfworker global variables
      _tfworkerprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._tfworkerprefix + "-" + super._mname + tfworkernum + "-" + $._jobname,
      _dockerimage: $._grpcimage,
      _containerrequestcpu:: $._tfworkerrequestcpu,
      _containerrequestmem:: $._tfworkerrequestmem,
      _containerlimitcpu:: $._tfworkerlimitcpu,
      _containerlimitmem:: $._tfworkerlimitmem,
      _containerrequestgpu: 1,
      _containerlimitgpu: 1,
      _podantiaffinitytype: $._tfworkerpodantiaffinitytype,
      _podantiaffinitytag: self._tfworkerprefix + "-" + "tfworker" + "-" + $._jobname,
      _podantiaffinityns: [self._mnamespace,],
      _workerjobname: $._jobname,

      _nameports:: ["tfworkerport:2222",],
      _volumemounts:: [
        "tfcephfs:" + $._containerpath,
        "nvidiadir:/opt/nvidia",
        "toolsdir:/opt/tools",
      ],
      _volumes:: [
        "tfcephfs:persistentVolumeClaim:" + cephfsstoragename[0],
        "nvidiadir:hostPath:/opt/lib/nvidia",
        "toolsdir:hostPath:/opt/lib/tools",
      ],
      _command:: ["/tmp/entrypoint.sh","worker" + tfworkernum + "-" + $._jobname + ".log",$._output_path,$._log_dir,
              "--existing_servers=" + $._existing_servers,
              "--ps_hosts=" + ps_hosts,
              "--worker_hosts=" + worker_hosts,
              "--job_name=worker",
              "--task_index=" + tfworkernum,
              "--num_gpus=" + $._n_gpus,
              "--data_dir=" + $._data_dir,
              "--output_path=" + $._output_path,
              "--train_steps=" + $._train_steps,
              "--sync_replicas=" + $._sync_replicas,
              ],
    } for tfworkernum in std.range(0, $._workernum - 1)
  ] + [
    (import "../tfworkerservice.jsonnet") + {
      // override tfworkerservice global variables
      _tfworkerprefix:: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._tfworkerprefix + "-" + super._mname + tfworkernum + "-" + $._jobname,
    } for tfworkernum in std.range(0, $._workernum - 1)
  ],
}
