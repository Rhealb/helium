#!/bin/bash

res=$(curl --silent localhost:16010/master-status | grep "<h4>Current Active Master: <a href=" | wc -l)

if [ ! $res -gt 0 ]
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
