{
  // global variables
  _mname:: "ceph-secret-jsonnet",
  _mnamespace:: "yancheng-jsonnet",
  _location:: "yancheng",

  apiVersion: "v1",
  kind: "Secret",
  metadata: {
    name: $._mname,
    namespace: $._mnamespace,
  },
  data: {
    key: if $._location == "shanghai" then
           // for shanghai
           "QVFCdEFObFgzeUtuR0JBQWM0YURORGF6RDlRSVR6b1YrME9zR0E9PQ=="
         else if $._location == "yancheng" then
           // for yancheng
           "QVFCQk1oaFltR09vQ1JBQVFqVG1wYWR0U2VhVUdjdThGYnRRbEE9PQ=="
         else
           // for langfang
           "QVFDcDBmMVlyU0tRQ0JBQUtlaTZVVGFQY3ZPSE1oN0VJT3ZGU3c9PQo=",
  }
}
