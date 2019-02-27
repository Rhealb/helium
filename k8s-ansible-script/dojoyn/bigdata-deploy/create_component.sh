#!/bin/bash
set -e
JSONNET=`which jsonnet`
if [[ -z ${JSONNET} ]]; then
  echo "Error: jsonnet binary not exist, please install first"
  exit 0
fi
componentname=$1
if [[ -z ${componentname} ]]; then
  echo "Error:please input component name"
  exit 0
fi
workdir=$(cd `dirname $0` && pwd)
portslines=$(${JSONNET} ${workdir}/template/portconfig.jsonnet | jq -r ".ports|length")
exportsnamelines=$(${JSONNET} ${workdir}/template/portconfig.jsonnet | jq -r ".exportsname|length")
for (( i = 0; i < ${exportsnamelines}; i++ )); do
   exportname=$(${JSONNET} ${workdir}/template/portconfig.jsonnet | jq -r ".exportsname[$i]")
   targetport=$(${JSONNET} ${workdir}/template/portconfig.jsonnet | jq -r ".ports" | grep ${exportname} | awk -F ":" '{print $2}' | sed -e 's/\"//g' -e 's/,//g' -e 's/ //g')
   localexportstemplate=${localexportstemplate}"local external${exportname}s = $._${componentname}externalports.${exportname}s,\n  "
   localnodeportstemplate=${localnodeportstemplate}"local node${exportname}s = $._${componentname}nodeports.${exportname}s,\n  "
   exportstemplate=${exportstemplate}"\"${exportname}\" + utils.addcolonforport(external${exportname}s[num - 1]) + \":${targetport}\",\n        "
   nodeportstemplate=${nodeportstemplate}"\"${exportname}\" + utils.addcolonforport(node${exportname}s[num - 1]) + \":${targetport}\",\n        "
   globalexportstemplate=${globalexportstemplate}${exportname}"s:[${targetport} + i for i in std.range(0,$.${componentname}.instancecount - 1)],\n      "
   globalnodeportstemplate=${globalnodeportstemplate}${exportname}"s:[\"\" for count in std.range(1, $.${componentname}.instancecount)],\n      "
done
for (( i = 0; i < ${portslines}; i++ )); do
  serviceport=$(${JSONNET} ${workdir}/template/portconfig.jsonnet | jq ".ports[$i]")
  serviceportstemplate=${serviceportstemplate}${serviceport}",\n    "
done
function replaceVariable {
  sed -i "s/%NAME%/${componentname}/g" ${workdir}/jsonnet/${componentname}/${componentname}.jsonnet
  sed -i "s/%NAME%/${componentname}/g" ${workdir}/jsonnet/${componentname}/${componentname}service.jsonnet
  sed -i "s/%NAME%/${componentname}/g" ${workdir}/jsonnet/${componentname}/deploy/${componentname}podservice_deploy.jsonnet
  sed -i "s/%SERVICEPORTS%/${serviceportstemplate}/g" ${workdir}/jsonnet/${componentname}/${componentname}service.jsonnet
  sed -i "s/%LOCALEXPORTSTEMPLATE%/${localexportstemplate}/g" ${workdir}/jsonnet/${componentname}/deploy/${componentname}podservice_deploy.jsonnet
  sed -i "s/%LOCALNODEPORTSTEMPLATE%/${localnodeportstemplate}/g" ${workdir}/jsonnet/${componentname}/deploy/${componentname}podservice_deploy.jsonnet
  sed -i "s/%EXPORTSTEMPLATE%/${exportstemplate}/g" ${workdir}/jsonnet/${componentname}/deploy/${componentname}podservice_deploy.jsonnet
  sed -i "s/%NODEPORTSTEMPLATE%/${nodeportstemplate}/g" ${workdir}/jsonnet/${componentname}/deploy/${componentname}podservice_deploy.jsonnet
  sed -i "s/%NAME%/${componentname}/g" ${workdir}/jsonnet/${componentname}/deploy/${componentname}storage_deploy.jsonnet
  sed -i "s/%NAME%/${componentname}/g" ${workdir}/jsonnet/example/${componentname}_example.jsonnet
}

if [[ -d ${workdir}/cephutils ]]; then
  if [[ -d ${workdir}/cephutils/${componentname}"utils" ]]; then
    echo "${workdir}/cephutils/${componentname}utils already exist, please delete first..."
    exit 0
  fi
  mkdir ${workdir}/cephutils/${componentname}"utils"
  mkdir ${workdir}/cephutils/${componentname}"utils"/conf
  mkdir ${workdir}/cephutils/${componentname}"utils"/entry
  mkdir ${workdir}/cephutils/${componentname}"utils"/scripts
  touch ${workdir}/cephutils/${componentname}"utils"/entry/entrypoint.sh
fi

if [[ -d ${workdir}/jsonnet ]]; then
  if [[ -d ${workdir}/jsonnet/${componentname} ]]; then
    echo "${workdir}/jsonnet/${componentname} already exist, please delete first..."
    rm -rf ${workdir}/cephutils/${componentname}"utils"
    exit 0
  fi
  mkdir ${workdir}/jsonnet/${componentname}
  mkdir ${workdir}/jsonnet/${componentname}/deploy
  mkdir ${workdir}/jsonnet/${componentname}/image
  touch ${workdir}/jsonnet/${componentname}/image/Dockerfile
  touch ${workdir}/jsonnet/${componentname}/image/entrypoint.sh
  cp ${workdir}/template/deployment.jsonnet  ${workdir}/jsonnet/${componentname}/${componentname}.jsonnet
  cp ${workdir}/template/service.jsonnet  ${workdir}/jsonnet/${componentname}/${componentname}service.jsonnet
  cp ${workdir}/template/podservice_deploy.jsonnet ${workdir}/jsonnet/${componentname}/deploy/${componentname}podservice_deploy.jsonnet
  cp ${workdir}/template/storage_deploy.jsonnet ${workdir}/jsonnet/${componentname}/deploy/${componentname}storage_deploy.jsonnet
  cp ${workdir}/template/example.jsonnet ${workdir}/jsonnet/example/${componentname}_example.jsonnet
fi
replaceVariable
if [[ $(${JSONNET} ${workdir}/jsonnet/example/global_config.jsonnet | jq -r ".${componentname}") == "null" ]]; then
  line=`cat ${workdir}/jsonnet/example/global_config.jsonnet | wc -l`
  sed -i "${line}i\ \n  ${componentname}: { \n \
   image: $.registry + \"/component-image-to-be-defined:version\", \n \
   exservicetype: $.exservicetype, \n \
   instancecount: 1, \n \
   replicas: 1, \n \
   requestcpu: \"0\", \n \
   requestmem: \"0\", \n \
   limitcpu: \"0\", \n \
   limitmem: \"0\", \n \
   externalports: { \n \
     ${globalexportstemplate} \n \
   }, \n \
   nodeports: { \n \
     ${globalnodeportstemplate} \n \
   }, \n \
  }," ${workdir}/jsonnet/example/global_config.jsonnet
else
  echo "Error:${componentname} config is already in globalfile..."
  rm -rf ${workdir}/jsonnet/${componentname}
  rm -rf ${workdir}/cephutils/${componentname}"utils"
  exit 0
fi
echo "create ${componentname} jsonnet code successful..."
