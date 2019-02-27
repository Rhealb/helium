#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

esclient_nodeport='{{ elasticsearch_nodeports_httpport }}'
nodeportlist=(${esclient_nodeport//,/ })
virtual_ip={{ master_list[0] }}
URL=()
for url in ${nodeportlist[@]}
do
  drurl=${url//\"}
  URL+=("${virtual_ip}:${drurl}")
done

# Paths to commands used in this script.
CURL="curl"
CHECK_URL="http://${URL[0]}/_cluster/health"
CHECK_ELASTICSEARCH="Elasticsearch"

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
        echo "$PROGNAME $RELEASE - Elasticsearch status check script for Nagios"
        echo ""
        echo "Usage: check_elasticsearch_status.sh"
        echo ""
        echo "  -H  the host(default:http://10.19.140.200:31921)"
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
        echo "This plugin will check elasticsearch status"
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
        -H | --host)
            shift
            host=$1
            CHECK_URL="http://${host}:31921/_cluster/health"
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
        CURL_RETURN=`$CURL --insecure -XGET -m 5 -s -w "#HTTPSTATUS:%{http_code}" $CHECK_URL`
        HTTP_STATUS=${CURL_RETURN#*HTTPSTATUS:}

		if [ "$HTTP_STATUS" != "200" ];then
		#	sleep 5
            CURL_RETURN=`$CURL --insecure -XGET -m 5 -s -w "#HTTPSTATUS:%{http_code}" $CHECK_URL`
	        HTTP_STATUS=${CURL_RETURN#*HTTPSTATUS:}
		fi

		JSON_SCRIPT=${CURL_RETURN%#HTTPSTATUS:*}
	    ELASTICSEARCH_STATUS=`echo $JSON_SCRIPT | grep -o '"status":"[^"]*' | grep -o '[^"]*$'`

		if [ "$HTTP_STATUS" = "200" ];then
			case "$ELASTICSEARCH_STATUS" in
            	"green" | --OK)
					echo "OK - $CHECK_ELASTICSEARCH status is $ELASTICSEARCH_STATUS"
                	exit $STATE_OK
					;;
            	"yellow"| --Warning)
					echo "WARNING - $CHECK_ELASTICSEARCH status is $ELASTICSEARCH_STATUS"
            	    exit $STATE_WARNING
					;;
            	"red"   | --Critical)
					echo "CRITICAL - $CHECK_ELASTICSEARCH status is $ELASTICSEARCH_STATUS"
                	exit $STATE_CRITICAL
					;;
        	esac
		else
            echo "CRITICAL - HTTP_RESPONSE status code is $HTTP_STATUS"
            exit $STATE_CRITICAL
        fi
