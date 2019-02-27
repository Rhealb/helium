#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

print_usage() {
    echo ""
    echo "Usage: create_opentsdb_table.sh"
    echo ""
    echo "  -H1 the host1 -H2 the host2 -H3 the host(default:http://10.19.140.200:30092)"
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
        echo "This script will create opentsdb tables in hbase"
        echo ""
        exit 1
}

if [ $# -le 0 ]; then
  print_usage
  exit 1
fi

namespace=$1
shift

PROGNAME=$(basename $0)


# Parse parameters
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)
            print_help
            exit $STATE_OK
            ;;
        *)

	    echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
        esac
shift
done

regionserver=`kubectl -n $namespace get pod | grep regionserver | tail -n 1 | awk '{print $1}'`

if [ $regionserver == "" ]; then
  echo no regionserver is available
  exit 1
else
  kubectl -n $namespace exec $regionserver -- env COMPRESSION=NONE /opt/scripts/create_table.sh
  exit 0
fi
