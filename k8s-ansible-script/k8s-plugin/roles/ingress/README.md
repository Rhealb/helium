Role Name
=========

ingress-controller and dns-controller deployment role

Requirements
------------
这个role只能完成ingress-controller and dns-controller　pod的配置和部署，外部环境的配置需要手工完成

    1.{{ ingress_export_ip }},默认为集群vip
    2.在dns中添加{{ ingress_dns_domain }}这个域名的NS记录到{{ ingress_export_ip }} 来解析
    3.配置{{ ingress_export_ip }}到集群vip的映射

Role Variables
--------------
ingress_backend_image

dns_controller_image

nginx_ingress_image

ingress_dns_domain

ingress_export_ip

Dependencies
------------


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
