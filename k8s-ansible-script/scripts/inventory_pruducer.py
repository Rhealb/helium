# -*- coding: utf-8 -*-


import yaml

import os
import re
import sys
import copy


var_dic = {
    'HOSTPAHT_DEV': ['sdb', 'sdc'],
    'CEPH_DEV': ['sde', 'sdf'],
    'HA_VIP': None,
    'TEMPLATE_FILE': './template.yml',
    'SSH_PORT': 22,
    'SSH_PASS': '123456',
    'INTERFACE': "",
    'PLATFROM_FILE': './cluster.yml',
    'SEARCHDOMAIN': ["xinao.com"],
    'NAMESERVERS': ['10.36.8.40', '10.36.8.41'],
    'DEBUG': True
}

# Configurable as shell vars start

# TEMPLATE_FILE = os.environ.get("TEMPLATE_FILE", "./cluster.yml")
# HOSTPAHT_DEV = os.environ.get("HOSTPATH_DEV", "sdb")
# CEPH_DEV = os.environ["CEPH_DEV", "sdc"]
# DEBUG = os.environ.get("DEBUG", True)
# SSH_PORT = os.environ.get("SSH_PORT", 22)
# SSH_PASS = os.environ.get("SSH_PASS", 123456)
# INTERFACE = os.environ.get("INTERFACE", 'eth0')
# Reconfigures cluster distribution at scale
with open(var_dic['TEMPLATE_FILE'], encoding='utf-8') as rf:
    template_content = yaml.load(rf)
pattern = re.compile(r'(\d+):(\d+)')
# Configurable as shell vars end


class KubesprayInventory(object):

    def __init__(self, hosts_dirty=None):
        self.host_ip = []
        self.master_list = []
        self.etcd_init_servers = []
        self.ntp_oraphan_parents = []
        self.hanode_list = []
        self.flannel_etcd_list = []
        self.hostpath_list = []
        for ips in hosts_dirty:
            self.valid_ip(ips)
            # 10.19.140.6
            if ips.split('.')[-1:][0].isdigit() and 0 < int(ips.split('.')[-1:][0]) < 255:
                self.appendIp_toList(ips)
            elif pattern.match(ips.split('.')[-1:][0]):
                self.appendRange_toList(ips)
            else:
                self.debug("invalid ip or range: {0}".format(ips.split('.')[-1:]))
                sys.exit(0)
        self.how_allot(self.host_ip)
        if not var_dic['HA_VIP']:
            var_dic['HA_VIP'] = self.master_list[0]
        self.template_yaml()
        print(template_content)
        self.write_yaml(template_content)


    def template_yaml(self):
        hosts_part = template_content.get('all').get('children')
        vars_part = template_content.get('all').get('vars')
        hosts_part.get('centos')['hosts'] = {}
        # template ip to hosts
        for ip in self.host_ip:
            hosts_part.get('centos')['hosts'][ip] = None
        hosts_part.get('centos').get('vars')['ansible_ssh_pass'] = var_dic['SSH_PASS']
        hosts_part.get('centos').get('vars')['ansible_ssh_port'] = var_dic['SSH_PORT']
        hosts_part.get('centos').get('vars')['special_mounts'] = {}
        for i, dev in enumerate(var_dic['HOSTPAHT_DEV']):
            hosts_part.get('centos').get('vars').get('special_mounts')['/dev/'+dev] = {'opt': 'prjquota', 'path': '/xfs/disk'+str(i+1)}
        # template var to vars
        vars_part['etcd_init_servers'] = self.etcd_init_servers
        vars_part['flannel_etcd_list'] = self.flannel_etcd_list
        vars_part['hanode_list'] = self.hanode_list
        vars_part['host_path_list'] = self.hostpath_list
        vars_part['master_list'] = self.master_list
        vars_part['ntp_orphan_parents'] = self.ntp_oraphan_parents
        vars_part['mon_list'] = copy.copy(self.host_ip)
        vars_part['osd_list'] = copy.copy(self.host_ip)
        vars_part['cluster_ip_range'], vars_part['flanneld_subnet'] = self.get_svc_pod_ip()
        vars_part['ceph_cluster_network'] = vars_part['ceph_public_network'] = self.get_ceph_network()
        vars_part['ca_vip'] = var_dic['HA_VIP']
        vars_part['kl_interface'] = var_dic['INTERFACE']
        vars_part['rbd_dev_list'] = var_dic['CEPH_DEV']
        vars_part['searchdomains'] = var_dic['SEARCHDOMAIN']
        vars_part['nameservers'] = var_dic['NAMESERVERS']

    def get_svc_pod_ip(self):
        sub = int(self.host_ip[0].split('.')[0])
        if sub < 172:
            return '192.168.0.0/16', '172.16.0.0/24'
        elif 172 <= sub < 192:
            return '10.254.0.0/16', '192.168.0.0/24'
        else:
            return '10.254.0.0/16', '172.16.0.0/24'

    def get_ceph_network(self):
        return '.'.join(self.host_ip[0].split('.')[:3])+'.0/24'

    def valid_ip(self, ip):
        for part in ip.split('.')[:-1]:
            if part.isdigit() and 0 < int(part) < 255:
                continue
            else:
                self.debug("invalid input ip: {0}".format(ip))
                sys.exit(0)

    def appendIp_toList(self, ip):
        self.host_ip.append(ip)

    def appendRange_toList(self, ip_range):
        last_part = ip_range.split('.')[-1:][0].split(':')
        for r in range(int(last_part[0]), int(last_part[1])+1):
            self.host_ip.append('.'.join(ip_range.split('.')[:-1]) + '.' + str(r))

    def debug(self, msg):
        if var_dic['DEBUG']:
            print("DEBUG: {0}".format(msg))

    def how_allot(self, host_list):
        scale = len(host_list)
        if scale > 5:
            self.debug("cluster with {0} hosts, etcds for k8s are on different hosts from etcds for flannel".format(scale))
            self.master_list = host_list[:3]
            self.etcd_init_servers = host_list[:3]
            self.flannel_etcd_list = host_list[3:6]
            self.hanode_list = host_list[3:5]
            self.hostpath_list = host_list
            self.ntp_oraphan_parents = host_list[:2]
        elif scale == 5:
            self.debug("cluster with {0} hosts, 3 masters, 2 HA nodes, 1 etcd cluster".format(scale))
            self.master_list = host_list[:3]
            self.etcd_init_servers = host_list[:3]
            self.flannel_etcd_list = host_list[:3]
            self.hanode_list = host_list[3:]
            self.hostpath_list = host_list
            self.ntp_oraphan_parents = host_list[:2]
        elif 5 > scale >= 3:
            self.debug("cluster with {0} hosts, 3 masters, 1 etcd cluster".format(scale))
            self.master_list = host_list[:3]
            self.etcd_init_servers = host_list[:3]
            self.flannel_etcd_list = host_list[:3]
            self.hostpath_list = host_list
            self.ntp_oraphan_parents = host_list[:2]
        else:
            self.debug("too few hosts provide: {0}".format(scale))
            sys.exit(0)


    def write_yaml(self, content):
        with open(var_dic['PLATFROM_FILE'], 'w') as wf:
            yaml.safe_dump(content, wf, encoding="utf-8", allow_unicode=True)

