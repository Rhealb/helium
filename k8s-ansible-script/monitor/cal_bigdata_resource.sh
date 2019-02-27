#!/bin/bash
if [ -z $1 ]; then
  echo "please input variables cluster_total_cores"
  exit -1
fi
if [ -z $2 ]; then
  echo "please input variables cluster_total_mem"
  exit -1
fi
cluster_total_cores=$1
cluster_total_mem=$2
path=$(cd `dirname $0`;pwd)
cd ${path}/roles/monitor-resource-cal 
python ./scripts/essential-service-cal.py --cluster-total-cores ${cluster_total_cores} --cluster-total-mem ${cluster_total_mem}
# python ./scripts/cal.py --cluster-total-cores ${cluster_total_cores} --cluster-total-mem ${cluster_total_mem}
