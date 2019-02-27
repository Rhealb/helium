FROM he2-centos7-jdk8:0.1

ENV OPENTSDB_VERSION 2.3.0

RUN yum -y install gnuplot

RUN curl -o /opt/opentsdb-${OPENTSDB_VERSION}.rpm -L -C - https://github.com/OpenTSDB/opentsdb/releases/download/v${OPENTSDB_VERSION}/opentsdb-${OPENTSDB_VERSION}.rpm && \
	 rpm -ivh /opt/opentsdb-${OPENTSDB_VERSION}.rpm && \
	 rm /opt/opentsdb-${OPENTSDB_VERSION}.rpm

ENV PATH $PATH:/usr/share/opentsdb/bin

ENTRYPOINT ["/opt/entrypoint.sh"]
