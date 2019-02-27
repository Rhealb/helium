#!/bin/bash

losetup $1 /virtualfs
mount -o prjquota $1 $2

#mount -o prjquota /dev/loop0 /xfs/disk1