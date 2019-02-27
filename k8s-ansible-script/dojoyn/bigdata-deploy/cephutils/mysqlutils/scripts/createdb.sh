#!/bin/bash
#crate database
USER="root"
PASSWORD=${MYSQL_ROOT_PASSWORD}
if [[ -z ${1} ]]; then
  echo "databases not set"
  exit 1
fi
dbs=${1/,/ }
echo "creat_table.sh: ${dbs}"
for db in ${dbs}; do
  echo "create db: ${db}"
  while [[ true ]]; do
    sleep 1
    mysql -u$USER -p$PASSWORD << EOF 2>/dev/null
    CREATE DATABASE ${db} DEFAULT CHARACTER SET utf8;
EOF
    if [[ $? -eq 0 ]]; then
      break
    fi
  done
done
