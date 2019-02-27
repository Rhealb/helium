#!/bin/bash
#spark config
opentsdb_nodeport='{{ opentsdb_nodeports_httpport }}'
nodeportlist=(${opentsdb_nodeport//,/ })
virtual_ip={{ master_list[0] }}
opentsdb_url=()
for url in ${nodeportlist[@]}
do
  drurl=${url//\"}
  opentsdb_url+=("${virtual_ip}:${drurl}")
done

for url in ${opentsdb_url[*]}
do
	CURL_RETURN=`curl --insecure -m 4 -s -w "#HTTPSTATUS:%{http_code}" $url`
	HTTP_STATUS=${CURL_RETURN#*HTTPSTATUS:}
	if [ "${HTTP_STATUS}" != "200" ];then
	  exit 2
	fi
done

exit 0
