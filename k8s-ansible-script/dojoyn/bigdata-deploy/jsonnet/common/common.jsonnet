{
  // global varibles, should not show in the final json format
  _mnamespace:: "tbd",
  _mname:: "tbd",
  _mlabel:: "tbd",
  // annotations currently can only support string arrays, like ["a:aa", "b:bb"], cannot
  // support variables yet, like ["a:$._aa"]. If annotations need to use variables, you should
  // not specify it in this variable, you should write it explicitly in jsonnet context.
  _mannotations:: [],

  apiVersion: "tbd",
  kind: "tbd",
  metadata: {
    name: $._mname,
    namespace: $._mnamespace,
    local annolist = [std.splitLimit(anno, ":", 1) for anno in $._mannotations],
    annotations: {
      [annos[0]]: annos[1] for annos in annolist
    },
    labels: {
      app: $._mname + "-" + $._mlabel,
      name: $._mname,
    },
  },
}
