# helium1.5敏捷版安装

本文档是给实施人员或者用户的系统安装人员提供新智认知新氦云平台敏捷版的私有云安装和配置指导，帮助实施人员或用户能够快速安装配置敏捷版云平台。可选择安装三台及以上机器数的集群，或一台机器的单机版集群。

## 1.安装准备

### 1.1 安装机要求

安装机器用来放置安装介质和启动ansible容器，可以是集群机中的一台，也可以是与集群机在同一网段的另一台机器。

### 1.2 集群机要求

以下是装三台以上的机器的集群的要求。

|     硬件      |                  |         |
| :-----------: | :--------------: | :-----: |
|               |  CPU（总核数）   |   ≥6    |
|               |   内存（总数）   |  ≥ 20G  |
| 存储（/单机） | 系统盘（根目录） | ≥100GB  |
|               |    数据盘1块     | ≥ 500GB |

  

|     软件     |                    |
| :----------: | :----------------: |
|   操作系统   |     CentOS7.4      |
| 操作系统内核 | = kernel3.10.0-693 |

### 1.3 下载安装镜像

docker pull enndata/helium:1.5

### 1.4 配置inventory

安装三台以上机器的集群配置inventory时参照inventory.yml，安装单机版集群参照k8s-cluster/clusters/minicluster/centos-cluster.yml

## 2.安装步骤

### 2.1安装集群

1.在安装机开启一个docker，端口2375，用以跑安装镜像

bash no-boardmachine-ansible-docker.sh start

2.将配置好的inventory file挂载到/opt/k8s-ansible-script/inventory/，等待容器运行完成。

docker -H 127.0.0.1:2375 run -it --privileged -v $PWD/inventory.yml:/opt/k8s-ansible-script/inventory.yml  enndata/helium:1.5  sh

## 3.代码

https://github.com/Rhealb/k8s-plugins

https://github.com/Rhealb/console