#!/bin/bash

echo "populate system level information to env file /etc/alilocal.conf..."
META_EP=http://100.100.100.200/latest/meta-data
echo -n 'ALI_INSTANCE=' > /etc/alilocal.conf
echo `curl -s $META_EP/region-id`.`curl -s $META_EP/instance-id` >> /etc/alilocal.conf
cat /etc/alilocal.conf