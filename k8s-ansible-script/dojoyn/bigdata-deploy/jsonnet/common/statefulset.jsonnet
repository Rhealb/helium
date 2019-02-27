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
  _volumeclaimtemplates:: [],
  _cephhostports:: [],
  _cephuser:: "tbd",
  _cephsecretref:: "tbd",
  _containerrequestcpu:: "0",
  _containerrequestmem:: "0",
  _containerlimitcpu:: "0",
  _containerlimitmem:: "0",
  _rollingupdatetype:: "RollingUpdate",
  _privileged:: false,
  _servicename:: "",

  // override super global variables
  _mlabel: "ss",

  apiVersion: "apps/v1beta1",
  kind: "StatefulSet",
  spec: {
    selector: {
      matchLabels: {
        app: $._sname + "-" + $._slabel,
        name: $._sname,
      },
    },
    strategy: {
      type: $._rollingupdatetype,
      rollingUpdate: {
        maxUnavailable: 1,
        maxSurge: 0,
      },
    },
    serviceName: $._mname,
    replicas: $._replicacount,
    template: {
      metadata: {
        annotations: {
          "pod.beta.kubernetes.io/hostname": $._mname,
        },
        labels: {
          app: $._sname + "-" + $._slabel,
          name: $._sname,
        },
      },
      spec: {
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
            local volmountlist = [std.split(volmount, ":") for volmount in $._volumemounts],
            volumeMounts: [
              {
                name: vm[0],
                mountPath: vm[1],
                readOnly: if std.length(vm) == 3 && vm[2] == "true" then
                            true
                          else
                            false,
              } for vm in volmountlist
            ],
            resources: {
              requests: {
                memory: $._containerrequestmem,
                cpu: $._containerrequestcpu,
              },
              limits: {
                memory: $._containerlimitmem,
                cpu: $._containerlimitcpu,
              },
            },
            securityContext: {
               privileged: $._privileged,
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
                      else if vol[1] == "configMap" then
                        {
                          name: vol[2],
                        }
                      else
                        error "not support volume type",
          } for vol in volumelist
        ],
        storage: [
          { 
            name: $._storages[i],
          } for i in std.range(0, std.length($._storages) - 1)
        ],
      },
    },
    volumeClaimTemplates: [
     {
       metadata: {
         name: std.splitLimit($._volumeclaimtemplates[i], ":", 2)[0],
         annotations: {
           "volume.beta.kubernetes.io/storage-class": super._mnamespace,
         },
       },
       spec: {
         accessModes: [
          "ReadWriteMany",
         ],
         resources: {
           requests: {
            storage: std.splitLimit($._volumeclaimtemplates[i], ":", 2)[1],
           }
         }
       }
     } for i in std.range(0, std.length($._volumeclaimtemplates) - 1)
    ]
  },
}
