#!/bin/bash
set -e
while true; do
  sleep 30
  if [ $(jps | grep "DFSZKFailoverController" | wc -l) -eq 0 ]; then
    echo "DFSZKFailoverController process not exist......"
    namenodepid=$(jps | grep "NameNode" | awk '{print $1}')
    if [[ ! -z $namenodepid ]]; then
      echo "start kill NameNode process......"
      kill -9 ${namenodepid}
      exit 1
    fi
  fi
done
