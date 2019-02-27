#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

print_usage() {
    echo ""
    echo "Usage: create_spark_history_dir.sh <namespace>"
    echo ""
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
        echo "This script will create spark history log dir in hdfs"
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

namenode=`kubectl -n $namespace get pod | grep namenode | tail -n 1 | awk '{print $1}'`

if [ $namenode == "" ]; then
  echo no namenode is available
  exit 1
else
  kubectl -n $namespace exec $namenode -- hdfs dfs -mkdir -p /var/log/spark
  exit 0
fi