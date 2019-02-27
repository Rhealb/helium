{
  local globalconf = import "../global_config.jsonnet",
  local deploytype = globalconf.deploytype,

  local tfpodservice = (import "../../tensorflow/deploy/tfpodservice_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _externalips:: globalconf.externalips,
    local tensorflow = globalconf.tensorflow,
    _tfexservicetype:: tensorflow.exservicetype,
    _tfnodeports:: tensorflow.nodeports,
    _externalports:: tensorflow.externalports,
    _tfworkerrequestcpu:: tensorflow.tfworkerrequestcpu,
    _tfworkerrequestmem:: tensorflow.tfworkerrequestmem,
    _tfworkerlimitcpu:: tensorflow.tfworkerlimitcpu,
    _tfworkerlimitmem:: tensorflow.tfworkerlimitmem,
    _tfpsrequestcpu:: tensorflow.tfpsrequestcpu,
    _tfpsrequestmem:: tensorflow.tfpsrequestmem,
    _tfpslimitcpu:: tensorflow.tfpslimitcpu,
    _tfpslimitmem:: tensorflow.tfpslimitmem,
    _workernum:: tensorflow.workernum,
    _psnum:: tensorflow.psnum,
    _jobname:: tensorflow.jobname,
    _modelname:: tensorflow.modelname,
    _grpcimage:: tensorflow.grpcimage,
    _setup_cluster_only:: tensorflow.setup_cluster_only,
    _n_gpus:: tensorflow.n_gpus,
    _existing_servers:: tensorflow.existing_servers,
    _output_path:: tensorflow.output_path,
    _cephfsstoragename:: tensorflow.cephfsstoragename,
    _containerpath:: tensorflow.containerpath,
    _data_dir:: tensorflow.data_dir,
    _log_dir:: tensorflow.log_dir,
    _sync_replicas:: tensorflow.sync_replicas,
    _train_steps:: tensorflow.train_steps,
  },

  local tfstorages = (import "../../tensorflow/deploy/tfstorage_deploy.jsonnet") + {
    _namespace:: globalconf.namespace,
    _suiteprefix:: globalconf.suiteprefix,
    _mountdevtype:: globalconf.mountdevtype,
    local tensorflow = globalconf.tensorflow,
    _cephfsstoragename:: tensorflow.cephfsstoragename,
    _cephfsstoragesize:: tensorflow.cephfsstoragesize,
  },

  kind: "List",
  apiVersion: "v1",
  items: if deploytype == "storage" then
           tfstorages.items
         else if deploytype == "podservice" then
           tfpodservice.items
         else
           error "Unknow deploytype",
}
