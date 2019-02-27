#!/bin/bash
res=$(curl --silent ${HOSTNAME}:8088/cluster/cluster | sed -n '/ResourceManager HA state:/,/active/p' | wc -l)

if [ $res -eq 4 ]
#the node is active node, return http 200
then
  /bin/echo "HTTP/1.1 200 OK\r\n"
  /bin/echo "Content-Type: Content-Type: text/plain\r\n"
  /bin/echo "\r\n"
  /bin/echo " I am active.\r\n"
  /bin/echo "\r\n"
else
# ldap is down, return http 503
  /bin/echo "HTTP/1.1 503 Service Unavailable\r\n"
  /bin/echo "Content-Type: Content-Type: text/plain\r\n"
  /bin/echo "\r\n"
  /bin/echo " I am standby.\r\n"
  /bin/echo "\r\n"
fi
