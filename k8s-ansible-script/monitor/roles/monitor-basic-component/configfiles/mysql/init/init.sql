-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 10.19.140.200:31036
-- Generation Time: 2017-07-03 07:30:40
-- 服务器版本： 5.7.18
-- PHP Version: 7.0.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `grafana`
--
CREATE DATABASE IF NOT EXISTS `grafana` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

--
-- Database: `osticket`
--
CREATE DATABASE IF NOT EXISTS `osticket` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

--
-- Database: `prometheus`
--
CREATE DATABASE IF NOT EXISTS `prometheus` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE `prometheus`;

--
-- 表的结构 `alerts`
--

CREATE TABLE `alerts` (
  `id` int(11) NOT NULL,
  `_from` varchar(20) NOT NULL DEFAULT 'default' COMMENT '来自哪个渠道的报警',
  `status` varchar(20) NOT NULL,
  `cluster` varchar(20) NOT NULL,
  `namespace` varchar(50) NOT NULL,
  `type` varchar(20) NOT NULL,
  `alertname` varchar(20) NOT NULL DEFAULT 'unknown',
  `instance` varchar(100) NOT NULL,
  `fingerprint` bigint(64) UNSIGNED NOT NULL COMMENT '根据labelset生成',
  `labels` varchar(1024) NOT NULL,
  `annotations` text NOT NULL,
  `starts_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ends_at` datetime DEFAULT '0001-01-01 00:00:00',
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `alerts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fingerprint` (`fingerprint`),
  ADD KEY `starts_at` (`starts_at`),
  ADD KEY `ends_at` (`ends_at`),
  ADD KEY `cluster-namespace` (`cluster`),
  ADD KEY `_from` (`_from`);

ALTER TABLE `alerts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;COMMIT;

  --
  -- 表的结构 `clusters`
  --

  CREATE TABLE `clusters` (
    `id` int(11) NOT NULL,
    `name` varchar(255) DEFAULT NULL,
    `status` int(11) DEFAULT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  --
  -- 转存表中的数据 `clusters`
  --

  INSERT INTO `clusters` (`id`, `name`, `status`) VALUES
  (1, '{{ cluster_name }}', 0);

  --
  -- Indexes for dumped tables
  --

  --
  -- Indexes for table `clusters`
  --
  ALTER TABLE `clusters`
    ADD PRIMARY KEY (`id`);

  --
  -- 在导出的表使用AUTO_INCREMENT
  --

  --
  -- 使用表AUTO_INCREMENT `clusters`
  --
  ALTER TABLE `clusters`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;COMMIT;

  --
  -- 表的结构 `bizlines`
  --

  CREATE TABLE `bizlines` (
    `id` int(11) NOT NULL,
    `name` varchar(255) DEFAULT NULL,
    `status` int(11) DEFAULT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  --
  -- 转存表中的数据 `bizlines`
  --

  INSERT INTO `bizlines` (`id`, `name`, `status`) VALUES
  (1, 'common', 0),
  (2, 'bigdata', 0),
  (3, 'console', 0),
  (4, 'k8s', 0),
  (5, 'ops', 0),
  (6, 'ml', 0),
  (7, 'monitor', 0);

  --
  -- Indexes for dumped tables
  --

  --
  -- Indexes for table `bizlines`
  --
  ALTER TABLE `bizlines`
    ADD PRIMARY KEY (`id`);

  --
  -- 在导出的表使用AUTO_INCREMENT
  --

  --
  -- 使用表AUTO_INCREMENT `bizlines`
  --
  ALTER TABLE `bizlines`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;COMMIT;


  CREATE TABLE `scripts` (
    `id` int(11) NOT NULL,
    `type` varchar(255) DEFAULT NULL,
    `name` varchar(255) DEFAULT NULL,
    `filename` varchar(255) DEFAULT NULL,
    `description` varchar(255) DEFAULT NULL,
    `status` int(11) DEFAULT NULL,
    `created_at` timestamp NULL DEFAULT NULL,
    `updated_at` timestamp NULL DEFAULT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  --
  -- 转存表中的数据 `scripts`
  --

  INSERT INTO `scripts` (`id`, `type`, `name`, `filename`, `description`, `status`, `created_at`, `updated_at`) VALUES
  (1, 'check', 'check_service_status.sh', 'script.sh.1526389904840133049', 'check service status by curl and nc', 0, null, null),
  (2, 'check', 'check_prometheus_status.sh', 'script.sh.1526436540627334622', 'check prometheus status', 0, null, null),
  (3, 'check', 'check_hdfs_status.sh', 'script.sh.1526440272893725262', 'check hdfs status', 0, null, null),
  (4, 'check', 'check_ceph_clock_status.sh', 'script.sh.1526465658056343383', 'check ceph clock', 0, null, null),
  (6, 'check', 'check_mongo_status.sh', '', 'check mongo status', 0, null, null),
  (7, 'check', 'check_opentsdb_status.sh', 'script.sh.1526475124027445158', 'check opentsdb status', 0, null, null),
  (8, 'check', 'check_hbase_status.sh', 'script.sh.1526475538856661384', 'check hbase status', 0, null, null),
  (9, 'check', 'check_zookeeper_status.sh', 'script.sh.1526475864259316034', 'check zookeeper status', 0, null, null),
  (10, 'check', 'check_kafka_status.sh', 'script.sh.1526476346015010197', 'check kafka status', 0, null, null),
  (11, 'check', 'check_spark_status.sh', 'script.sh.1526537936926726843', 'check spark status', 0, null, null),
  (12, 'check', 'check_spark_job.sh', 'script.sh.1526538871388057655', 'check spark job', 0, null, null),
  (13, 'check', 'check_mongo_rs_status.sh', 'script.sh.1526543908076885780', 'check mongo replicaset status', 0, null, null),
  (14, 'check', 'fping.sh', 'script.sh.1526551526117540282', 'fping', 0, null, null),
  (15, 'check', 'check_Druid_status.sh', 'script.sh.1526611818470622160', 'check Druid status', 0, null, null),
  (16, 'check', 'check_rm_status.sh', 'script.sh.1526612395472252698', 'check rm status', 0, null, null),
  (17, 'check', 'check_impala_cluster_status.sh', 'script.sh.1526613115379119750', 'check impala cluster status', 0, null, null),
  (18, 'check', 'check_mysql_status.sh', 'script.sh.1526613823897417428', 'check mysql status', 0, null, null);

  --
  -- Indexes for dumped tables
  --

  --
  -- Indexes for table `scripts`
  --
  ALTER TABLE `scripts`
    ADD PRIMARY KEY (`id`);

  --
  -- 在导出的表使用AUTO_INCREMENT
  --

  --
  -- 使用表AUTO_INCREMENT `scripts`
  --
  ALTER TABLE `scripts`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;COMMIT;

    --
  -- 表的结构 `service_check_configs`
  --

  CREATE TABLE `service_check_configs` (
    `id` int(11) NOT NULL,
    `cluster` varchar(255) DEFAULT NULL,
    `bizline` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
    `name` varchar(255) DEFAULT NULL,
    `description` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
    `script_id` int(11) DEFAULT NULL,
    `timeout` int(11) DEFAULT NULL,
    `args` varchar(512) CHARACTER SET latin1 DEFAULT NULL,
    `automation` int(11) DEFAULT NULL,
    `extra_tags` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
    `status` int(11) DEFAULT NULL,
    `created_at` timestamp NULL DEFAULT NULL,
    `updated_at` timestamp NULL DEFAULT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  --
  -- 转存表中的数据 `service_check_configs`
  --

  INSERT INTO `service_check_configs` (`id`, `cluster`, `bizline`, `name`, `description`, `script_id`, `timeout`, `args`, `automation`, `extra_tags`, `status`, `created_at`, `updated_at`) VALUES
  (1, '{{ cluster_name }}', 'k8s', 'apiserver', '', 1, 6, '-servicename apiserver -username {{ admin_username }} -password {{ admin_password }} -IP {{ ca_vip }} -PORT 6442 -ishttps 1 -getdatamethod curl', 0, '', 0, null, null),
  (2, '{{ cluster_name }}', 'k8s', 'harbor', '', 1, 6, '-servicename harbor -IP harbor-proxy.system-tools -PORT 80 -getdatamethod curl', 0, '', 0, null, null),
  (3, '{{ cluster_name }}', 'k8s', 'ceph', '', 1, 6, '-servicename ceph -IP ceph-rest.ceph -PORT 5000 -getdatamethod curl -restfulapi /api/v0.1/health -checkjsonfield 1 -OK \'HEALTH_OK\' -WARNING \'HEALTH_WARN\'', 0, '', 0, null, null),
  (4, '{{ cluster_name }}', 'console', 'keycloak', '', 1, 6, '-servicename Keycloak -IP keycloak.console -PORT 8080 -getdatamethod curl -restfulapi /auth/realms/console-sso/protocol/openid-connect/token -curlpostdata \'client_id=ennctl&grant_type=password&username=admin&password={{ keystone_admin_password }}\' -header \'Content-Type:application/x-www-form-urlencoded\'', 0, '', 0, null, null),
  (5, '{{ cluster_name }}', 'monitor', 'mongo', '', 6, 6, '-H mongo.monitor-essential-service -P 27017', 0, '', 0, null, null),
  (6, '{{ cluster_name }}', 'k8s', 'ldap', '', 1, 6, '-servicename ldap -IP ldaps-ha-svc.system-tools -PORT 389 -getdatamethod ldapsearch', 0, '', 0, null, null),
  (7, '{{ cluster_name }}', 'console', 'console', '', 1, 6, '-servicename console -IP cc-gateway.system-tools -PORT 8810 -getdatamethod curl -restfulapi /gw/wt/api/v1/health/console -checkjsonfield 1 -OK \'"status":"UP"\' -CRITICAL \'"status":"DOWN"\'', 0, '', 0, null, null),
  (8, '{{ cluster_name }}', 'monitor', 'elasticsearch', '', 1, 10, '-servicename elasticsearch -IP pre1-esclient-ex.monitor-essential-service -PORT 9200 -getdatamethod curl -restfulapi /_cluster/health -checkjsonfield 1 -OK \'"status":"green"\' -WARNING \'"status":"yellow"\' -CRITICAL \'"status":"red"\'', 0, '', 0, null, null),
  (9, '{{ cluster_name }}', 'bigdata', 'hdfs', '', 3, 15, '-H1 pre1-namenode1.monitor-essential-service:50070 -H2 pre1-namenode2.monitor-essential-service:50070 -F {{ cluster_name }} -l 3', 0, '', 0, null, null),
  (10, '{{ cluster_name }}', 'bigdata', 'zookeeper', '', 9, 15, '-H pre1-zookeeper1.monitor-essential-service:2181,pre1-zookeeper2.monitor-essential-service:2181,pre1-zookeeper3.monitor-essential-service:2181', 0, '', 0, null, null),
  (11, '{{ cluster_name }}', 'monitor', 'prometheus', '', 1, 10, '-IP prometheus-engine.monitor-application -PORT 9090', 0, '', 0, null, null),
  (12, '{{ cluster_name }}', 'bigdata', 'opentsdb', '', 1, 10, '-IP pre1-opentsdb-ex.monitor-essential-service -PORT 4242', 0, '', 0, null, null),
  (13, '{{ cluster_name }}', 'bigdata', 'spark', '', 11, 15, '-H pre1-master1.monitor-essential-service:8080,pre1-master2.monitor-essential-service:8080,pre1-master3.monitor-essential-service:8080', 0, '', 0, null, null),
  (14, '{{ cluster_name }}', 'bigdata', 'kibana', '', 1, 7, '-servicename kibana -IP kibana-logging.monitor-application -PORT 29304 -getdatamethod curl -restfulapi /api/status -checkjsonfield 1 -OK \'"status":{"overall":{"state":"green"\'', 0, '', 0, null, null),
  (15, '{{ cluster_name }}', 'k8s', 'ldap_registry', '', 1, 6, '-servicename ldapregistry -IP ldap-register-svc.system-tools -PORT 80 -getdatamethod curl -restfulapi /', 0, '', 0, null, null),
  (16, '{{ cluster_name }}', 'monitor', 'monitor_frontend', '', 1, 6, '-IP cc-lmd.console -PORT 4200 -getdatamethod curl -restfulapi /', 0, '', 0, null, null),
  (17, '{{ cluster_name }}', 'bigdata', 'hbase', '', 8, 15, '-H1 pre1-hmaster1.monitor-essential-service:16010 -H2 pre1-hmaster2.monitor-essential-service:16010 -H3 pre1-hmaster3.monitor-essential-service:16010 -l 3', 0, '', 0, null, null),
  (18, '{{ cluster_name }}', 'monitor', 'mock_server', '', 1, 10, '-IP mock-server.monitor-application -PORT 8001 -getdatamethod curl -restfulapi /health -checkjsonfield 1 -OK \'Healthy\'', 0, '', 0, null, null);

  --
  -- Indexes for dumped tables
  --

  --
  -- Indexes for table `service_check_configs`
  --
  ALTER TABLE `service_check_configs`
    ADD PRIMARY KEY (`id`);

  --
  -- 在导出的表使用AUTO_INCREMENT
  --

  --
  -- 使用表AUTO_INCREMENT `service_check_configs`
  --
  ALTER TABLE `service_check_configs`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;COMMIT;
