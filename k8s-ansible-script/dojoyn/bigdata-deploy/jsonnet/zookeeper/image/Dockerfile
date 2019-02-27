# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

FROM he2-centos7-jdk8:0.1

# ZOOKEEPER
ENV ZK_DATA_DIR=/data \
    ZK_DATA_LOG_DIR=/datalog \
    ZK_PORT=2181 \
    ZK_TICK_TIME=2000 \
    ZK_INIT_LIMIT=5 \
    ZK_SYNC_LIMIT=2 \
    DISTRO_NAME=zookeeper-3.5.3

# Download Apache Zookeeper, untar and clean up
RUN set -x && \
    curl -L -C - "http://www.apache.org/dist/zookeeper/$DISTRO_NAME/$DISTRO_NAME.tar.gz" | \
         tar -x -C /opt && \
    cd /opt && \
    ln -s $DISTRO_NAME zookeeper

VOLUME ["$ZK_DATA_DIR", "$ZK_DATA_LOG_DIR"]

ENV ZOOKEEPER_HOME /opt/zookeeper
ENV PATH $PATH:$ZOOKEEPER_HOME/bin
ENV ZOOKEEPER_CONF_DIR $ZOOKEEPER_HOME/conf

WORKDIR /opt

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]
