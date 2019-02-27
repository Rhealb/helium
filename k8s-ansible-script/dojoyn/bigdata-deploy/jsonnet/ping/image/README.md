##### build dockerfile should have kafka2hdfs.tar.gz

```
git clone ssh://git@gitlab.cloud.enndata.cn:10885/ping/kafka2hdfs.git
```
##### into project director:

```
mvn package
```
##### after package, you should pack three directories(conf,sbin,lib) and kafka2hdfs.jar to ping.tar.gz

```
cd target
tar -zcf ping.tar.gz conf sbin lib kafka2hdfs.jar
```
