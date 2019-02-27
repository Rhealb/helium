#!bin/bash 
# this script is used to uninstall console

cd /console/cc-devop/install/console
kubectl delete -f console-basic-specicifation.json
kubectl delete -f basic-specicifation.json 
iskilled=$(kubectl get ns | grep console) 
while [[ !  -z  $iskilled  ]]
do
  echo "$iskilled"
  echo "sleep 10 second"
  sleep 10
  iskilled=$(kubectl get ns | grep console) 
done
echo "clean ceph image and pools"
rbd rm k8s.console/mysql
ceph osd pool delete k8s.console  k8s.console --yes-i-really-really-mean-it
echo "console clean successful"