## How to get dependency

##### You have a working [Go environment]. Download kubernetes source code

```
$ go get -d k8s.io/kubernetes

```

##### Get source code of the project, install the packages it uses and build it.

```
$ git clone ssh://git@10.19.248.12:30885/kubernetes/dependency.git
$ go get github.com/spf13/pflag
$ go get github.com/golang/protobuf/proto
$ go get github.com/xeipuuv/gojsonschema
$ cd checkdep/exec
$ go build -o dependency

```

[Go environment]: https://golang.org/doc/install