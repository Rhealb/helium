#!/bin/bash
set -eo pipefail
shopt -s nullglob


BRIDGE_NAME="ansible"
BASE_DIR="/tmp/$BRIDGE_NAME"
VERSION="1.5"


function print_usage() {
    echo ""
    echo "Usage: "
    echo ""
    echo "  start     start deploy docker daemon"
    echo "  clean     clean all deploy docker daemon files"
    echo "  version   print version "
    echo ""
}

function prepare_network() {
    systemctl stop firewalld
    if ! ip link show $BRIDGE_NAME > /dev/null 2>&1
    then
        sudo brctl addbr $BRIDGE_NAME
        sudo ip addr add ${net:-"192.168.1.1/24"} dev $BRIDGE_NAME
        sudo ip link set dev $BRIDGE_NAME up
    fi
}

function install_packages() {
  yum update
  yum remove docker  docker-common docker-selinux docker-engine
  yum install -y yum-utils device-mapper-persistent-data lvm2
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce-18.06.0.ce-3.el7 bridge-utils

}

function prepare_config() {
    ## containerd config
    cat << EOF > /tmp/containerd-config.toml
disabled_plugins = ["btrfs","aufs","zfs","cri"]
[plugins]
  [plugins.linux]
    shim = "docker-containerd-shim"
    runtime = "docker-runc"
    runtime_root = "/var/lib/docker/runc"
    no_shim = false
    shim_debug = false
EOF

    ## containerd systemd service
    cat << EOF > /etc/systemd/system/deploy-containerd.service
[Unit]
Description=deploy containerd
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/usr/bin/docker-containerd --config /tmp/containerd-config.toml
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target

EOF

    ## docker systemd service
    cat << EOF > /etc/systemd/system/deploy-docker.service
[Unit]
Description=deploy docker
After=deploy-containerd.service
Requires=deploy-containerd.service

[Service]
Type=notify
ExecStart=/usr/bin/dockerd \
	-b=$BRIDGE_NAME \
	--data-root=$BASE_DIR/data \
	--exec-root=$BASE_DIR/run \
	-H=127.0.0.1:2375 \
	--pidfile=$BASE_DIR/docker.pid \
	--containerd=/var/run/containerd/containerd.sock

LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target

EOF

}

if [ "$#" == "1" ];then
  if [ "$1" == "start" ];then
     install_packages
     prepare_config
     prepare_network
     systemctl daemon-reload
     systemctl start deploy-containerd
     systemctl start deploy-docker
     echo "Finished install,now set \"alias docker='docker -H 127.0.0.1:2375'\"  to run deploy pod"
  elif [ "$1" == "clean" ];then
     systemctl stop deploy-docker
     systemctl stop deploy-containerd
     ip link del $BRIDGE_NAME
     rm -rf /etc/systemd/system/deploy-containerd.service /etc/systemd/system/deploy-docker.service
  elif [[ "$1" == version ]]; then
    echo "shell version is $VERSION"
  else
     print_usage
  fi
else
  print_usage
fi