#
#     def parse_command(self, command, args=None):
#         if command == 'help':
#             self.show_help()
#         elif command == 'print_cfg':
#             self.print_config()
#         elif command == 'print_ips':
#             self.print_ips()
#         elif command == 'load':
#             self.load_file(args)
#         else:
#             raise Exception("Invalid command specified.")
#
#     def show_help(self):
#         help_text = '''Usage: inventory.py ip1 [ip2 ...]
# Examples: inventory.py 10.10.1.3 10.10.1.4 10.10.1.5
#
# Available commands:
# help - Display this message
# print_cfg - Write inventory file to stdout
# print_ips - Write a space-delimited list of IPs from "all" group
#
# Advanced usage:
# Add another host after initial creation: inventory.py 10.10.1.5
# Delete a host: inventory.py -10.10.1.3
# Delete a host by id: inventory.py -node1
#
# Configurable env vars:
# DEBUG                   Enable debug printing. Default: True
# CONFIG_FILE             File to write config to Default: ./inventory/sample/hosts.ini
# HOST_PREFIX             Host prefix for generated hosts. Default: node
# SCALE_THRESHOLD         Separate ETCD role if # of nodes >= 50
# MASSIVE_SCALE_THRESHOLD Separate K8s master and ETCD if # of nodes >= 200
# '''
#         print(help_text)
#
#     def print_config(self):
#         self.config.write(sys.stdout)
#
#     def print_ips(self):
#         ips = []
#         for host, opts in self.config.items('all'):
#             ips.append(self.get_ip_from_opts(opts))
#         print(' '.join(ips))


def main(argv=None):
    if not argv:
        argv = sys.argv[1:]
    KubesprayInventory(argv)

if __name__ == "__main__":
    sys.exit(main())
