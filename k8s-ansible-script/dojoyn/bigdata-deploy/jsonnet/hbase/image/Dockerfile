# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .
FROM he2-centos7-jdk8:0.1

# HBASE
ENV HBASE_VERSION 1.2.6
ENV HBASE_PACKAGE hbase-$HBASE_VERSION-bin

RUN curl -L -C - http://www.apache.org/dist/hbase/$HBASE_VERSION/$HBASE_PACKAGE.tar.gz | \
         tar -zx -C /opt  && \
    cd /opt && \
    ln -s hbase-$HBASE_VERSION hbase

ENV HBASE_HOME /opt/hbase
ENV PATH $PATH:$HBASE_HOME/bin

ENTRYPOINT ["/opt/entrypoint.sh"]
