# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

FROM he2-centos7-jdk8:0.1
RUN mkdir /opt/ping 
COPY ping.tar.gz /opt/ping/
RUN cd /opt/ping && tar zxf ping.tar.gz && rm ping.tar.gz
ENTRYPOINT /opt/entrypoint.sh
