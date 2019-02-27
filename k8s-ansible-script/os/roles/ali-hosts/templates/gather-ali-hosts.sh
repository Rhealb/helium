#!/bin/bash

rm -rf roles/ali-hosts/templates/ali-hosts-all-new
touch roles/ali-hosts/templates/ali-hosts-all-new
sudo chmod 777 roles/ali-hosts/templates/ali-hosts-all-new
cat roles/ali-hosts/templates/ali-hosts-all >> roles/ali-hosts/templates/ali-hosts-all-new
for i in `ls /tmp/ali-hosts/`
do
echo ${i}
tail -n 1 /tmp/ali-hosts/${i}/etc/hosts >> roles/ali-hosts/templates/ali-hosts-all-new
done
cat roles/ali-hosts/templates/ali-hosts-all-new