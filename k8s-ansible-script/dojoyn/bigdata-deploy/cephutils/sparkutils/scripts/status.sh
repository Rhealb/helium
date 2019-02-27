#!/bin/bash

res=$(curl --silent localhost:8080 | grep "<li><strong>Status:</strong> ALIVE</li>" | wc -l)

if [ $res -gt 0 ]
#the node is active node, return http 200
then
  /bin/echo "HTTP/1.1 200 OK\r\n"
  /bin/echo "Content-Type: Content-Type: text/plain\r\n"
  /bin/echo "\r\n"
  /bin/echo " I am alive.\r\n"
  /bin/echo "\r\n"
else
# the node is standby node, return http 503
  /bin/echo "HTTP/1.1 503 Service Unavailable\r\n"
  /bin/echo "Content-Type: Content-Type: text/plain\r\n"
  /bin/echo "\r\n"
  /bin/echo " I am standby.\r\n"
  /bin/echo "\r\n"
fi
