#!/bin/bash
#spark config
sparkmaster_nodeport='{{ spark_nodeports_master_ui }}'
nodeportlist=(${sparkmaster_nodeport//,/ })
virtual_ip={{ master_list[0] }}
spark_url=()
for url in ${nodeportlist[@]}
do
  drurl=${url//\"}
  spark_url+=("${virtual_ip}:${drurl}")
done

spark_worker_count={{ spark_worker_instancecount }}
spark_master_count=1
spark_standby_count=2

spark_worker_instance=0
spark_master_instance=0
spark_slave_instance=0

while getopts ":H:w:m:" optname
do
	case "$optname" in
	  "H")
		hosts=$OPTARG
		;;
	  "w")
		spark_worker_count=$OPTARG
		;;
	  "?")
		echo "Unknown option"

		;;
	  ":")
		echo "No args"
		;;
	esac
done

if [[ $hosts && -n $hosts ]]
then
 	export IFS=","
	spark_url=($hosts)
{% raw %}
	urlLen=${#spark_url[*]}
{% endraw %}
	spark_standby_count=`expr $urlLen - 1`
fi

function funCheck(){
        isStandy=$1
        isAlive=$2
        if [ $isStandy == 1 ]
        then
                val=`expr $spark_slave_instance + 1`
                spark_slave_instance=$val
        fi
        if [ $isAlive -ge 1 ]
        then
                val=`expr $spark_master_instance + 1`
                spark_master_instance=$val
                val=`expr $isAlive - 1 + $spark_worker_instance`
                spark_worker_instance=$val
        fi
}

export IFS=$'\n'
for url in ${spark_url[*]}
do
	response=`curl -m 6 -sL $url`
	standbys=(`echo "$response" | grep -c 'STANDBY'`)
	alives=(`echo "$response" | grep -c 'ALIVE'`)
	funCheck $standbys $alives
done

if [[ $spark_master_instance == $spark_master_count && $spark_slave_instance == $spark_standby_count && $spark_worker_instance == $spark_worker_count ]]
then
	exit 0
fi

if [[ $spark_master_instance == 0 || $spark_worker_instance == 0 ]]
then
	exit 2
fi

exit 1
