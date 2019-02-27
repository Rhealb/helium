#!/bin/bash

echo "nonsense" | docker login -uadmin -p{{ harbor_admin_password }} {{ registry_url }}
docker push {{ registry_url }}/{{ scaler_image_url }}
docker push {{ registry_url }}/{{ monitor_image_url }}