#!/bin/bash
ENNCTL=`which ennctl`
JSONNET=`which jsonnet`
JQ=`which jq`
if [[ -z ${JQ} ]]; then
  echo "please install binary jq"
  exit 1
fi
if [[ -z ${ENNCTL} ]]; then
  echo "please install binary ennctl"
  exit 1
fi
if [[ -z ${JSONNET} ]]; then
  echo "please install binary jsonnet"
  exit 1
fi

display_help() {
    echo
    echo "Usage: $0 create [option...] {component_example.jsonnet}"
    echo "       $0 delete [option...] {component_example.jsonnet}"
    echo
    echo "   -p, --podcontainer  start component with a pod, which is mount fs storage, by use 'ennctl cp' copy local utils to fs"
    echo "   -c, --configmap     start component with configmap"
    echo "   -m, --mountfs       start component by use mount file system, mount file system to local, cp utils to fs, due to use mount command, should have root privileges"
    echo "   -h, --help          display command help info"
    echo
    echo "Example:"
    echo
    echo "       ./bigctl.sh create zookeeper_example.jsonnet <=> ./bigctl.sh create -p zookeeper_example.jsonnet"
    echo "       ./bigctl.sh create -c zookeeper_example.jsonnet"
    echo "       sudo ./bigctl.sh create -m zookeeper_example.jsonnet"
    echo "       ./bigctl.sh delete -c zookeeper_example.jsonnet"
    echo "       ./bigctl.sh delete zookeeper_example.jsonnet  <=>  ./bigctl.sh delete -p zookeeper_example.jsonnet  <=> ./bigctl.sh -m delete zookeeper_example.jsonnet"
    echo
}
if [[ $# -lt 2 ]]; then
  display_help
  exit 1
fi
if [ $1 == "create" ] || [ $1 == "delete" ]; then
  createOrdelete=$1
  shift
else
  echo "Error: The first paramter spell Error(create or delete)"
  display_help
  exit 1
fi
utilsstoretype=""
while [[ true ]]; do
  case "$1" in
    -h | --help)
        display_help  # Call help display function
        exit 0
        ;;
    -p | --podcontainer)
        if [[ $utilsstoretype == "mountfs" ]]||[[ $utilsstoretype == "configmap" ]]; then
          echo "Error: [-p] [-m] [-c] cannot be used at the same time"
          display_help
          exit 1
        fi
        utilsstoretype="podcontainer"
        shift
        ;;
    -m | --mountfs)
        if [[ ${utilsstoretype} == "podcontainer" ]]||[[ ${utilsstoretype} == "configmap" ]]; then
          echo "Error: [-p] [-m] [-c] cannot be used at the same time"
          display_help
          exit 1
        fi
        utilsstoretype="mountfs"
        shift
        ;;
    -c | --configmap)
        if [[ ${utilsstoretype} = "podcontainer" ]]||[[ ${utilsstoretype} = "mountfs" ]]; then
          echo "Error: [-p] [-m] [-c] cannot be used at the same time"
          display_help
          exit 1
        fi
        utilsstoretype="configmap"
        shift
        ;;
    -*)
        echo "Error: Unknown option: $1"
        display_help
        exit 1
        ;;
    *)
        break
        ;;
  esac
done
if [[ ${utilsstoretype} == "" ]]; then
  utilsstoretype="podcontainer"
fi
if [[ $1 == "" ]]; then
  display_help
  exit 1
fi
if [ -f $1 ]; then
  deploy_file=$1
else
  echo "file $1 is not exist......"
  exit 1
fi

# if the deploy file is druid,mysql or tranquility,the globalconfigpath must be the parent directory
if [ $(echo "${deploy_file}" | grep -E "druid_|tranquility_|plyql_" | wc -l) != 0 ]; then
  globalconfigpath=$(dirname ${deploy_file})/../
else
  globalconfigpath=$(dirname ${deploy_file})
fi

src_conf_path=${globalconfigpath}/../../cephutils
utilspath=$(cd ${src_conf_path}; pwd)
global_config=${globalconfigpath}/global_config.jsonnet
depoly_file_name=$(basename ${deploy_file})
namespace=$(${JSONNET} ${global_config} | ${JQ} -r '.namespace')
location=$(${JSONNET} ${global_config} | ${JQ} -r '.location')
mountdevtype=$(${JSONNET} ${global_config} | ${JQ} -r '.mountdevtype')
cephaddress=$(${JSONNET} ${global_config} | ${JQ} -r '.cephaddress')
nfsaddress=$(${JSONNET} ${global_config} | ${JQ} -r '.nfsaddress')
suiteprefix=$(${JSONNET} ${global_config} | ${JQ} -r '.suiteprefix')
registry=$(${JSONNET} ${global_config} | ${JQ} -r '.registry')
appname=${suiteprefix}-$(basename $deploy_file | awk -F "." '{print $1}' | awk -F "_" '{print $1}')

