(import "common.jsonnet") + {
  // global variables
  _nameports:: [],
  _nodeports:: [],
  _sname:: $._mname,
  _slabel:: "pod",
  _servicetype:: "ClusterIP",
  // override super global variables
  _mlabel: "svc",

  apiVersion: "v1",
  kind: "Service",
  spec: {
    selector: {
      app: $._sname + "-" + $._slabel,
      name: $._sname,
    },
    local portlist = [std.splitLimit(nameport, ":", 2) for nameport in $._nameports],
    local nodeportlist = [std.splitLimit(nodeport, ":", 2) for nodeport in $._nodeports],
    local resultportlist = if $._servicetype == "NodePort" then
                             nodeportlist
                           else 
                             portlist,
    ports: [
      {
        name: rp[0],
        port: if $._servicetype == "NodePort" then
                std.parseInt(rp[std.length(rp) - 1])
              else
                std.parseInt(rp[1]), 
        targetPort: std.parseInt(rp[std.length(rp) - 1]),

        nodePort: if $._servicetype == "NodePort" && std.length(rp) == 3 then
                    std.parseInt(rp[1])
                  else
                    null,
      } for rp in resultportlist
    ],
    type: if $._servicetype == "NodePort" || $._servicetype == "ClusterIP" then
            $._servicetype
          else
            error "Unkown servicetype(" + $._servicetype + ")",
  },
}
