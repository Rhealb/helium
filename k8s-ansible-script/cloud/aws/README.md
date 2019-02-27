# AWS ansible deployment

This article explains how to create EC2 instances with AWS using ansible.

## Prepare

Using centos 7 in aws as the Ansible host.Install ansible version 2.4.2 or higher

```
yum install ansible
```

Log into your AWS account to get your “AWS_ACCESS_KEY_ID” and  “AWS_SECRET_ACCESS_KEY”. Go to “Identity and Access Management”. Create a new user or select an exiting one. Go to “Security Credentials” and click “Create Access Key”. aws/accessKeys.csv is my keys,use them to create environment variables:

```
export AWS_ACCESS_KEY_ID="AKIAOIPCI7TI7E4VBKFQ" 
export AWS_SECRET_ACCESS_KEY="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"
```

add above to ~/.bashrc and run

```
source ~/.bashrc
```

## VM Import/Export

You can use VM Import/Export to import virtual machine (VM) images from your virtualization
environment to Amazon EC2 as Amazon Machine Images (AMI), which you can use to launch
instances. 
Create your image according to the steps in the link below.

https://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html

Or you can use the default centos7 image, its version is 

```
3.10.0-693.el7.x86_64
```

## Usage

### Deploy a new cluster

change your variables in  aws/variables.yml or use default value,here is the meaning of variables:

|       Parameter       |                           Comments                           |
| :-------------------: | :----------------------------------------------------------: |
|      ec2_region       |                    The AWS region to use                     |
|       ec2_zone        |    AWS availability zone in which to launch the instance     |
|   ec2_instance_type   | instance type to use for the instance, see <http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html> |
|       ec2_image       |               *ami* ID to use for the instance               |
|      ec2_keypair      |               key pair to use on the instance                |
|  ec2_volume_size_sdb  |                      volume size of sdb                      |
|  ec2_volume_size_sdc  |                      volume size of sdc                      |
|       ec2_count       |                number of instances to launch                 |
| ec2_security_group_id | security group id (or list of ids) to use with the instance  |
|     ec2_subnet_id     |     the subnet ID in which to launch the instance (VPC)      |

now we can run

```
ansible-playbook -i k8s-cluster/clusters/aws/hosts aws/prov-ec2.yml
```

After all the tasks finished,an inventory file is produced in k8s-cluster/clusters/aws/cluster.yml

then create k8s cluster with new inventory 

```
ansible-playbook -i k8s-cluster/clusters/aws/cluster.yml os/install-centos7.4-packages-localrepo.yml
ansible-playbook -i k8s-cluster/clusters/aws/cluster.yml k8s-cluster/k8s-1.9-ennpolicy.yml
```

### Add node to cluster

change your variables in  aws/variables.yml,then run 

```
ansible-playbook -i k8s-cluster/clusters/aws/hosts aws/addnode.yml
```

check  k8s-cluster/clusters/aws/cluster.yml file,"host_path_list" is now updated with new instance ips,as well as the last few lines named "hosts".Comment out the old ip with the cluster installed,leaving the newly generated ec2_count(as you defined in aws/variables.yml) ips, then run

```
ansible-playbook -i k8s-cluster/clusters/aws/cluster.yml k8s-cluster/k8s-1.9-isolated-addNodes.yml
```



## Changes in k8s deployment

add --cloud-provider parameter in apiserver ,kube-controller and kubelet

```
--cloud-provider=aws
```

except above,add --cloud-config parameter in kube-controller

```
--cloud-config=/etc/kubernetes/cloud-config
```

The config content is as follows

```
[Global]
KubernetesClusterTag=enn-cluster
KubernetesClusterID=enn-cluster
zone=cn-north-1b
```

the environment file /etc/kubernetes/config has been added with AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY ,so the cluster can connect to the right account

```
AWS_ACCESS_KEY_ID="AKIAOIPCI7TI7E4VBKFQ"
AWS_SECRET_ACCESS_KEY="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"
```

