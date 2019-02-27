FROM openjdk:8-jre-alpine

WORKDIR /opt

RUN apk update && \
  apk add --update alpine-sdk && \
  apk add vim gcc git libffi-dev musl-dev openssl-dev perl py-pip python python-dev sshpass openssh&& \
  pip install --upgrade pip &&\
  pip install ansible  

RUN ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -P ""
RUN curl -s -L -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 && \
curl -s -L -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 && \
chmod +x /usr/local/bin/cfssl && \
chmod +x /usr/local/bin/cfssljson
RUN apk add --no-cache rsync bash


ENTRYPOINT ["/usr/bin/tail", "-f", "/dev/null"]
