# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

FROM he2-centos7-jdk8:0.1

# KAFKA
ENV KAFKA_VERSION 0.10.1.1
ENV SCALA_VERSION 2.11
ENV KAFKA_PACKAGE=kafka_${SCALA_VERSION}-${KAFKA_VERSION}

# Download Apache Kafka, untar and clean up
RUN set -x && \
    curl -L -C - "http://www.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_PACKAGE}.tgz" | \
         tar -xz -C /opt && \
    cd /opt && \
    ln -s $KAFKA_PACKAGE kafka

ENV KAFKA_HOME /opt/kafka
ENV PATH $PATH:${KAFKA_HOME}/bin
ENV KAFKA_CONF_DIR $KAFKA_HOME/config

WORKDIR /opt

ENTRYPOINT ["tail", "-f", "/var/log/lastlog"]
