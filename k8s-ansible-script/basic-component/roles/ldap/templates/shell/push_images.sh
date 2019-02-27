#!/bin/bash

echo "nosense" | docker login -uadmin -p{{ harbor_admin_password }} {{ registry_url }}
docker push {{ registry_url }}/{{ ldap_image_url }}
docker push {{ registry_url }}/{{ haproxy_image_url }}
docker push {{ registry_url }}/{{ ldap_register_image }}