if [[ ${utilsstoretype} == "configmap" ]]; then
  if [[ $(${JSONNET} ${global_config} | jq -r '.utilsstoretype') = "FS" ]]; then
    sed -i "s/utilsstoretype: \"FS\",/utilsstoretype: \"ConfigMap\",/g" ${global_config}
  fi
else
  if [[ $(${JSONNET} ${global_config} | jq -r '.utilsstoretype') = "ConfigMap" ]]; then
    sed -i "s/utilsstoretype: \"ConfigMap\",/utilsstoretype: \"FS\",/g" ${global_config}
  fi
fi
sed -i "s/deploytype: \"podservice\",/deploytype: \"storage\",/g" ${global_config}
$JSONNET ${deploy_file} > /tmp/${appname}storage.json
sed -i "s/deploytype: \"storage\",/deploytype: \"podservice\",/g" ${global_config}
$JSONNET ${deploy_file} > /tmp/${appname}podservice.json

if [[ ${utilsstoretype} == "configmap" ]]; then
  cm=$(cat /tmp/${appname}podservice.json | jq -r '.items[]|select((.kind == "Deployment") or (.kind == "StatefulSet"))|.spec.template.spec.volumes[0].configMap.name' | sed -n "1p")
  local_utils=$(echo "$cm" | awk -F "-" '{print $(NF-1)}')
  utilsdir=${suiteprefix}"-"${local_utils}
else
  utilsdir=$(cat /tmp/${appname}storage.json | jq -r '.items[] | .metadata.name' | grep "utils")
  local_utils=$(echo $utilsdir | awk -F '-' '{print $NF}')
fi

