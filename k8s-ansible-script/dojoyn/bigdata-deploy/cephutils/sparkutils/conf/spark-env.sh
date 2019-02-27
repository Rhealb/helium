export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER -Dspark.deploy.zookeeper.url=%BD_ZOOKEEPER_SERVERS% -Dspark.deploy.zookeeper.dir=/spark"
export SPARK_LOCAL_DIRS="/tmp/local/dir1"
export SPARK_NO_DAEMONIZE=true
export SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=%BD_ENENTLOG_DIR% -Dspark.history.ui.port=18080 -Dspark.history.retainedApplications=10"
export SPARK_WORKER_OPTS="-Dspark.worker.cleanup.enabled=true -Dspark.worker.cleanup.interval=1800 -Dspark.worker.cleanup.appDataTtl=86400" 
