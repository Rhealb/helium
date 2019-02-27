#!/bin/bash
zookeeper_nodeport='{{ zookeeper_nodeports_clientport }}'
nodeportlist=(${zookeeper_nodeport//,/ })
virtual_ip={{ master_list[0] }}
zookeeper_url=()
for url in ${nodeportlist[@]}
do
  drurl=${url//\"}
  zookeeper_url+=("${virtual_ip}:${drurl}")
done

zookeeper_leader_count=1

leader_instance=0
follower_instance=0

while getopts ":H:" optname
do
        case "$optname" in
          "H")
                hosts=$OPTARG
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
        zookeeper_url=($hosts)
fi
{% raw %}
urlLen=${#zookeeper_url[*]}
{% endraw %}
zookeeper_follower_count=`expr $urlLen - 1`

checkZK(){
	export IFS=":"
	url=($1)

	response=`echo ruok | nc -w 8 ${url[0]} ${url[1]}`
	if [ "$response" = "imok" ]
	then
		response=`echo stat | nc -w 8 ${url[0]} ${url[1]} | grep Mode | awk {'print $2'}`
	        if [ "$response" = "leader" ]
        	then
                	val=`expr $leader_instance + 1`
                      	leader_instance=$val
                fi

	        if [ "$response" = "follower" ]
                then
                       	val=`expr $follower_instance + 1`
                       	follower_instance=$val
                fi
	fi
}

for zk_url in ${zookeeper_url[*]}
do
	export IFS=","
	checkZK $zk_url
done

if [[ $leader_instance == $zookeeper_leader_count && $follower_instance == $zookeeper_follower_count ]]
then
	exit 0
fi

if [[ $leader_instance == $zookeeper_leader_count && $follower_instance -ge 1 ]]
then
	exit 1
fi

exit 2
