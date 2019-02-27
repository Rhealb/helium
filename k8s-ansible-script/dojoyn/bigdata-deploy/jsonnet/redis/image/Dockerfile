# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

FROM quay.io/smile/redis:4.0.2 

RUN set -x && \
	echo "https://mirrors.aliyun.com/alpine/v3.6/main/" > /etc/apk/repositories && \
	echo "https://mirrors.aliyun.com/alpine/v3.6/community/" >> /etc/apk/repositories && \
	apk update && apk add ruby && apk add openjdk8 && (gem install redis || echo 0) && \
        mkdir /opt
ADD entrypoint.sh /opt
ADD entrypoint-0.2.0.jar /opt
ADD redis-trib.rb /usr/bin/redis-trib.rb
ADD redis-server /usr/bin/redis-server
ADD redis-cli /usr/bin/redis-cli
