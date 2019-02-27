#/bin/sh
#"{{ item.key }}" "{{ item.value.path }}" "{{ item.value.num }}" "{{ item.value.size }}"

sudo mkdir -p $2
sudo umount $2
sudo losetup -d $1$3
sudo rm -rf /virtualfs

sudo dd if=/dev/zero of=/virtualfs bs=1024 count=$4
sudo losetup $1$3 /virtualfs
sudo mkfs.xfs -f $1$3
sudo mount -o prjquota  $1$3 $2