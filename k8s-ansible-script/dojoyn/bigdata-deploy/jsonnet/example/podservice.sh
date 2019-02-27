#!/bin/bash
if [ $1 == "start" ] || [ $1 == "stop" ]; then
  startOrstop=$1
else
  echo "Error: The first paramter spell Error(start or stop)!"
  exit 0
fi
if [ $startOrstop == "start" ]; then
  createOrdelete="create"
elif [  $startOrstop == "stop" ]; then
  createOrdelete="delete"
fi
ENNCTL=`which ennctl`
JSONNET=`which jsonnet`
JQ=`which jq`
if [ ${JQ} == "" ]; then
  echo "jq binary not exist, please intall jq first"
  exit 0
fi
if [ ${ENNCTL} == "" ]; then
  echo "ennctl binary not exist, please intall ennctl first"
  exit 0
fi
if [ ${JSONNET} == "" ]; then
  echo "jsonnet binary not exist, please intall jsonnet first"
  exit 0
fi

if [ -f $2 ]; then
  deploy_file=$2
else
  echo "$2 is not a file"
  exit 0
fi

# if the deploy file is druid,mysql or tranquility,the globalconfigpath must be the parent directory
if [ $(echo "$deploy_file" | grep -E "druid_|tranquility_|plyql_" | wc -l) != 0 ]; then
  globalconfigpath=$(dirname $deploy_file)/../
else
  globalconfigpath=$(dirname $deploy_file)
fi
global_config=$globalconfigpath/global_config.jsonnet
sed -i "s/deploytype: \"storage\",/deploytype: \"podservice\",/g" $global_config
suiteprefix=$(${JSONNET} ${global_config} | jq -r '.suiteprefix')
appname=${suiteprefix}-$(basename $deploy_file | awk -F "." '{print $1}' | awk -F "_" '{print $1}')
namespace=$(${JSONNET} ${global_config} | jq -r '.namespace')
${JSONNET} $deploy_file > /tmp/${appname}podservice.json
if [ $createOrdelete = "create" ]; then
  if [[ $(${ENNCTL} -n $namespace get app | awk '{print $1}' | grep -E "(^)${appname}($)" | wc -l) = 0 ]]; then 
      $ENNCTL -n $namespace create app $appname
  fi
fi
$ENNCTL $createOrdelete -f /tmp/${appname}podservice.json -a ${appname}

if [ ${createOrdelete} == "delete" ]; then
  # delete app if there is no pod in this app
  if [ $($ENNCTL -n $namespace get pod -a $appname | awk '{print $3}' | grep -c Running) -eq 0 ]; then
    $ENNCTL -n $namespace delete app $appname
  fi
fi
if [ -f /tmp/${appname}podservice.json ]; then
  rm -f /tmp/${appname}podservice.json
fi
