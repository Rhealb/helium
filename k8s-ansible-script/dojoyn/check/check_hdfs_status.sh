STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

SH_MAX_LIVE_DATANODES=3
MAX_LIVE_DATANODES=${SH_MAX_LIVE_DATANODES}

# Paths to commands used in this script.
CURL="/usr/bin/curl"
CHECK_URL[0]="http://10.19.140.6:29470/jmx"
CHECK_URL[1]="http://10.19.140.6:29471/jmx"
CHECK_HDFS="HDFS"
FLAG="SH"
capacity_used_threshold=0.8

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
        echo "$PROGNAME $RELEASE - HDFS status check script for Nagios"
        echo ""
        echo "Usage: check_hdfs_status.sh"
        echo ""
        echo "  -H1 the host1 -H2 the host2"
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
        echo "This plugin will check hdfs status"
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
            CHECK_URL[0]="http://${1}/jmx"
            ;;
        -H2 | --host2)
            shift
            CHECK_URL[1]="http://${1}/jmx"
            ;;
        -l )
            shift
            MAX_LIVE_DATANODES=${1}
            ;;
        -F )
            shift
            FLAG=${1}
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

        for ((num=0;num<2;num++))
        do
        (
            filename="check_${FLAG}_hdfs_tempfile_${num}"
            `$CURL --insecure -m 17 -s -w "#HTTPSTATUS:%{http_code}" ${CHECK_URL[${num}]} > ${filename}`
        )&
        done
        wait

        filename="check_${FLAG}_hdfs_tempfile_0"
        CURL_RETURN_1=$(cat ${filename})

        HTTP_STATUS_1=${CURL_RETURN_1#*HTTPSTATUS:}

        JSON_SCRIPT_1=${CURL_RETURN_1%#HTTPSTATUS:*}

        filename="check_${FLAG}_hdfs_tempfile_1"
        CURL_RETURN_2=$(cat ${filename})

        HTTP_STATUS_2=${CURL_RETURN_2#*HTTPSTATUS:}

        JSON_SCRIPT_2=${CURL_RETURN_2%#HTTPSTATUS:*}

        state_1=`echo $JSON_SCRIPT_1 | grep -o '"State" : "[^"]*' | grep -o '[^"]*$'`
        state_2=`echo $JSON_SCRIPT_2 | grep -o '"State" : "[^"]*' | grep -o '[^"]*$'`


        if [ "${HTTP_STATUS_1}" = "200" -a "${HTTP_STATUS_2}" = "200" ];then
            if [ "${state_1}" = "active" -a "${state_2}" = "standby" ];then
                num_Live_DataNodes=`echo $JSON_SCRIPT_1 | grep -o '"NumLiveDataNodes" : [0-9]*' | grep -o '[0-9]*'`
                safeMode_Status=`echo $JSON_SCRIPT_1 | grep -o 'SafeMode" : "[^"]*' | grep -o '[^"]*$'`

                if [ -z "${safeMode_Status}" -a ${num_Live_DataNodes} -ge $[${MAX_LIVE_DATANODES}-2] ];then
                    capacity_total_GB=`echo $JSON_SCRIPT_1 | grep -o '"CapacityTotalGB" : [0-9]*' | grep -o '[0-9]*'`
                    capacity_used_GB=`echo $JSON_SCRIPT_1 | grep -o '"CapacityUsedGB" : [0-9]*' | grep -o '[0-9]*'`
                    capacity_used_ratio=$(awk 'BEGIN{printf "%.2f\n",'${capacity_used_GB}'/'${capacity_total_GB}'}')

                    if [ ${num_Live_DataNodes} == ${MAX_LIVE_DATANODES} -a $(expr ${capacity_used_ratio}\<${capacity_used_threshold}) ];then
                        echo "OK - ${CHECK_HDFS} status is OK"
                        exit $STATE_OK
                    else
                        echo "WARNING - ${CHECK_HDFS} status is WARNING!"
                        exit $STATE_WARNING
                    fi
                else
                    echo "CRITICAL - ${CHECK_HDFS} status is CRITICAL!"
                    exit $STATE_CRITICAL
                fi
            elif [ "${state_1}" = "standby" -a "${state_2}" = "active" ];then
                num_Live_DataNodes=`echo $JSON_SCRIPT_2 | grep -o '"NumLiveDataNodes" : [0-9]*' | grep -o '[0-9]*'`
                safeMode_Status=`echo $JSON_SCRIPT_2 | grep -o 'SafeMode" : "[^"]*' | grep -o '[^"]*$'`

                if [ -z "${safeMode_Status}" -a ${num_Live_DataNodes} -ge $[${MAX_LIVE_DATANODES}-2] ];then
                    capacity_total_GB=`echo $JSON_SCRIPT_1 | grep -o '"CapacityTotalGB" : [0-9]*' | grep -o '[0-9]*'`
                    capacity_used_GB=`echo $JSON_SCRIPT_1 | grep -o '"CapacityUsedGB" : [0-9]*' | grep -o '[0-9]*'`
                    capacity_used_ratio=$(awk 'BEGIN{printf "%.2f\n",'${capacity_used_GB}'/'${capacity_total_GB}'}')

                    if [ ${num_Live_DataNodes} == ${MAX_LIVE_DATANODES} -a $(expr ${capacity_used_ratio}\<${capacity_used_threshold}) ];then
                        echo "OK - ${CHECK_HDFS} status is OK"
                        exit $STATE_OK
                    else
                        echo "WARNING - ${CHECK_HDFS} status is WARNING!"
                        exit $STATE_WARNING
                    fi
                else
                    echo "CRITICAL - ${CHECK_HDFS} status is CRITICAL!"
                    exit $STATE_CRITICAL
                fi
              else
                echo "CRITICAL - ${CHECK_HDFS} status is CRITICAL!"
                exit $STATE_CRITICAL
            fi
        elif [ "${HTTP_STATUS_1}" != "200" -a "${HTTP_STATUS_2}" != "200" ];then
            echo "3333"
            echo "CRITICAL - HTTP_STATUS status is wrong!"
            exit $STATE_CRITICAL
          elif [ "${HTTP_STATUS_1}" = "200" ];then
                num_Live_DataNodes=`echo $JSON_SCRIPT_1 | grep -o '"NumLiveDataNodes" : [0-9]*' | grep -o '[0-9]*'`
                safeMode_Status=`echo $JSON_SCRIPT_1 | grep -o 'SafeMode" : "[^"]*' | grep -o '[^"]*$'`

                if [ -z "${safeMode_Status}" -a "${state_1}" = "active" -a ${num_Live_DataNodes} -ge $[${MAX_LIVE_DATANODES}-2] ];then
                    echo "WARNING - ${CHECK_HDFS} status is WARNING!"
                    exit $STATE_WARNING
                else
                    echo "CRITICAL - ${CHECK_HDFS} status is CRITICAL!"
                    exit $STATE_CRITICAL
                fi
            else
                num_Live_DataNodes=`echo $JSON_SCRIPT_2 | grep -o '"NumLiveDataNodes" : [0-9]*' | grep -o '[0-9]*'`
                safeMode_Status=`echo $JSON_SCRIPT_2 | grep -o 'SafeMode" : "[^"]*' | grep -o '[^"]*$'`
                if [ -z "${safeMode_Status}" -a "${state_2}" = "active" -a ${num_Live_DataNodes} -ge $[${MAX_LIVE_DATANODES}-2] ];then
                    echo "WARNING - ${CHECK_HDFS} status is WARNING!"
                    exit $STATE_WARNING
                else
                    echo "CRITICAL - ${CHECK_HDFS} status is CRITICAL!"
                    exit $STATE_CRITICAL
                fi
            fi
        fi

