#!/bin/bash
umount /data
fdisk /dev/sda << EOF
d
wq
EOF

fdisk /dev/sda << EOF
n
p
1


wq
EOF
mkfs.xfs /dev/sda1
mkdir /data
mount /dev/sda1 /data
echo "/dev/sda1 /data xfs defaults 0 0" >> /etc/fstab
