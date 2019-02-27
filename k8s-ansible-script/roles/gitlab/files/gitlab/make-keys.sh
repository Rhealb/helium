#/bin/bash
# $1 gitlab domain
#sudo openssl genrsa -des3 -out $1.key 2048

#sudo openssl req -new -key $1.key -out  $1.csr

#sudo cp -v $1.{key,original}

#sudo rm -v $1.original

#sudo openssl x509 -req -days 1460 -in $1.csr -signkey $1.key -out $1.crt

#sudo rm -v $1.csr

#sudo chmod 600 $1.*

#openssl genrsa -out ca.key 2048
#openssl req -x509 -new -nodes -key ca.key -subj "/CN=enn.cn" -days 10000 -out ca.crt


openssl genrsa -out ssl/gitlab.key 2048
openssl req -new -key ssl/gitlab.key -subj "/CN=$1" -out ssl/gitlab.csr
openssl x509 -req -in ssl/gitlab.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extensions v3_req  -out ssl/gitlab.crt -days 10000
