
-- TODO: remove this line once this table has been dropped across all tiers
DROP TABLE IF EXISTS `STATUS_CHANGE`;

DROP TABLE IF EXISTS `LAST_REFRESH`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `LAST_REFRESH` (
  `ID` bigint(20) NOT NULL,
  `COMPLETION_DATE` timestamp NULL default NULL,
  `NUM_SERVICES` bigint(20) NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `DOMAIN_ATTRIBUTE`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `DOMAIN_ATTRIBUTE` (
  `ID` bigint(20) NOT NULL,
  `DOMAIN_CLASS_ID` bigint(20) NOT NULL,
  `ATTRIBUTE_NAME` varchar(256) NOT NULL,
  `DATA_TYPE_NAME` varchar(256) default NULL,
  `CDE_PUBLIC_ID` bigint(20) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `DOMAIN_CLASS`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `DOMAIN_CLASS` (
  `ID` bigint(20) NOT NULL,
  `DOMAIN_MODEL_ID` bigint(20) NOT NULL,
  `CLASS_NAME` varchar(512) NOT NULL,
  `DOMAIN_PACKAGE` varchar(512) NOT NULL,
  `DESCRIPTION` varchar(2000) default NULL,
  `COUNT` bigint(20),
  `COUNT_DATE` timestamp NULL default NULL,
  `COUNT_ERROR` varchar(5000) default NULL,
  `COUNT_STACKTRACE` varchar(50000) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `DOMAIN_MODEL`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `DOMAIN_MODEL` (
  `ID` bigint(20) NOT NULL,
  `DESCRIPTION` varchar(2000) default NULL,
  `LONG_NAME` varchar(512) default NULL,
  `VERSION` varchar(255) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `SEARCH_EXEMPLAR`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `SEARCH_EXEMPLAR` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `SEARCH_STRING` varchar(512) NOT NULL,
  `DATA_SERVICE_GROUP_ID` bigint(20) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `DATA_SERVICE_GROUP`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `DATA_SERVICE_GROUP` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(512) NOT NULL UNIQUE,
  `CAB2B_NAME` varchar(512) NOT NULL,
  `DATA_PRIMARY_KEY` varchar(512),
  `HOST_PRIMARY_KEY` varchar(512),
  `DATA_TITLE` varchar(512),
  `DATA_DESCRIPTION` varchar(512),
  `PRIMARY_CLASS` varchar(512),
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `GRID_SERVICE`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `GRID_SERVICE` (
  `ID` bigint(20) NOT NULL,
  `IDENTIFIER` varchar(255) NOT NULL,
  `DISCRIMINATOR` varchar(255) NOT NULL,
  `DESCRIPTION` varchar(2000) default NULL,
  `NAME` varchar(512) NOT NULL,
  `PUBLISH_DATE` timestamp NULL default NULL,
  `LAST_UPDATE` timestamp NULL default NULL,
  `SIMPLE_NAME` varchar(255) default NULL,
  `DATA_SERVICE_GROUP_ID` bigint(20) default NULL,
  `URL` varchar(767) NOT NULL UNIQUE,
  `VERSION` varchar(255) default NULL,
  `HIDDEN_DEFAULT` tinyint(1) default '0' NOT NULL,
  `SEARCH_DEFAULT` tinyint(1) default '0' NOT NULL,
  `IS_ACCESSIBLE` tinyint(1) default '0' NOT NULL,
  `LAST_STATUS` varchar(255) default NULL,
  `HOSTING_CENTER_ID` bigint(20) NULL,
  `DOMAIN_MODEL_ID` bigint(20) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `GRID_SERVICE_POCS`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `GRID_SERVICE_POCS` (
  `GRID_SERVICE_ID` bigint(20) NOT NULL,
  `POINT_OF_CONTACT_ID` bigint(20) NOT NULL,
  PRIMARY KEY  (`POINT_OF_CONTACT_ID`,`GRID_SERVICE_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `HOSTING_CENTER`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `HOSTING_CENTER` (
  `ID` bigint(20) NOT NULL,
  `IDENTIFIER` varchar(255) NOT NULL,
  `COUNTRY_CODE` varchar(255) default NULL,
  `LOCALITY` varchar(255) default NULL,
  `LONG_NAME` varchar(255) NOT NULL UNIQUE,
  `POSTAL_CODE` varchar(255) default NULL,
  `SHORT_NAME` varchar(255) NOT NULL,
  `STATE_PROVINCE` varchar(255) default NULL,
  `STREET` varchar(255) default NULL,
  `HIDDEN_DEFAULT` tinyint(1) default '0' NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `HOSTING_CENTER_POCS`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `HOSTING_CENTER_POCS` (
  `HOSTING_CENTER_ID` bigint(20) NOT NULL,
  `POINT_OF_CONTACT_ID` bigint(20) NOT NULL,
  PRIMARY KEY  (`HOSTING_CENTER_ID`,`POINT_OF_CONTACT_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `POINT_OF_CONTACT`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `POINT_OF_CONTACT` (
  `ID` bigint(20) NOT NULL,
  `AFFILIATION` varchar(512) default NULL,
  `EMAIL` varchar(512) default NULL,
  `NAME` varchar(512) default NULL,
  `ROLE` varchar(512) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `SIMPLE_NAME`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `SIMPLE_NAME` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `PATTERN` varchar(512) NOT NULL UNIQUE,
  `SIMPLE_NAME` varchar(512) NOT NULL DEFAULT '',
  `TYPE` varchar(512) NOT NULL,
  `HIDE` tinyint(1) default '0' NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;
