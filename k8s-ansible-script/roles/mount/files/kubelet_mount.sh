#!/bin/bash
for j in 1,e 2,f 3,g 4,h
do
  var1=${j%,*}
  var2=${j#*,}
fdisk /dev/sd${var2} << EOF
n
p
1


wq
EOF
mkfs.xfs /dev/sd${var2}1
mount -o prjquota /dev/sd${var2}1 /xfs/disk${var1}
echo "/dev/sd${var2}1 /xfs/disk${var1}    xfs prjquota 0 0" >> /etc/fstab

done
