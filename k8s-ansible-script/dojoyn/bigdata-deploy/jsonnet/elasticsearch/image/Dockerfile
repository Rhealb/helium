# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

FROM he2-centos7-jdk8:0.1

ENV ES_VERSION 6.1.0
ENV ES_NAME elasticsearch-$ES_VERSION 

RUN \
  cd /opt && \
  curl -L https://artifacts.elastic.co/downloads/elasticsearch/$ES_NAME.tar.gz -o $ES_NAME.tar.gz && \
  tar xvzf $ES_NAME.tar.gz && \
  rm -f $ES_NAME.tar.gz && \
  ln -s $ES_NAME elasticsearch

ENV ES_HOME /opt/elasticsearch
ENV ES_CONF_DIR /ES_HOME/config

WORKDIR /opt

ENTRYPOINT ["/opt/entrypoint.sh"]