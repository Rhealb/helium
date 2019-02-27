#!/bin/bash

echo "nonsense" | docker login -uadmin -p{{ harbor_admin_password }} {{ registry_url }}
docker push {{ registry_url }}/{{ csi_attacher_image_url }}
docker push {{ registry_url }}/{{ driver_registrar_image_url }}
docker push {{ registry_url }}/{{ hostpathcsi_image_url }}