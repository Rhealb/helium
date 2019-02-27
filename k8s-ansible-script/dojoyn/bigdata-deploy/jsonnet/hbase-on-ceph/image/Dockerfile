# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .
FROM 10.19.140.200:30100/tools/he2-centos7-jdk8:0.1

# HBASE
ENV HBASE_VERSION 1.2.6
ENV HBASE_PACKAGE hbase-$HBASE_VERSION-bin

RUN curl -L -C - http://www.apache.org/dist/hbase/$HBASE_VERSION/$HBASE_PACKAGE.tar.gz | \
         tar -zx -C /opt && \
    rm -rf $HBASE_HOME/docs && \
    cd /opt && \
    ln -s hbase-$HBASE_VERSION hbase

ENV HBASE_HOME /opt/hbase
ENV PATH $PATH:$HBASE_HOME/bin

# install hbase on ceph additional deps
ENV LOCAL_CEPH_DEP ceph_deps
COPY $LOCAL_CEPH_DEP/cephfs-hadoop-0.80.6.jar $HBASE_HOME/lib/cephfs-hadoop.jar
COPY $LOCAL_CEPH_DEP/libcephfs.jar $HBASE_HOME/lib/
COPY $LOCAL_CEPH_DEP/libceph-common.so.0 $LOCAL_CEPH_DEP/libcephfs.so.2.0.0 $LOCAL_CEPH_DEP/libcephfs_jni.so.1.0.0 /usr/lib64/
RUN cd /usr/lib64 && \
    ln -s libceph-common.so.0 libceph-common.so && \
    ln -s libcephfs_jni.so.1.0.0 libcephfs_jni.so.1 && \
    ln -s libcephfs_jni.so.1.0.0 libcephfs_jni.so && \
    ln -s libcephfs.so.2.0.0 libcephfs.so.2 && \
    ln -s libcephfs.so.2.0.0 libcephfs.so && \
    mkdir /usr/lib/jni && \
    ln -s /usr/lib64/libcephfs_jni.so.1.0.0 /usr/lib/jni/libcephfs_jni.so
RUN echo $'/usr/local/jdk-8u131/jre/lib/amd64/server\n/usr/local/jdk-8u131/jre/lib/amd64' > /etc/ld.so.conf.d/jdk.conf && ldconfig
COPY $LOCAL_CEPH_DEP/hbase-site.xml $HBASE_HOME/conf
COPY $LOCAL_CEPH_DEP/ceph.conf $LOCAL_CEPH_DEP/ceph.client.admin.keyring $HBASE_HOME/

# install hbase addons
ENV JAVA_LIBRARY_PATH $HBASE_HOME/lib/native

ENV LOCAL_HBASE_ADDON hbase_deps
COPY $LOCAL_HBASE_ADDON/lib.tar.gz /opt/lib.tar.gz
COPY $LOCAL_HBASE_ADDON/lzo.tar.gz /opt/lzo.tar.gz
COPY $LOCAL_HBASE_ADDON/hadoop-lzo.tar.gz /opt/hadoop-lzo.tar.gz
COPY $LOCAL_HBASE_ADDON/hadoop-snappy-target.tar.gz /opt/hadoop-snappy-target.tar.gz

RUN yum -y install lzo-devel lzo

RUN test -d $HBASE_HOME/lib/native || \
    mkdir -p $HBASE_HOME/lib/native

RUN tar -zxf /opt/lib.tar.gz -C $HBASE_HOME/lib/native && \
    rm -rf /opt/lib.tar.gz

RUN test -d /usr/local/hadoop || \
    mkdir -p /usr/local/hadoop && \
    tar -zxf /opt/lzo.tar.gz -C /usr/local/hadoop

RUN tar -zxf /opt/hadoop-lzo.tar.gz -C /opt && \
    cp /opt/hadoop-lzo-master/target/native/Linux-amd64-64/lib/* $HBASE_HOME/lib/native && \
    cp /opt/hadoop-lzo-master/target/hadoop-lzo-0.4.21-SNAPSHOT.jar $HBASE_HOME/lib

RUN tar -zxf /opt/hadoop-snappy-target.tar.gz -C /opt && \
    cp -f /opt/target/hadoop-snappy-0.0.1-SNAPSHOT/lib/native/Linux-amd64-64/lib* $HBASE_HOME/lib/native/ && \
    cp -f /opt/target/hadoop-snappy-0.0.1-SNAPSHOT/lib/hadoop-snappy-0.0.1-SNAPSHOT.jar $HBASE_HOME/lib

COPY create_table.sh /opt/


ENTRYPOINT ["/opt/entrypoint.sh"]
