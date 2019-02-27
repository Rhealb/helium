#!/bin/bash


ansibleroot=$(dirname "$(realpath "$0")")/../..

file=$ansibleroot/$1

des=$(dirname "$file")

if [ ! -d $des ]; then
	mkdir -p $des
fi 

if [ -e "$file" ];then
	rm -f $file
fi

docker save registry:2.6.2 -o images/registry.tar 
cmd="zip -r $file images/docker images/registry.tar scripts/start_local_registry.sh"

$cmd
rm -rf images/registry.tar
rm -rf images/docker
