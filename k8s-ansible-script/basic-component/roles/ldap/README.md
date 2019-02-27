Role Name
=========

ldap

Requirements
------------

1. modify env in vars/main.yml, such as docker image of ldap and haproxy, harbor connection info

2. prepare images in {base_dir}/files

   Dokckerfiles are here:
   https://10.19.248.200:30883/shanghai-dev/ldaps

3. require variable "mon_list" if using ceph, "ldap_password", "nfs_host", "nfs_path" if using aliyun cloud nfs defined in group_vars/all


Dependencies
------------

system-role to create namespace "system-tools"
ceph secret if use ceph

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: all
      roles:
         - ldap

License
-------

BSD

Author Information
------------------

Terry