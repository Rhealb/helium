# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .
FROM he2-centos7-jdk8:0.2

# HADOOP
ENV HADOOP_VERSION 2.7.4
RUN curl -L -C - http://www.eu.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-$HADOOP_VERSION.tar.gz | \
         tar -xz -C /opt && \
    cd /opt && \
    ln -s hadoop-$HADOOP_VERSION hadoop

ENV HADOOP_HOME /opt/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_HOME/etc/hadoop

WORKDIR /opt

CMD ["/opt/entrypoint.sh"]
