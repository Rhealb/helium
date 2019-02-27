# How to build an docker image enabling hbase on ceph
There are two major dependencies essential to build an image of hbase on ceph.
* The first part is making cephfs integrated with hbase.  Document at [Google Drive: hbase on cephfs](https://docs.google.com/document/d/1AvCoVFU-VZk_qzhrZcqe8G07W5D78--4AWih6-ZuJXs/edit)
* The second part is compression modules we built for hbase. Document at [Google Drive: hbase compression]( https://docs.google.com/document/d/1ROMb1XQ-dbl535z9c_b5duUW27BQyCfxdBrc--4uuds/edit)

## Enabling cephfs
According to manual build reference mentioned above, ultimately, we get 3 so, 2 jar and 2 config files.  Copy these files to subfolder named **ceph_deps** because they are hardcoded in Dockerfile
* libceph-common.so.0
* libcephfs.so.2.0.0
* libcephfs_jni.so.1.0.0
* libcephfs.jar
* cephfs-hadoop-0.80.6.jar
* ceph.conf
* ceph.client.admin.keyring

## Hbase compression modules
According to manual build reference mentioned above, we get 4 tar.gz files.  Copy these files to subfolder named **hbase_deps**
* lib.tar.gz
* lzo.tar.gz
* hadoop-lzo.tar.gz
* hadoop-snappy-target.tar.gz

## Build Dockerfile
You have to have access to corporate private image repo to retrieve base image and also push the image to be built
1. docker login 10.19.140.200:30100
1. docker build -f Dockerfile -t hbaseonceph:1 .
1. docker tag hbaseonceph:1 10.19.140.200:30100/tools/he2-centos7-hbase-on-ceph:newrev
1. docker push 10.19.140.200:30100/tools/he2-centos7-hbase-on-ceph:newrev
1. Manually create hbase tables after running the container.  Exec into the container and run script /opt/create_table.sh
