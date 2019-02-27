### hostname configuration in k8s
```json
  spec: {
   template: {
     ...
     spec: {
       hostname: "hostname",
       ...
     }
   }

  }
```
##### zookeeper
zk have to use hostname configuration. Because in zookeeper config file(server.properities), Part of the configuration file like this:
```
server.1=pre1-zookeeper1:2888:3888:participant
server.2=pre1-zookeeper2:2888:3888:participant
server.3=pre1-zookeeper3:2888:3888:participant

```
when it starting, zk try to bind port 2888 and 3888 for pre1-zookeeper1, when you not set hostname, zk will failed to bind port, because zk query dns server, find the pre1-zookeeper1 corresponding ip address is IP1, but the ip address is for service，causes bind to fail.

##### namenode in hdfs
namenode have to use hostname configuration. The reason is same to zk(port bind fail). part of config file(hdfs-site.xml) like this:
```
<property>
    <name>dfs.namenode.rpc-address.enncloud-hadoop.nn1</name>
    <value>pre1-namenode1:8020</value>
  </property>
  <property>
    <name>dfs.namenode.rpc-address.enncloud-hadoop.nn2</name>
    <value>pre1-namenode2:8020</value>
  </property>
  <property>
    <name>dfs.namenode.http-address.enncloud-hadoop.nn1</name>
    <value>pre1-namenode1:50070</value>
  </property>
  <property>
    <name>dfs.namenode.http-address.enncloud-hadoop.nn2</name>
    <value>pre1-namenode2:50070</value>
  </property>

```
##### resourcemanager in yarn
reason same as namenode. part of the config file(yarn-site.xml) like this:
```
<property>
    <name>yarn.resourcemanager.webapp.address.rm1</name>
    <value>pre1-resourcemanager1:8088</value>
  </property>
  <property>
    <name>yarn.resourcemanager.webapp.address.rm2</name>
    <value>pre1-resourcemanager2:8088</value>
  </property>
  <property>
    <name>yarn.resourcemanager.webapp.https.address.rm1</name>
    <value>pre1-resourcemanager1:8090</value>
  </property>
  <property>
    <name>yarn.resourcemanager.webapp.https.address.rm2</name>
    <value>pre1-resourcemanager2:8090</value>
  </property>

```

##### mrjobhistory in yarn
mrjobhistory must to use hostname configuration, if you not use, mrjobhistory will threw a non Bind IOException. mrjobhistory should bind port 19888, if not use hostname configuration, will bind pre1-mrjobhistory:19888, the pre1-mrjobhistory is service name, not hostname

##### hmater in hbase
hmaster also have to use hostname configuration , regionserver find the hmaster through zookeeper, hmaster register own hostname into zookeeper, if not use hostname configuration, the hostname form like pre1-hmater1-xxx-xxx, when regionserver try to access this domain name，causes UnknowhsotnameError. but if use poddns for hmaster, hbase also can work.
