# K8s ansible deployment 

## Supported version
* 1.9

## Usage
```
---
- include: k8s-cluster/k8s-1.9-isolated.yml
```

## Dependencies

### tools
* cfssl
* cfssljson
```
mkdir ~/bin
curl -s -L -o ~/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
curl -s -L -o ~/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x ~/bin/{cfssl,cfssljson}
export PATH=$PATH:~/bin
```

### files prepared
```
k8s-cluster/files/kube/
├── exechealthz.tar      --> tag to the same value as variable exechealthz_image
├── flanneld             --> only needed when backend_type is "vxlan-over-hostgw"
├── kube-apiserver
├── kube-controller-manager
├── kubectl
├── kube-dnsmasq.tar     --> tag to the same value as variable dnsmasq_image
├── kube-dns.tar         --> tag to the same value as variable kubedns_image
├── kubelet
├── kube-proxy
├── kube-rescheduler
├── kube-scheduler
└── pause.tar            --> tag to the same value as variable pause_image

0 directories, 14 files
```

## Variable defination example
* refer to var.example

## Preinstalled Pacages
* kernel-ml
* etcd
* flannel
* docker
* systemd-networkd
* systemd-resolved
* ntp
* ceph-common
* glibc
* conntrack-tools
* curl
* nc
* rsync
* net-tools
* keepalived
* haproxy
* jq
