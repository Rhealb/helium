### How to use bigdata-deploy template
##### bigdata-deploy template is used to simplify generate jsonnet code
##### 1. Into bigdata content
```
bigdata/
├── 2binary.sh
├── jsonnet
├── DEV_CONVENTION.md
├── doc
├── create_component.sh
├── README.md
├── template
  ├── portconfig.jsonnet
├── cephutils

```
##### 2. edit portconfig.jsonnet
you should add portname and port which you want to expose in portconfig.jsonnet. like this:
```
{
  ports: ["port1:1111","port2:2222"],
  exportsname: ["port1",],
}

```
The {ports} is an array, include portname and port which you wanted to expose in pod.
The {exportsname} include some port name which you wanted to exposure to the outside of the cluster, those port must be belong to the array of {ports}. 

##### 3. Run the command
```
$ ./create_component.sh [componentname]

```
Running this command will generate some of file and dir in bigdata. like this:
```
bigdata/
├── jsonnet
  ├── example
    ├── {componentname}_example.jsonnet
  ├── {componentname}
    ├── deploy
      ├── {componentname}podservice.jsonnet
      ├── {componentname}storage.jsonnet
    ├── {componentname}.jsonnet
    ├── {componentname}service.jsonnet
├── ...
├── cephutils
  ├── {componentname}utils
    ├── conf
    ├── entry
├── ...


```

##### 4. Edit global_config.jsonnet file
Run the above command, will add componentname related configuration into global_config.jsonnet,like this:
```
componentname: {
    image: $.registry + "/tools/opentsdb-2.3.0:beta-0.4",
    exservicetype: $.exservicetype,
    instancecount: 1,
    replicas: 1,
    requestcpu: "0",
    requestmem: "0",
    limitcpu: "0",
    limitmem: "0",
    externalports: {
    },
    nodeports: {
    },
   },

```
Before you edit global_config.jsonnet, you make sure the image is available, and add some of config file ,entrypoint file to specific directory if you wanted. And then you should modify the command in file of {componentname}podservice_deploy.jsonnet for youself, the default command is :
```
"/opt/entrypoint.sh /opt/mntcephutils/entry/entrypoint.sh"
```
###### 5. start pod and service in k8s
```
$ sudo ./bigctl create bigdata/jsonnet/example/{componentname}_example.jsonnet

```
