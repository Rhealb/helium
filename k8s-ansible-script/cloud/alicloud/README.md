# AWS ansible deployment

## Prepare

There are two ways to install alicloud provider. However, before installing it. you should ensure `Ansible` has existed in your server.
If not, please install it using the following command:

    sudo pip install ansible

* First one

    Ansible provider has been released, and you can install it easily using the following command:

    ```
     sudo pip install ansible_alicloud
    ```

* Second one

    Ansible provider's modules support to install independently. That means you can download one or more modules from lib/ansible/modules/cloud/alicloud and then run them independently.
    However, before running them, you should ensure `ansible_alicloud_module_utils` has existed in your server. If not, please install it using the following command:

    ```
     sudo pip install ansible_alicloud_module_utils
    ```



Log into your ALICLOUD account to get your “ALICLOUD_ACCESS_KEY” and  “ALICLOUD_SECRET_KEY”. Go to “Identity and Access Management”. Create a new user or select an exiting one. Go to “Security Credentials” and click “Create Access Key”. alicloud/AccessKey.csv is my keys,use them to create environment variables:

```
export ALICLOUD_ACCESS_KEY="LTAIffvltEg9eoKY"
export ALICLOUD_SECRET_KEY="vjCIPszBTQaRILzP7NmF4nSnSMaYbv"
```

add above to ~/.bashrc and run

```
source ~/.bashrc
```

## Usage

Alter your variables in alicloud/group_vars/all or use default value,here is the meaning of variables:

|      Parameter       |     Choices | Comments |
| :------------------: | :------: | -------- |
|   alicloud_region    |       | The Aliyun Cloud region to use   	  |
|    alicloud_zone     |         |  Aliyun availability zone ID in which to launch the instance. If it is not specified, it will be allocated by system automatically.        |
|       vpc_cidr       |       10.0.0.0/8 172.16.0.0/12 192.168.0.0/16       | The CIDR block representing the vpc. The value can be subnet block of its choices. It is required when creating a vpc. |
|       vpc_name       |              | The name of VPC |
|     vswitch_cidr     |          | The CIDR block representing the Vswitch |
|     vswitch_name     |          | The name of vswitch |
|      group_name      |            | Security Group name used to launch instance or join/remove existing instances to/from the specified Security Group. |
|  group_inboundRules  |    | List of hash/dictionaries firewall inbound rules to enforce in this group. |
| group_outboundRules  |   | List of hash/dictionaries firewall outbound rules to enforce in this group. |
|       image_id       |              | Image ID used to launch instances. |
|    instance_type   |       | Instance type used to launch instances |
|    instance_name     |         | The name of ECS instance |
|      host_name       |             | Instance host name. |
|       password       |              | The password to login instance. After rebooting instances, the modified password would be take effect. |
|  allocate_public_ip  |    | Whether allocate a public ip for the new instance. |
| internet_charge_type | PayByBandwidth PayByTraffic | The charge type of the instance. |
|   max_bandwidth_in   |      | Maximum incoming bandwidth from the public network, measured in Mbps (Mega bit per second). |
|  max_bandwidth_out   |     | Maximum outgoing bandwidth to the public network, measured in Mbps (Mega bit per second). |
|    instance_tags     |         | A hash/dictionaries of instance tags |
| system_disk_category | cloud_efficiency cloud_ssd | Category of the system disk. |
|   system_disk_size   |   40~500   | Size of the system disk, in GB |
| number_of_instances  |   | The number of the new instance |
|        force         |     yes or no | Whether the current operation needs to be execute forcibly. |
|      disk_name       |            | The name of ECS disk |
|    disk_category     | cloud cloud_efficiency cloud_ssd | The category to apply to the disk. |
|    data_disk_size    |        | Size of disk (in GB) to create |
|      disk_tags       |             | A list of hash/dictionaries of instance tags |
| delete_with_instance | yes or no | When set to true, the disk will be released along with terminating ECS instance. |

These playbooks' hosts default to `localhost`, you want to deploy.Then run the playbook, like this:

	ansible-playbook alicloud.yml

These playbooks build a simple Alicloud VPC cluser based on Ansible provider of Alicloud.
The VPC cluster will contains one VPC, one VSwitch, one Security Group, several Security Group Rules, sevaral Instances and Disks for Instances. When the run is complete, you can login in the Alicloud console to check them.At the same time, cluster.yml is created in the same directory.Need to set parameters in cluster.yml:

```
alicloud:true
```

## Create cluster

```
ansible-playbook -i aliyun/cluster.yml os/install-centos7.4-packages-localrepo.yml

ansible-playbook -i aliyun/cluster.yml k8s-cluster/k8s-1.9-ennpolicy.yml
```

### Add node to cluster

firstly, change your variables in  group_vars/all

1,modify number_of_instances to the sum of the number of existing instances and the number of newly wanted instances

2,change the value of add_node to "true"

then run 

```
ansible-playbook alicloud.yml
```
the existing node will not be changed,as the same time new node is created.
check  cluster.yml file,"host_path_list" is now updated with new instance ips,as well as the last few lines named "hosts".Comment out the old ip with the cluster installed,leaving the newly generated instances' ips to add new instances to cluster (or keep them to reinstall a cluster).

```
ansible-playbook -i aliyun/cluster.yml k8s-cluster/k8s-1.9-isolated-addNodes.yml
```






