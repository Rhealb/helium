#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

HMASTER_NUM={{ hbase_master_instancecount }}
REGIONSERVER_MAX_NUM={{ hbase_regionserver_instancecount }}


# Paths to commands used in this script.
CURL="curl"

hmaster_nodeport='{{ hbase_nodeports_master_http }}'
nodeportlist=(${hmaster_nodeport//,/ })
virtual_ip={{ master_list[0] }}
URL=()
for url in ${nodeportlist[@]}
do
  drurl=${url//\"}
  URL+=("${virtual_ip}:${drurl}")
done


CHECK_HBASE="HBase"

# USERNAME="IDH02BjXJI8agb1WdPlXf3VaYkRVNQrPaP5OKcbuYe8="
# PASSWD="admin"

# Plugin variable description
PROGNAME=$(basename $0)
RELEASE="Revision 0.1"
AUTHOR="(c) 2017 WangShengtao (stwang.casd@gmail.com)"

# Functions plugin usage
print_release() {
    echo "$RELEASE $AUTHOR"
}

print_usage() {
        echo ""
        echo "$PROGNAME $RELEASE - Hbase status check script for Nagios"
        echo ""
        echo "Usage: check_hbase_status.sh"
        echo ""
        echo "  -H1 the host1 -H2 the host2 -H3 the host(default:http://10.19.140.200:30092)"
        # echo "  -n  username to login(default:admin)"
	    # echo "  -p  passwd to login(default:admin)"
        echo "  -v  check the version"
        echo "  -h  Show this page"
        echo ""
    echo "Usage: $PROGNAME"
    echo "Usage: $PROGNAME --help"
    echo ""
    exit 0
}

print_help() {
        print_usage
        echo ""
        echo "This plugin will check hbase status"
        echo ""
        exit 0
}

# Parse parameters
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)
            print_help
            exit $STATE_OK
            ;;
        -v | --version)
            print_release
            exit $STATE_OK
            ;;
        -H1 | --host1)
            shift
            URL[0]=${1}
			;;
        -H2 | --host2)
            shift
		    URL[1]=${1}
			;;
        -H3 | --host3)
            shift
            URL[2]=${1}
			;;
        -l )
            shift
            REGIONSERVER_MAX_NUM=${1}
            ;;
	   # -n | --username)
       #     shift
       #     USERNAME=$1
       #    ;;
	   # -p | --password)
       #     shift
       #     PASSWD=$1
       #     ;;
        *)

	    echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
        esac
shift
done

MAIN_STATUS=()
HTTP_STATUS=()
NUM_REGIONSERVER=()
ACTIVE_HMASTER=()

for((i=0;i<${HMASTER_NUM}; ++i))
do
    CHECK_URL_MAIN="http://${URL[i]}"
    CURL_RETURN_MAIN=`$CURL --insecure -m 4 -s -w "#HTTPSTATUS:%{http_code}" $CHECK_URL_MAIN`
    MAIN_STATUS[i]=${CURL_RETURN_MAIN#*HTTPSTATUS:}

    CHECK_URL_JMX="http://${URL[i]}/jmx?qry=Hadoop:service=HBase,name=Master,sub=Server"
    CURL_RETURN_JMX=`$CURL --insecure -m 6 -s -w "#HTTPSTATUS:%{http_code}" $CHECK_URL_JMX`
    HTTP_STATUS[i]=${CURL_RETURN_JMX#*HTTPSTATUS:}
    NUM_REGIONSERVER[i]=`echo $CURL_RETURN_JMX | grep -o '"numRegionServers" : [0-9]*' | grep -o '[0-9]*'`
    ACTIVE_HMASTER[i]=`echo $CURL_RETURN_JMX | grep -o '"tag.isActiveMaster" : "[^"]*' | grep -o '[^"]*$'`
done

if [ "${MAIN_STATUS[0]}" != "200" -a "${MAIN_STATUS[1]}" != "200" -a "${MAIN_STATUS[2]}" != "200" ];then
    echo "CRITICAL - ${CHECK_HBASE} status is CRITICAL"
    exit $STATE_CRITICAL
else
    ind=-1
    HTTP_STATUS_FLAG=0
    MAIN_STATUS_FLAG=0

    for((i=0;i<${HMASTER_NUM}; ++i))
    do
        if [ "${ACTIVE_HMASTER[${i}]}" = "true" ];then
            ind=${i}
        fi

        if [ "${MAIN_STATUS[${i}]}" != "200" ];then
            MAIN_STATUS_FLAG=1
        fi

        if [ "${HTTP_STATUS[${i}]}" != "200" ];then
            HTTP_STATUS_FLAG=1
        fi

    done

    if [ ${ind} == -1 -o "${MAIN_STATUS[${ind}]}" != "200" ];then
        echo "CRITICAL - ${CHECK_HBASE} status is CRITICAL"
        exit $STATE_CRITICAL
    elif [ "${ACTIVE_HMASTER[${ind}]}" != "true" ]; then
        echo "CRITICAL - ${CHECK_HBASE} status is CRITICAL"
        exit $STATE_CRITICAL
      else
        case ${NUM_REGIONSERVER[${ind}]} in
            0 )
                echo "CRITICAL - ${CHECK_HBASE} status is CRITICAL"
                exit $STATE_CRITICAL
                ;;
            ${REGIONSERVER_MAX_NUM} )
                if [ "${MAIN_STATUS_FLAG}" = "1" -o "${HTTP_STATUS_FLAG}" = "1" ]; then
                    echo "WARNING - ${CHECK_HBASE} status is WARNING"
                    exit $STATE_WARNING
                fi
                echo "OK - ${CHECK_HBASE} status is OK"
                exit $STATE_OK
                ;;
            * )
                echo "WARNING - ${CHECK_HBASE} status is WARNING"
                exit $STATE_WARNING
                ;;
        esac
    fi
fi
