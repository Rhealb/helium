-- MySQL dump 10.13  Distrib 5.7.20, for Linux (x86_64)
--
-- Host: localhost    Database: keystone
-- ------------------------------------------------------
-- Server version	5.7.20-0ubuntu0.16.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT = @@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS = @@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION = @@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE = @@TIME_ZONE */;
/*!40103 SET TIME_ZONE = '+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS, UNIQUE_CHECKS = 0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0 */;
/*!40101 SET @OLD_SQL_MODE = @@SQL_MODE, SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES = @@SQL_NOTES, SQL_NOTES = 0 */;

--
-- Table structure for table `access_token`
--

DROP TABLE IF EXISTS `access_token`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_token` (
  `id`                  VARCHAR(64) NOT NULL,
  `access_secret`       VARCHAR(64) NOT NULL,
  `authorizing_user_id` VARCHAR(64) NOT NULL,
  `project_id`          VARCHAR(64) NOT NULL,
  `role_ids`            TEXT        NOT NULL,
  `consumer_id`         VARCHAR(64) NOT NULL,
  `expires_at`          VARCHAR(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_access_token_consumer_id` (`consumer_id`),
  KEY `ix_access_token_authorizing_user_id` (`authorizing_user_id`),
  CONSTRAINT `access_token_ibfk_1` FOREIGN KEY (`consumer_id`) REFERENCES `consumer` (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `access_token`
--

LOCK TABLES `access_token` WRITE;
/*!40000 ALTER TABLE `access_token`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `access_token`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignment`
--

DROP TABLE IF EXISTS `assignment`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assignment` (
  `type`      ENUM ('UserProject', 'GroupProject', 'UserDomain', 'GroupDomain') NOT NULL,
  `actor_id`  VARCHAR(64)                                                       NOT NULL,
  `target_id` VARCHAR(64)                                                       NOT NULL,
  `role_id`   VARCHAR(64)                                                       NOT NULL,
  `inherited` TINYINT(1)                                                        NOT NULL,
  PRIMARY KEY (`type`, `actor_id`, `target_id`, `role_id`, `inherited`),
  KEY `ix_actor_id` (`actor_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignment`
--

LOCK TABLES `assignment` WRITE;
/*!40000 ALTER TABLE `assignment`
  DISABLE KEYS */;
INSERT INTO `assignment`
VALUES ('UserProject', '{{ keystone_admin_username }}', '067b4cc5ce1c4a36aef356ff40bc33c0', 'bad4a67b13974269968a9e439aa429e9', 0),
  ('UserProject', '{{ keystone_admin_username }}', '20e01203b97349ecbac8d7d2257b00ab', 'bad4a67b13974269968a9e439aa429e9', 0),
  ('UserProject', '{{ keystone_admin_username }}', '377bae08c4a74681be99e18fbd9a586f', 'bad4a67b13974269968a9e439aa429e9', 0),
  ('UserProject', '{{ keystone_admin_username }}', '40e48a4b7f574b249a8697f0b695529e', 'bad4a67b13974269968a9e439aa429e9', 0),
  ('UserProject', '{{ keystone_admin_username }}', '4ee23d1bb5b64c8b91b2c3409f2fcfdf', '1caa894228ce467f9ddedaa8701862e6', 0),
  ('UserDomain', '{{ keystone_admin_username }}', 'default', '56fde862ae3a48d7a8ec0ee3aa2bfe43', 0);
/*!40000 ALTER TABLE `assignment`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config_register`
--

DROP TABLE IF EXISTS `config_register`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config_register` (
  `type`      VARCHAR(64) NOT NULL,
  `domain_id` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`type`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_register`
--

LOCK TABLES `config_register` WRITE;
/*!40000 ALTER TABLE `config_register`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `config_register`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consumer`
--

DROP TABLE IF EXISTS `consumer`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `consumer` (
  `id`          VARCHAR(64) NOT NULL,
  `description` VARCHAR(64) DEFAULT NULL,
  `secret`      VARCHAR(64) NOT NULL,
  `extra`       TEXT        NOT NULL,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consumer`
--

LOCK TABLES `consumer` WRITE;
/*!40000 ALTER TABLE `consumer`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `consumer`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credential`
--

DROP TABLE IF EXISTS `credential`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credential` (
  `id`         VARCHAR(64)  NOT NULL,
  `user_id`    VARCHAR(64)  NOT NULL,
  `project_id` VARCHAR(64) DEFAULT NULL,
  `blob`       TEXT         NOT NULL,
  `type`       VARCHAR(255) NOT NULL,
  `extra`      TEXT,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `credential`
--

LOCK TABLES `credential` WRITE;
/*!40000 ALTER TABLE `credential`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `credential`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `domain`
--

DROP TABLE IF EXISTS `domain`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domain` (
  `id`      VARCHAR(64) NOT NULL,
  `name`    VARCHAR(64) NOT NULL,
  `enabled` TINYINT(1)  NOT NULL,
  `extra`   TEXT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ixu_domain_name` (`name`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domain`
--

LOCK TABLES `domain` WRITE;
/*!40000 ALTER TABLE `domain`
  DISABLE KEYS */;
INSERT INTO `domain` VALUES ('<<keystone.domain.root>>', '<<keystone.domain.root>>', 0, '{}');
/*!40000 ALTER TABLE `domain`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `endpoint`
--

DROP TABLE IF EXISTS `endpoint`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `endpoint` (
  `id`                 VARCHAR(64) NOT NULL,
  `legacy_endpoint_id` VARCHAR(64)          DEFAULT NULL,
  `interface`          VARCHAR(8)  NOT NULL,
  `service_id`         VARCHAR(64) NOT NULL,
  `url`                TEXT        NOT NULL,
  `extra`              TEXT,
  `enabled`            TINYINT(1)  NOT NULL DEFAULT '1',
  `region_id`          VARCHAR(255)         DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `service_id` (`service_id`),
  KEY `fk_endpoint_region_id` (`region_id`),
  CONSTRAINT `endpoint_service_id_fkey` FOREIGN KEY (`service_id`) REFERENCES `service` (`id`),
  CONSTRAINT `fk_endpoint_region_id` FOREIGN KEY (`region_id`) REFERENCES `region` (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `endpoint`
--

LOCK TABLES `endpoint` WRITE;
/*!40000 ALTER TABLE `endpoint`
  DISABLE KEYS */;
INSERT INTO `endpoint` VALUES
  ('0abb477c1c1843ecbe49107d9767f391', NULL, 'public', '9490c4206b7b4702afb59f7d9362cd68', '{{ keystone_url }}', '{}',
   1, NULL),
  ('5ff321d0584f40bf85e7743aa09905fc', NULL, 'internal', '9490c4206b7b4702afb59f7d9362cd68', '{{ keystone_url }}', '{}',
   1, NULL),
  ('80af356dbd784280b68bf4eff6d1e8bc', NULL, 'admin', '9490c4206b7b4702afb59f7d9362cd68', '{{ keystone_url }}', '{}', 1,
   NULL);
/*!40000 ALTER TABLE `endpoint`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `endpoint_group`
--

DROP TABLE IF EXISTS `endpoint_group`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `endpoint_group` (
  `id`          VARCHAR(64)  NOT NULL,
  `name`        VARCHAR(255) NOT NULL,
  `description` TEXT,
  `filters`     TEXT         NOT NULL,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `endpoint_group`
--

LOCK TABLES `endpoint_group` WRITE;
/*!40000 ALTER TABLE `endpoint_group`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `endpoint_group`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `federated_user`
--

DROP TABLE IF EXISTS `federated_user`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `federated_user` (
  `id`           INT(11)      NOT NULL AUTO_INCREMENT,
  `user_id`      VARCHAR(64)  NOT NULL,
  `idp_id`       VARCHAR(64)  NOT NULL,
  `protocol_id`  VARCHAR(64)  NOT NULL,
  `unique_id`    VARCHAR(255) NOT NULL,
  `display_name` VARCHAR(255)          DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idp_id` (`idp_id`, `protocol_id`, `unique_id`),
  KEY `user_id` (`user_id`),
  KEY `federated_user_protocol_id_fkey` (`protocol_id`, `idp_id`),
  CONSTRAINT `federated_user_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `federated_user_ibfk_2` FOREIGN KEY (`idp_id`) REFERENCES `identity_provider` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `federated_user_protocol_id_fkey` FOREIGN KEY (`protocol_id`, `idp_id`) REFERENCES `federation_protocol` (`id`, `idp_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `federated_user`
--

LOCK TABLES `federated_user` WRITE;
/*!40000 ALTER TABLE `federated_user`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `federated_user`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `federation_protocol`
--

DROP TABLE IF EXISTS `federation_protocol`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `federation_protocol` (
  `id`         VARCHAR(64) NOT NULL,
  `idp_id`     VARCHAR(64) NOT NULL,
  `mapping_id` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`id`, `idp_id`),
  KEY `idp_id` (`idp_id`),
  CONSTRAINT `federation_protocol_ibfk_1` FOREIGN KEY (`idp_id`) REFERENCES `identity_provider` (`id`)
    ON DELETE CASCADE
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `federation_protocol`
--

LOCK TABLES `federation_protocol` WRITE;
/*!40000 ALTER TABLE `federation_protocol`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `federation_protocol`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group`
--

DROP TABLE IF EXISTS `group`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group` (
  `id`          VARCHAR(64) NOT NULL,
  `domain_id`   VARCHAR(64) NOT NULL,
  `name`        VARCHAR(64) NOT NULL,
  `description` TEXT,
  `extra`       TEXT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ixu_group_name_domain_id` (`domain_id`, `name`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group`
--

LOCK TABLES `group` WRITE;
/*!40000 ALTER TABLE `group`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `group`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `id_mapping`
--

DROP TABLE IF EXISTS `id_mapping`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `id_mapping` (
  `public_id`   VARCHAR(64)            NOT NULL,
  `domain_id`   VARCHAR(64)            NOT NULL,
  `local_id`    VARCHAR(64)            NOT NULL,
  `entity_type` ENUM ('user', 'group') NOT NULL,
  PRIMARY KEY (`public_id`),
  UNIQUE KEY `domain_id` (`domain_id`, `local_id`, `entity_type`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `id_mapping`
--

LOCK TABLES `id_mapping` WRITE;
/*!40000 ALTER TABLE `id_mapping`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `id_mapping`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identity_provider`
--

DROP TABLE IF EXISTS `identity_provider`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `identity_provider` (
  `id`          VARCHAR(64) NOT NULL,
  `enabled`     TINYINT(1)  NOT NULL,
  `description` TEXT,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_provider`
--

LOCK TABLES `identity_provider` WRITE;
/*!40000 ALTER TABLE `identity_provider`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `identity_provider`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idp_remote_ids`
--

DROP TABLE IF EXISTS `idp_remote_ids`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `idp_remote_ids` (
  `idp_id`    VARCHAR(64) DEFAULT NULL,
  `remote_id` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`remote_id`),
  KEY `idp_id` (`idp_id`),
  CONSTRAINT `idp_remote_ids_ibfk_1` FOREIGN KEY (`idp_id`) REFERENCES `identity_provider` (`id`)
    ON DELETE CASCADE
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idp_remote_ids`
--

LOCK TABLES `idp_remote_ids` WRITE;
/*!40000 ALTER TABLE `idp_remote_ids`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `idp_remote_ids`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `implied_role`
--

DROP TABLE IF EXISTS `implied_role`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `implied_role` (
  `prior_role_id`   VARCHAR(64) NOT NULL,
  `implied_role_id` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`prior_role_id`, `implied_role_id`),
  KEY `implied_role_implied_role_id_fkey` (`implied_role_id`),
  CONSTRAINT `implied_role_implied_role_id_fkey` FOREIGN KEY (`implied_role_id`) REFERENCES `role` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `implied_role_prior_role_id_fkey` FOREIGN KEY (`prior_role_id`) REFERENCES `role` (`id`)
    ON DELETE CASCADE
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `implied_role`
--

LOCK TABLES `implied_role` WRITE;
/*!40000 ALTER TABLE `implied_role`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `implied_role`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `local_user`
--

DROP TABLE IF EXISTS `local_user`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `local_user` (
  `id`        INT(11)      NOT NULL AUTO_INCREMENT,
  `user_id`   VARCHAR(64)  NOT NULL,
  `domain_id` VARCHAR(64)  NOT NULL,
  `name`      VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain_id` (`domain_id`, `name`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `local_user_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
    ON DELETE CASCADE
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `local_user`
--

LOCK TABLES `local_user` WRITE;
/*!40000 ALTER TABLE `local_user`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `local_user`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mapping`
--

DROP TABLE IF EXISTS `mapping`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mapping` (
  `id`    VARCHAR(64) NOT NULL,
  `rules` TEXT        NOT NULL,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mapping`
--

LOCK TABLES `mapping` WRITE;
/*!40000 ALTER TABLE `mapping`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `mapping`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrate_version`
--

DROP TABLE IF EXISTS `migrate_version`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrate_version` (
  `repository_id`   VARCHAR(250) NOT NULL,
  `repository_path` MEDIUMTEXT,
  `version`         INT(11) DEFAULT NULL,
  PRIMARY KEY (`repository_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrate_version`
--

LOCK TABLES `migrate_version` WRITE;
/*!40000 ALTER TABLE `migrate_version`
  DISABLE KEYS */;
INSERT INTO `migrate_version`
VALUES ('keystone', '/usr/local/lib/python2.7/site-packages/keystone/common/sql/migrate_repo', 97);
/*!40000 ALTER TABLE `migrate_version`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password`
--

DROP TABLE IF EXISTS `password`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password` (
  `id`            INT(11)      NOT NULL AUTO_INCREMENT,
  `local_user_id` INT(11)      NOT NULL,
  `password`      VARCHAR(128) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `local_user_id` (`local_user_id`),
  CONSTRAINT `password_ibfk_1` FOREIGN KEY (`local_user_id`) REFERENCES `local_user` (`id`)
    ON DELETE CASCADE
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password`
--

LOCK TABLES `password` WRITE;
/*!40000 ALTER TABLE `password`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `password`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `policy`
--

DROP TABLE IF EXISTS `policy`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy` (
  `id`    VARCHAR(64)  NOT NULL,
  `type`  VARCHAR(255) NOT NULL,
  `blob`  TEXT         NOT NULL,
  `extra` TEXT,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `policy`
--

LOCK TABLES `policy` WRITE;
/*!40000 ALTER TABLE `policy`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `policy`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `policy_association`
--

DROP TABLE IF EXISTS `policy_association`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_association` (
  `id`          VARCHAR(64) NOT NULL,
  `policy_id`   VARCHAR(64) NOT NULL,
  `endpoint_id` VARCHAR(64) DEFAULT NULL,
  `service_id`  VARCHAR(64) DEFAULT NULL,
  `region_id`   VARCHAR(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `endpoint_id` (`endpoint_id`, `service_id`, `region_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `policy_association`
--

LOCK TABLES `policy_association` WRITE;
/*!40000 ALTER TABLE `policy_association`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `policy_association`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project` (
  `id`          VARCHAR(64) NOT NULL,
  `name`        VARCHAR(64) NOT NULL,
  `extra`       TEXT,
  `description` TEXT,
  `enabled`     TINYINT(1)           DEFAULT NULL,
  `domain_id`   VARCHAR(64) NOT NULL,
  `parent_id`   VARCHAR(64)          DEFAULT NULL,
  `is_domain`   TINYINT(1)  NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ixu_project_name_domain_id` (`domain_id`, `name`),
  KEY `project_parent_id_fkey` (`parent_id`),
  CONSTRAINT `project_domain_id_fkey` FOREIGN KEY (`domain_id`) REFERENCES `project` (`id`),
  CONSTRAINT `project_parent_id_fkey` FOREIGN KEY (`parent_id`) REFERENCES `project` (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project`
--

LOCK TABLES `project` WRITE;
/*!40000 ALTER TABLE `project`
  DISABLE KEYS */;
INSERT INTO `project` VALUES
  ('067b4cc5ce1c4a36aef356ff40bc33c0', 'kube-system', '{}', 'Project for Kubernetes Namespace kube-system', 1,
   'default', 'default', 0),
  ('20e01203b97349ecbac8d7d2257b00ab', 'console', '{}', 'description', 1, 'default', 'default', 0),
  ('377bae08c4a74681be99e18fbd9a586f', 'system-tools', '{}', 'description', 1, 'default', 'default', 0),
  ('40e48a4b7f574b249a8697f0b695529e', 'ceph', '{}', 'Project for Kubernetes Namespace ceph', 1, 'default', 'default',
   0),
  ('4ee23d1bb5b64c8b91b2c3409f2fcfdf', 'admin', '{}', 'Bootstrap project for initializing the cloud.', 1, 'default',
   'default', 0), ('8293faa8449449aca60961f77bf4598d', 'default', '{}', 'description', 1, 'default', 'default', 0),
  ('<<keystone.domain.root>>', '<<keystone.domain.root>>', '{}', '', 0, '<<keystone.domain.root>>', NULL, 1),
  ('default', 'Default', '{}', 'The default domain', 1, '<<keystone.domain.root>>', NULL, 1);
/*!40000 ALTER TABLE `project`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_endpoint`
--

DROP TABLE IF EXISTS `project_endpoint`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_endpoint` (
  `endpoint_id` VARCHAR(64) NOT NULL,
  `project_id`  VARCHAR(64) NOT NULL,
  PRIMARY KEY (`endpoint_id`, `project_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_endpoint`
--

LOCK TABLES `project_endpoint` WRITE;
/*!40000 ALTER TABLE `project_endpoint`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `project_endpoint`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_endpoint_group`
--

DROP TABLE IF EXISTS `project_endpoint_group`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_endpoint_group` (
  `endpoint_group_id` VARCHAR(64) NOT NULL,
  `project_id`        VARCHAR(64) NOT NULL,
  PRIMARY KEY (`endpoint_group_id`, `project_id`),
  CONSTRAINT `project_endpoint_group_ibfk_1` FOREIGN KEY (`endpoint_group_id`) REFERENCES `endpoint_group` (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_endpoint_group`
--

LOCK TABLES `project_endpoint_group` WRITE;
/*!40000 ALTER TABLE `project_endpoint_group`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `project_endpoint_group`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `region`
--

DROP TABLE IF EXISTS `region`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `region` (
  `id`               VARCHAR(255) NOT NULL,
  `description`      VARCHAR(255) NOT NULL,
  `parent_region_id` VARCHAR(255) DEFAULT NULL,
  `extra`            TEXT,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `region`
--

LOCK TABLES `region` WRITE;
/*!40000 ALTER TABLE `region`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `region`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `request_token`
--

DROP TABLE IF EXISTS `request_token`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_token` (
  `id`                   VARCHAR(64) NOT NULL,
  `request_secret`       VARCHAR(64) NOT NULL,
  `verifier`             VARCHAR(64) DEFAULT NULL,
  `authorizing_user_id`  VARCHAR(64) DEFAULT NULL,
  `requested_project_id` VARCHAR(64) NOT NULL,
  `role_ids`             TEXT,
  `consumer_id`          VARCHAR(64) NOT NULL,
  `expires_at`           VARCHAR(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_request_token_consumer_id` (`consumer_id`),
  CONSTRAINT `request_token_ibfk_1` FOREIGN KEY (`consumer_id`) REFERENCES `consumer` (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `request_token`
--

LOCK TABLES `request_token` WRITE;
/*!40000 ALTER TABLE `request_token`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `request_token`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `revocation_event`
--

DROP TABLE IF EXISTS `revocation_event`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `revocation_event` (
  `id`              INT(11)  NOT NULL AUTO_INCREMENT,
  `domain_id`       VARCHAR(64)       DEFAULT NULL,
  `project_id`      VARCHAR(64)       DEFAULT NULL,
  `user_id`         VARCHAR(64)       DEFAULT NULL,
  `role_id`         VARCHAR(64)       DEFAULT NULL,
  `trust_id`        VARCHAR(64)       DEFAULT NULL,
  `consumer_id`     VARCHAR(64)       DEFAULT NULL,
  `access_token_id` VARCHAR(64)       DEFAULT NULL,
  `issued_before`   DATETIME NOT NULL,
  `expires_at`      DATETIME          DEFAULT NULL,
  `revoked_at`      DATETIME NOT NULL,
  `audit_id`        VARCHAR(32)       DEFAULT NULL,
  `audit_chain_id`  VARCHAR(32)       DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_revocation_event_new_revoked_at` (`revoked_at`)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 8
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `revocation_event`
--

LOCK TABLES `revocation_event` WRITE;
/*!40000 ALTER TABLE `revocation_event`
  DISABLE KEYS */;
INSERT INTO `revocation_event` VALUES
  (7, NULL, '377bae08c4a74681be99e18fbd9a586f', 'qingyi', 'bad4a67b13974269968a9e439aa429e9', NULL, NULL, NULL,
      '2017-11-02 08:18:58', NULL, '2017-11-02 08:18:58', NULL, NULL);
/*!40000 ALTER TABLE `revocation_event`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `id`        VARCHAR(64)  NOT NULL,
  `name`      VARCHAR(255) NOT NULL,
  `extra`     TEXT,
  `domain_id` VARCHAR(64)  NOT NULL DEFAULT '<<null>>',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ixu_role_name_domain_id` (`name`, `domain_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role`
  DISABLE KEYS */;
INSERT INTO `role` VALUES ('167f775177c64f3e9455938abcaa4d7e', 'dev', '{}', '<<null>>'),
  ('1caa894228ce467f9ddedaa8701862e6', 'admin', '{}', '<<null>>'),
  ('56fde862ae3a48d7a8ec0ee3aa2bfe43', 'sys_admin', '{}', '<<null>>'),
  ('bad4a67b13974269968a9e439aa429e9', 'site_admin', '{}', '<<null>>');
/*!40000 ALTER TABLE `role`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sensitive_config`
--

DROP TABLE IF EXISTS `sensitive_config`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sensitive_config` (
  `domain_id` VARCHAR(64)  NOT NULL,
  `group`     VARCHAR(255) NOT NULL,
  `option`    VARCHAR(255) NOT NULL,
  `value`     TEXT         NOT NULL,
  PRIMARY KEY (`domain_id`, `group`, `option`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sensitive_config`
--

LOCK TABLES `sensitive_config` WRITE;
/*!40000 ALTER TABLE `sensitive_config`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `sensitive_config`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service`
--

DROP TABLE IF EXISTS `service`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service` (
  `id`      VARCHAR(64) NOT NULL,
  `type`    VARCHAR(255)         DEFAULT NULL,
  `enabled` TINYINT(1)  NOT NULL DEFAULT '1',
  `extra`   TEXT,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service`
--

LOCK TABLES `service` WRITE;
/*!40000 ALTER TABLE `service`
  DISABLE KEYS */;
INSERT INTO `service` VALUES ('9490c4206b7b4702afb59f7d9362cd68', 'identity', 1, '{\"name\": \"keystone\"}');
/*!40000 ALTER TABLE `service`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_provider`
--

DROP TABLE IF EXISTS `service_provider`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_provider` (
  `auth_url`           VARCHAR(256) NOT NULL,
  `id`                 VARCHAR(64)  NOT NULL,
  `enabled`            TINYINT(1)   NOT NULL,
  `description`        TEXT,
  `sp_url`             VARCHAR(256) NOT NULL,
  `relay_state_prefix` VARCHAR(256) NOT NULL DEFAULT 'ss:mem:',
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_provider`
--

LOCK TABLES `service_provider` WRITE;
/*!40000 ALTER TABLE `service_provider`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `service_provider`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `token`
--

DROP TABLE IF EXISTS `token`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `token` (
  `id`       VARCHAR(64) NOT NULL,
  `expires`  DATETIME    DEFAULT NULL,
  `extra`    TEXT,
  `valid`    TINYINT(1)  NOT NULL,
  `trust_id` VARCHAR(64) DEFAULT NULL,
  `user_id`  VARCHAR(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_token_expires` (`expires`),
  KEY `ix_token_expires_valid` (`expires`, `valid`),
  KEY `ix_token_user_id` (`user_id`),
  KEY `ix_token_trust_id` (`trust_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `token`
--

LOCK TABLES `token` WRITE;
/*!40000 ALTER TABLE `token`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `token`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trust`
--

DROP TABLE IF EXISTS `trust`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trust` (
  `id`              VARCHAR(64) NOT NULL,
  `trustor_user_id` VARCHAR(64) NOT NULL,
  `trustee_user_id` VARCHAR(64) NOT NULL,
  `project_id`      VARCHAR(64) DEFAULT NULL,
  `impersonation`   TINYINT(1)  NOT NULL,
  `deleted_at`      DATETIME    DEFAULT NULL,
  `expires_at`      DATETIME    DEFAULT NULL,
  `remaining_uses`  INT(11)     DEFAULT NULL,
  `extra`           TEXT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `duplicate_trust_constraint` (`trustor_user_id`, `trustee_user_id`, `project_id`, `impersonation`, `expires_at`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trust`
--

LOCK TABLES `trust` WRITE;
/*!40000 ALTER TABLE `trust`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `trust`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trust_role`
--

DROP TABLE IF EXISTS `trust_role`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trust_role` (
  `trust_id` VARCHAR(64) NOT NULL,
  `role_id`  VARCHAR(64) NOT NULL,
  PRIMARY KEY (`trust_id`, `role_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trust_role`
--

LOCK TABLES `trust_role` WRITE;
/*!40000 ALTER TABLE `trust_role`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `trust_role`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id`                 VARCHAR(64) NOT NULL,
  `extra`              TEXT,
  `enabled`            TINYINT(1)  DEFAULT NULL,
  `default_project_id` VARCHAR(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `user`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_group_membership`
--

DROP TABLE IF EXISTS `user_group_membership`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group_membership` (
  `user_id`  VARCHAR(64) NOT NULL,
  `group_id` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`user_id`, `group_id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `fk_user_group_membership_group_id` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`),
  CONSTRAINT `fk_user_group_membership_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_group_membership`
--

LOCK TABLES `user_group_membership` WRITE;
/*!40000 ALTER TABLE `user_group_membership`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `user_group_membership`
  ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `whitelisted_config`
--

DROP TABLE IF EXISTS `whitelisted_config`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whitelisted_config` (
  `domain_id` VARCHAR(64)  NOT NULL,
  `group`     VARCHAR(255) NOT NULL,
  `option`    VARCHAR(255) NOT NULL,
  `value`     TEXT         NOT NULL,
  PRIMARY KEY (`domain_id`, `group`, `option`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

SET GLOBAL event_scheduler = 1;

DELIMITER $$
CREATE
EVENT IF NOT EXISTS `token_clean`
  ON SCHEDULE EVERY 1 DAY
DO BEGIN
  DELETE FROM token
  WHERE expires < NOW();
END $$

DELIMITER ;

/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `whitelisted_config`
--

LOCK TABLES `whitelisted_config` WRITE;
/*!40000 ALTER TABLE `whitelisted_config`
  DISABLE KEYS */;
/*!40000 ALTER TABLE `whitelisted_config`
  ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE = @OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE = @OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT = @OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS = @OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION = @OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES = @OLD_SQL_NOTES */;

-- Dump completed on 2017-11-10 18:28:43
