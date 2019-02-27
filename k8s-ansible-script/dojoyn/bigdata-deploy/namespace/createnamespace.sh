#!/bin/bash
ENNCTL=`which ennctl`
JQ=`which jq`
JSONNET=`which jsonnet`
if [[ -z ${JSONNET} ]]; then
  echo "please install binary jsonnet"
  exit 1
fi
if [[ -z ${JQ} ]]; then
  echo "please install binary jq"
  exit 1
fi
if [[ -z ${ENNCTL} ]]; then
  echo "please install binary ennctl"
  exit 1
fi
nsfile=$(cd $(dirname $0); pwd)/namespace.jsonnet
ns=$(${JSONNET} ${nsfile} | ${JQ} -r '.metadata.name')
if [ $(${ENNCTL} get ns | grep ${ns} | wc -l) -ne 0 ]; then
  echo "namespace ${ns} is already exist..."
  exit 1
fi
${JSONNET} ${nsfile} > /tmp/ns.json
${ENNCTL} create namespace -f /tmp/ns.json
if [ -f /tmp/ns.json ]; then
  rm -f /tmp/ns.json
fi 
