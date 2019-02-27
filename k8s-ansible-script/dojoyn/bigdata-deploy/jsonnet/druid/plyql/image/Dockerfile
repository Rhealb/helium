# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

FROM he2-centos7-jdk8:0.1
ENV PLYQL_VERSION 0.11.2
WORKDIR /opt

# To enable the EPEL repository and  add the Node.js v6 LTS repository
RUN yum install -y epel-release && curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -

# proceed with the Node.js v6 LTS and npm installation
RUN yum -y install nodejs

RUN curl -L -C - "https://github.com/implydata/plyql/archive/v${PLYQL_VERSION}.tar.gz" | \
    tar -xz -C /opt && \
    ln -s /opt/plyql-${PLYQL_VERSION} /opt/plyql && \
    cd /opt/plyql && \
    npm install && sed -i 's/"noImplicitAny": true/"noImplicitAny": false/g' tsconfig.json && \
    npm run compile 
