#!/bin/bash

echo "nonsense" | docker login -uadmin -p{{ harbor_admin_password }} {{ registry_url }}
docker push {{ registry_url }}/{{ nfs_image_url }}