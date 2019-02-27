#!/bin/bash

# Copyright 2018 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Generates the a CA cert, a server key, and a server cert signed by the CA.
# reference:
# https://github.com/kubernetes/kubernetes/blob/master/plugin/pkg/admission/webhook/gencerts.sh
set -e
createSecret=$1
certCN=$2
CN_BASE="enndata_scheduler"
TMP_DIR="/tmp/enndata-scheduler-certs"
NAMESPACE="k8splugin"
BASIC_AUTH="zhtsC1002,zhtsC1002,1"

echo "Generating certs for the NSHP Admission Controller in ${TMP_DIR}."
mkdir -p ${TMP_DIR}
cat > ${TMP_DIR}/server.conf << EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
EOF

# Create a certificate authority
openssl genrsa -out ${TMP_DIR}/caKey.pem 2048
openssl req -x509 -new -nodes -key ${TMP_DIR}/caKey.pem -days 100000 -out ${TMP_DIR}/caCert.pem -subj "/CN=${CN_BASE}_ca"

# Create a server certiticate
openssl genrsa -out ${TMP_DIR}/serverKey.pem 2048
# Note the CN is the DNS name of the service of the webhook.
if [ "$certCN" == "" ]; then
    certCN=enndata-scheduler-svc.${NAMESPACE}.svc
fi 
openssl req -new -key ${TMP_DIR}/serverKey.pem -out ${TMP_DIR}/server.csr -subj "/CN=${certCN}" -config ${TMP_DIR}/server.conf
openssl x509 -req -in ${TMP_DIR}/server.csr -CA ${TMP_DIR}/caCert.pem -CAkey ${TMP_DIR}/caKey.pem -CAcreateserial -out ${TMP_DIR}/serverCert.pem -days 100000 -extensions v3_req -extfile ${TMP_DIR}/server.conf
echo $BASIC_AUTH > ${TMP_DIR}/basicAuth 
echo "Uploading certs to the cluster."
if [ "`kubectl get ns ${NAMESPACE} 2>&1| grep -E "^${NAMESPACE}"`" == "" ]; then
   echo "create ns " ${NAMESPACE}
   kubectl create ns ${NAMESPACE}
   kubectl annotate ns ${NAMESPACE} io.enndata.namespace/alpha-allowhostpath=true
   kubectl annotate ns ${NAMESPACE} io.enndata.namespace/alpha-allowprivilege=true
else
   echo "namespace ${NAMESPACE} is exist"
fi

if [ "`kubectl -n ${NAMESPACE} get secret enndata-scheduler-tls-certs 2>&1 | grep -E "^enndata-scheduler-tls-certs"`" != "" ]; then
    echo "secret  enndata-scheduler-tls-certs is exist, start delete it"
    kubectl delete secret enndata-scheduler-tls-certs --namespace=${NAMESPACE}
fi

if [ "$createSecret" == "false" ]; then
   cp -r ${TMP_DIR} ./tls-certs
   rm ./tls-certs/server.conf
else
   kubectl create secret --namespace=${NAMESPACE} generic enndata-scheduler-tls-certs --from-file=${TMP_DIR}/caKey.pem --from-file=${TMP_DIR}/caCert.pem --from-file=${TMP_DIR}/serverKey.pem --from-file=${TMP_DIR}/serverCert.pem --from-file=${TMP_DIR}/basicAuth
fi

# Clean up after we're done.
echo "Deleting ${TMP_DIR}."
rm -rf ${TMP_DIR}