# create storage and podservice
if [ $createOrdelete = "create" ]; then
  #create storage
  $ENNCTL create -f /tmp/${appname}storage.json

  # copy local cephutils config and entrypoint to cephfs
  if [[ ${utilsstoretype} == "podcontainer" ]]; then
    cp ${globalconfigpath}/podexample/cpcephutilspod.json /tmp/cpcephutilspod.json
    sed -i -e "s/%NAMESPACE%/${namespace}/g" -e "s/%COMPONENTCEPHUTILS%/${utilsdir}/g" -e "s/%NAME%/${utilsdir}/g" -e "s/%REGISTRY%/${registry}/g" /tmp/cpcephutilspod.json
    cppodname=$(cat /tmp/cpcephutilspod.json | ${JQ} -r .metadata.name)
    if [ $(${ENNCTL} -n ${namespace} get pod | awk '{print $1}' | grep -E "(^)${cppodname}($)" | wc -l) != 0 ]; then
      echo "pod ${cppodname} already exist, delete first"
      ${ENNCTL} -n ${namespace} delete pod ${cppodname}
      rmpodtime=0
      while [[ true ]]; do
        sleep 2
        if [[ $(${ENNCTL} -n ${namespace} get pod | awk '{print $1}' | grep -E "(^)${cppodname}($)" | wc -l) = 0 ]]; then
          break
        fi
        ((rmpodtime+=2))
        if [ $((rmpodtime % 120)) = 0 ]; then
          echo "Warning: pod ${cppodname} can not be deleted, if you want to stop bigctl.sh, please ctrl + c"
        fi
      done
    fi
    $ENNCTL create -f /tmp/cpcephutilspod.json
    while [[ true ]]; do
      sleep 2
      if [[ $(${ENNCTL} -n ${namespace} get pod | grep -w ${cppodname} | awk '{print $3}') == "Running" ]]; then
        break;
      fi
    done
    $ENNCTL -n ${namespace} cp $src_conf_path/${local_utils} bigdata-${utilsdir}:/opt/mntcephutils
    podname=$(cat /tmp/cpcephutilspod.json | jq -r '.metadata.name')
    if [[ $(${ENNCTL} -n ${namespace} exec ${podname} ls /opt/mntcephutils | wc -l) -eq 0  ]]; then
      echo "copy utils failed"
      exit 1
    fi
    $ENNCTL delete -f /tmp/cpcephutilspod.json
    rm -rf /tmp/cpcephutilspod.json

  elif [[ ${utilsstoretype} == "mountfs" ]]; then
    if [ ! -d /mnt/${location} ]; then
        mkdir -p /mnt/${location}
    fi
    if [ ${mountdevtype} = "CephFS" ]; then
      ceph_username=${namespace}
      ceph_secret=$($ENNCTL -n ${namespace} get secret ${namespace} -o json | jq -r '.data.key' | base64 -d)
      /bin/mount -t ceph ${cephaddress}:/k8s/${namespace} /mnt/${location} -o name=${ceph_username},secret=${ceph_secret}
    elif [ ${mountdevtype} = "EFS" ] || [ ${mountdevtype} = "NFS" ] ; then
      /bin/mount -t nfs ${nfsaddress}:/k8s/${namespace} /mnt/${location}
    else
      echo "Unkown mountdevtype ${mountdevtype}"
      exit 1
    fi
    if [[ ! -d /mnt/${location}/${utilsdir} ]]; then
      echo "Error: /mnt/${location}/${utilsdir} is not exist"
      echo "Error: May be mount cephfs failed, the current user is $(whoami)"
      exit 1
    fi
    cp -rf $src_conf_path/${local_utils}/* /mnt/${location}/${utilsdir}
    # umount ceph path
    /bin/umount -l /mnt/${location}

  elif [[ ${utilsstoretype} == "configmap" ]]; then
    for absoluteutilsdir in $(find ${utilspath}/${local_utils}/* -type d); do
      if [[ $(ls -F ${absoluteutilsdir} | grep '/$' | wc -l) -ne $(ls ${absoluteutilsdir} | wc -l) ]] || [[ $(ls ${absoluteutilsdir} | wc -l) -eq 0 ]]; then
        suffix=$(echo ${absoluteutilsdir} | sed "s|${utilspath}/${local_utils}||g" | sed 's|/||g' | tr 'A-Z' 'a-z' | sed 's/_//g')
        ${ENNCTL} -n ${namespace} create configmap ${utilsdir}-${suffix} --from-file=${absoluteutilsdir}
      fi
    done
  fi

  #create podservice
  if [[ $($ENNCTL -n $namespace get app | awk '{print $1}' | grep -E  "(^)$appname($)" | wc -l) = 0 ]]; then
    $ENNCTL -n $namespace create app $appname
  fi
  $ENNCTL create -f /tmp/${appname}podservice.json -a $appname

elif [ ${createOrdelete} = "delete" ]; then
  # delete podservice
  $ENNCTL delete -f /tmp/${appname}podservice.json

  #check pod whether already deleted
  cat /tmp/${appname}podservice.json | jq -r '.items[] | select((.kind == "Deployment") or (.kind == "StatefulSet")) | .metadata.name' > /tmp/${appname}depnamelist
  lines=$(cat /tmp/${appname}depnamelist | wc -l)
  TIMEOUT=120
  starttime=$(date +%s)
  while [ true ] ; do
    podcount=0
    sleep 1
    for (( i=1; i<=${lines}; i++)); do
      ((podcount+=$($ENNCTL -n $namespace get pod | grep $(cat /tmp/${appname}depnamelist | sed -n "${i}p") | wc -l)))
    done
    if [ $podcount -eq 0 ]; then
      echo "pod already deleted......."
      break
    fi
    endtime=$(date +%s)
    if [ $((${endtime}-${starttime})) -ge ${TIMEOUT} ]; then
        echo "delete pod timeout......."
        echo "Forced to delete pod...... "
        for (( i=1; i<=${lines}; i++)); do
          $ENNCTL -n $namespace get pod | grep $(cat /tmp/${appname}depnamelist | sed -n "${i}p") | awk '{print $1}' | xargs -I {} $ENNCTL -n $namespace delete pod {} --grace-period=0 --force=true
        done
        echo "pod forced to be deleted......."
        break
    fi
  done

  # delete app if there is no pod in this app
  if [ $($ENNCTL -n $namespace get pod -a $appname | awk '{print $3}' | grep -c Running) -eq 0 ]; then
    $ENNCTL -n $namespace delete app $appname
  fi

  #delete storage
  $ENNCTL delete -f /tmp/${appname}storage.json

  # delete configmap if there is no pod in this app
  if [ $($ENNCTL -n $namespace get pod -a $appname | awk '{print $3}' | grep -c Running) -eq 0 ]; then
    if [[ ${utilsstoretype} == "configmap" ]]; then
      for absoluteutilsdir in $(find ${utilspath}/${local_utils}/* -type d); do
        if [[ $(ls -F ${absoluteutilsdir} | grep '/$' | wc -l) -ne $(ls ${absoluteutilsdir} | wc -l) ]] || [[ $(ls ${absoluteutilsdir} | wc -l) -eq 0 ]]; then
          suffix=$(echo ${absoluteutilsdir} | sed "s|${utilspath}/${local_utils}||g" | sed 's|/||g' | tr 'A-Z' 'a-z' | sed 's/_//g')
          ${ENNCTL} -n ${namespace} delete configmap ${utilsdir}-${suffix}
        fi
      done
    fi
  fi
fi
if [ -f /tmp/${appname}podservice.json ]; then
  rm -f /tmp/${appname}podservice.json
fi
if [ -f /tmp/${appname}storage.json ]; then
  rm -f /tmp/${appname}storage.json
fi
if [ -f /tmp/${appname}depnamelist ]; then
  rm -f /tmp/${appname}depnamelist
fi
