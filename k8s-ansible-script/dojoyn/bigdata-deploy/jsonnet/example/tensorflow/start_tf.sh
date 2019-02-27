#!/bin/bash

# Retrieve kubectl binary
KUBECTL_BIN=$(which kubectl)
JSONNET=$(which jsonnet)
ENNCTL=$(which ennctl)
if [[ -z "${KUBECTL_BIN}" ]]; then
  echo "please install kubectl binary"
  exit 0
fi
if [[ -z ${JSONNET} ]]; then
  echo "please install jsonnet binary"
  exit 0
fi
if [[ -z "${ENNCTL}" ]]; then
  echo "please install ennctl binary"
  exit 0
fi

tfdirpath=$(cd `dirname $0`; pwd)
globalfile="${tfdirpath}/../global_config.jsonnet"
deployfile="${tfdirpath}/tensorflow_example.jsonnet"
K8S_NAMESPACE=`$JSONNET global_config.jsonnet | jq -r '.namespace'`
JOB_NAME=`$JSONNET global_config.jsonnet | jq -r '.tensorflow.jobname'`
WORKER_NUM=`$JSONNET global_config.jsonnet | jq -r '.tensorflow.workernum'`
PS_NUM=`$JSONNET global_config.jsonnet | jq -r '.tensorflow.psnum'`
TIMEOUT=${1:-600}

echo "namespace is ${K8S_NAMESPACE}"
echo "tfjobname is ${JOB_NAME}"
echo "tfworkernum is ${WORKER_NUM}"
echo "tfpsnum is ${PS_NUM}"

die() {
  echo $@
  exit 1
}

function monitor {
  starttime=$(date +%s)
  while [[ true ]]; do
    sleep 5
    count=`${KUBECTL_BIN} -n ${K8S_NAMESPACE} get pod --show-all | grep ${JOB_NAME} | grep tfworker | awk '{print $3}' | grep Complete | wc -l`
    nocom_num=$((${WORKER_NUM}-${count}))
    echo "${nocom_num} tfworker were not complete"
    if [ "${nocom_num}" -eq 0 ]; then
        echo "all tfworker completed!"
        break
    fi
    endtime=$(date +%s)
    if [ $((${endtime}-${starttime})) -ge ${TIMEOUT} ]; then
        echo "timeout"
        break
    fi
  done
}

sed -i "s/deploytype: \"podservice\",/deploytype: \"storage\",/g" ${globalfile}
$JSONNET ${deployfile} > /tmp/tfstorage.json
sed -i "s/deploytype: \"storage\",/deploytype: \"podservice\",/g" ${globalfile}
$JSONNET ${deployfile} > /tmp/tfpodservice.json

#creat tensorflow cluster
echo "create TF cluster"
#${ENNCTL} create -f /tmp/tfstorage.json
${KUBECTL_BIN} create -f /tmp/tfpodservice.json

#monitor
monitor

# delete tensorflow cluster
echo "delete tensorflow cluster by jsonnet file"
${KUBECTL_BIN} delete -f /tmp/tfpodservice.json
#${ENNCTL} delete -f /tmp/tfstorage.json

if [ -f /tmp/tfpodservice.json ]; then
  rm -f /tmp/tfpodservice.json
fi
if [ -f /tmp/tfstorage.json ]; then
  rm -f /tmp/tfstorage.json
fi
