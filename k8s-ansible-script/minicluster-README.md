# 安装一个单节点的集群
## prepare:
1,安装的机器的系统版本必须是centos7.4 1708版
2,配置本机到安装机器ssh免密登录
3，修改k8s-cluster/clusters/minicluster/centos-cluster.yml文件中的ip为需要安装集群的主机ip
4,在k8s-cluster/clusters/minicluster/centos-cluster.yml中添加参数
  `single_node: true`
  **注意：若不是部署单节点的集群，务必将此参数删除。**
5，single-node-cluster的安装支持系统盘（例：/dev/sda）安装、额外添加硬盘(例：/dev/sdb)方式的安装以及loopback device的方式安装（见附录）。
1),使用额外盘安装需添加参数（推荐）： 
`      special_mounts:`
`          /dev/sdb`
`            path: /xfs/disk1`
`            opt: prjquota`
2),使用系统盘安装的前提是系统盘有分区，需添加参数：
`      special_mounts:`
`          /dev/sda:`
`            path: /xfs/disk1`
`            opt: prjquota`
`            num: 3`
并且设置
`      disk_type: sda`
  **注意：若不是在系统盘以分区方式安装hostpath，务必将此参数删除。**
3),使用回环设备安装添加参数：
`      special_mounts:`
`          /dev/loop`
`            path: /xfs/disk1`
`            opt: prjquota`
`            num: 0`
`            size:30720`
并且设置：
`disk_type: loop`
 **注意：若不是以loopback device方式安装hostpath，务必将此参数删除。**

## step：
### 安装：
`ansible-playbook  -i k8s-cluster/clusters/minicluster/centos-cluster.yml playbook/agile.yml`

### 删除：
`ansible-playbook  -i k8s-cluster/clusters/minicluster/centos-cluster.yml playbook/cluster-destroy.yml`

# 在ubuntu16.04上安装集群
## step：
### 安装：
`ansible-playbook  -i k8s-cluster/clusters/minicluster/ubuntu-cluster.yml playbook/agile-ubuntu.yml`


### 删除：
`ansible-playbook  -i k8s-cluster/clusters/minicluster/ubuntu-cluster.yml playbook/cluster-destroy.yml`



#### 附录：创建loopback device

1，创建一个用于承载虚拟文件系统的空文件，并指定大小。

要在根目录下（root directory）建立一个 30 MB 大小的名为 virtualfs 的文件可以通过以下命令：

$sudo dd if=/dev/zero of=/virtualfs bs=1024 count=30720

若要创建100G以上的文件会耗时比较久。
2，回环设备以 /dev/loop0、/dev/loop1 等命名。每个设备可虚拟一个块设备。为了确认当前系统是否有在使用回环设备，你需要使用下面的语句，如果 /dev/loop0 已经存在，你会得到类似下面的结果。然后你就需要把 /dev/loop0 替换成 /dev/loop1, 或者再把 /dev/loop1替换成/dev/loop2, 并以此类推，直到找到一个空的回环设备为止。后续步骤使用/dev/loop0为例。

$losetup /dev/loop0

/dev/loop0: []: (/var/lib/snapd/snaps/core_4917.snap)

3，接下来使用losetup命令来把常规文件或块设备（/dev/loop0）关联到一个loop文件（virtualfs）上。

$sudo losetup /dev/loop0 /virtualfs

4，接下来需要在回环设备上创建一个 Linux xfs 文件系统（with 1% reserved block count）,而该文件当前已经被关联到一个普通的磁盘文件上了。输入：

$sudo mkfs.xfs /dev/loop0

5， 然后我们在需要创建一个文件夹来作为挂载点（mount point）

$sudo mkdir /xfs/disk1

接下来就是把回环文件系统挂载（mount）到上面刚刚创建的目录上（ /xfs/disk1），这样就算完成了一个xfs文件系统的创建

$sudo mount -t xfs /dev/loop0 /xfs/disk1

接下来查看mount情况：

$df -h

/dev/loop5       27M  1.6M   26M   6% /xfs/disk1

6,卸载文件系统

$sudo umount /xfs/disk1
$sudo losetup -d /dev/loop0
$rm -rf /virtualfs   /xfs/disk1
