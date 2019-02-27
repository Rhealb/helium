# k8s ansible script

## Description
This project served as installer for following components.

- kubernetes cluster
- ceph storage
- harbor registy
- ldap server
- console eco-system
- monitor eco-system

## Prerequisite
To use this project, you need following softwares.
- Docker
- GNU automake

## Usage
### Initialization
Clone and initialize this project.
```
cd ~ && git clone ssh://git@gitlab.cloud.enndata.cn:10885/enn-product/k8s-ansible-script.git
cd k8s-ansible-script && git submodule update --init --recursive
```
### Standard version
Edit variables in file `inventory/standard/group_vars/all` and `inventory/standard/inventory`.
Then install with following command.
```
make standard
```
### Agile version
Edit variables in file `inventory/agile/group_vars/all` and `inventory/agile/inventory`.
Then install with following command.
```
make agile
```

## Reserved NodePorts
### Elastic search
| Name | Ports|
| --- | --- |
| elasticsearch_nodeports_httpport | **_29400_**, **_29401_**, **_29402_**, |
| elasticsearch_nodeports_transport | **_29405_**, **_29406_**, **_29407_**, |
#### Hbase
| Name | Ports|
| --- | --- |
| hbase_nodeports_master_http | **_29410_**, **_29411_**, **_29412_**, |
#### HDFS
| Name | Ports|
| --- | --- |
| hadoop_hdfs_nodeports_nn_http_addr | **_29415_**, **_29416_** |
#### Kafka
| Name | Ports|
| --- | --- |
| kafka_nodeports_brokerport | **_29420_**, **_29421_**, **_29422_**, |
| kafka_nodeports_jmxport | **_29425_**, **_29426_**, **_29427_**, |
#### Opentsdb
| Name | Ports|
| --- | --- |
| opentsdb_nodeports_httpport | **_29430_**, **_29431_**, **_29432_**, |
| opentsdb_nodeports_jmxport | **_29435_**, **_29436_**, **_29437_**, |
#### Spark
| Name | Ports|
| --- | --- |
| spark_nodeports_master_ui | **_29440_**, **_29441_**, **_29442_**, |
| spark_nodeports_master_port | **_29445_**, **_29446_**, **_29447_**, |
| spark_nodeports_application_ui | **_29450_**, **_29451_**, **_29452_**, |
| spark_nodeports_rest_port | **_29455_**, **_29456_**, **_29457_**, |
| spark_nodeports_history_ui | **_29459_** |
#### zookeeper
| Name | Ports|
| --- | --- |
| zookeeper_nodeports_clientport | **_29460_**, **_29461_**, **_29462_**, |
| zookeeper_nodeports_adminserverport | **_29465_**, **_29466_**,**_29467_**,|
#### Kibana
| Name | Ports|
| --- | --- |
| kibana_nodeports_ui | **30561** |
#### Monitor-security
| Name | Ports|
| --- | --- |
| config_nodeports_ui | **30145** |
| gateway_nodeports_port | **30111** |
| gateway_nodeports_http | **30112** |

#### Console

Reserved node port from 29200 to 29299. Refer table bellow for node pod assignment.

| Service | NodePort |
| --- | --- |
| web-ui | 29000  |
| gateway-http | 29002 |
| gateway-https | 29001 |
| websocket-exec | 29003 |
| rabitmq-managor | 29299 |
| console-doc | 29004 |
| pmd | 29005 |


#### System-tools

| Service | Port |
| --- | --- |
| ldap | **30389**,**30636**,**31101** |
| ldap-ha | **31389**,**31636**,**31188** |
| harbor | **30100** |
| keystone | 29200, 29201 |
