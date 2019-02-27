{
   "apiVersion": "v1",
   "kind": "Namespace",
   "metadata": {
       // you will create namespace name
      "name": "bigdata-jsonnet"
   },
   "spec": {
      // whether to allow Priority scheduling  
      "allowCriticalPod": true,
  
      // whether to allow use hostpath
      "allowHostpath": true,

      // whether to use privilege mode
      "allowPrivilege": true,

      // ldap username, should have system administrator privilieges
      "nsadmin": [
         "bigdata-jsonnet"
      ],
      "resources": {
         "limits": {
            "cpu": 10,
            "memory": "10Gi"
         },
         "requests": {
            "cpu": 10,
            "memory": "10Gi",

            // hostpath storage size
            "localStorage": "10Gi",

            // distributed storage storage size
            "remoteStorage": "10Gi"
         }
      }
   }
}
