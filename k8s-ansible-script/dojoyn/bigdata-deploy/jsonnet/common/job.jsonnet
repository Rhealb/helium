(import "common.jsonnet") + {
  // global variables
  _replicacount:: 1,
  _nameports:: [],
  _dockerimage:: "tbd",
  _imagepullpolicy:: "IfNotPresent",
  _args:: [],
  _command:: [],
  _envs:: [],
  _sname:: $._mname,
  _slabel:: "pod",
  _volumemounts:: [],
  _volumes:: [],
  _storages:: [],
  _cephhostports:: [],
  _cephuser:: "tbd",
  _cephsecretref:: "tbd",
  _containerrequestcpu:: "0",
  _containerrequestmem:: "0",
  _containerlimitcpu:: "0",
  _containerlimitmem:: "0",
  _containerrequestgpu:: 0,
  _containerlimitgpu:: 0,
  _restartPolicy:: "Never",

  // override super global variables
  _mlabel: "job",

  apiVersion: "batch/v1",
  kind: "Job",
  spec: {
    manualSelector: true,
    selector: {
      matchLabels: {
        app: $._sname + "-" + $._slabel,
        name: $._sname,
      },
    },
    template: {
      metadata: {
        annotations: {
        },
        labels: {
          app: $._sname + "-" + $._slabel,
          name: $._sname,
        },
      },
      spec: {
        restartPolicy: $._restartPolicy,
        containers: [
          {
            image: $._dockerimage,
            imagePullPolicy: $._imagepullpolicy,
            name: $._mname,
            args: $._args,
            command: $._command,
            local envlist = [std.splitLimit(en, ":", 1) for en in $._envs],
            env: [
              { name: e[0], value: e[1]  } for e in envlist
            ],
            local portlist = [std.splitLimit(nameport, ":", 1) for nameport in $._nameports],
            ports: [
              { name: np[0], containerPort: std.parseInt(np[1]) } for np in portlist
            ],
            local volmountlist = [std.splitLimit(volmount, ":", 1) for volmount in $._volumemounts],
            volumeMounts: [
              {
                name: vm[0],
                mountPath: vm[1],
              } for vm in volmountlist
            ],
            resources: {
              requests: {
                memory: $._containerrequestmem,
                cpu: $._containerrequestcpu,
                "alpha.kubernetes.io/nvidia-gpu": $._containerrequestgpu,
              },
              limits: {
                memory: $._containerlimitmem,
                cpu: $._containerlimitcpu,
                "alpha.kubernetes.io/nvidia-gpu": $._containerlimitgpu,
              },
            },
          },
        ],
        local volumelist = [std.splitLimit(volume, ":", 2) for volume in $._volumes],
        volumes: [
          {
            name: vol[0],
            [vol[1]]: if vol[1] == "hostPath" then
                        {
                          path: vol[2]
                        }
                      else if vol[1] == "cephfs" then
                        {
                          monitors: $._cephhostports,
                          user: $._cephuser,
                          path: vol[2],
                          secretRef: {
                            name: $._cephsecretref,
                          },
                        }
                      else if vol[1] == "persistentVolumeClaim" then
                        {
                          claimName: vol[2],
                        }
                      else if vol[1] == "emptyDir" then
                        {}
                      else
                        error "not support volume type",
          } for vol in volumelist
        ],
      },
    },
  },
}
