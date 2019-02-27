
--
-- Table structure for table `license_token`
--

DROP TABLE IF EXISTS `license_token`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `license_token` (
  `id`    bigint(20)  NOT NULL AUTO_INCREMENT,
  `token` varchar(511)       NOT NULL,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `license_token`
--

LOCK TABLES `license_token` WRITE;
/*!40000 ALTER TABLE `license_token`
  DISABLE KEYS */;
INSERT INTO `license_token`
VALUES (1,'{{ result_license_token.stdout }}');
/*!40000 ALTER TABLE `license_token`
  ENABLE KEYS */;
UNLOCK TABLES;