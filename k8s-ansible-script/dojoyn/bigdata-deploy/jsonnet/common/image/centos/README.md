## How to get check 

##### Get source code of the project and build it.

```
$ git clone ssh://git@10.19.248.12:30885/kubernetes/dependency.git

```

##### Install the package which the source code uses and build it.

```
$ go get github.com/spf13/pflag
$ cd test-ip
$ go build -o check

```