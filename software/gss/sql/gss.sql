
DROP TABLE IF EXISTS `DOMAIN_CLASS`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `DOMAIN_CLASS` (
  `ID` bigint(20) NOT NULL,
  `CLASS_NAME` varchar(255) default NULL,
  `DESCRIPTION` varchar(255) default NULL,
  `DOMAIN_PACKAGE` varchar(255) default NULL,
  `DOMAIN_MODEL_ID` bigint(20) NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `DOMAIN_MODEL`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `DOMAIN_MODEL` (
  `ID` bigint(20) NOT NULL,
  `DESCRIPTION` varchar(255) default NULL,
  `LONG_NAME` varchar(255) default NULL,
  `VERSION` varchar(255) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `GRID_SERVICE`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `GRID_SERVICE` (
  `ID` bigint(20) NOT NULL,
  `DISCRIMINATOR` varchar(255) NOT NULL,
  `DESCRIPTION` varchar(1024) default NULL,
  `NAME` varchar(255) default NULL,
  `PUBLISH_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `TYPE` varchar(255) default NULL,
  `URL` varchar(255) default NULL,
  `VERSION` varchar(255) default NULL,
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
  `COUNTRY_CODE` varchar(255) default NULL,
  `LOCALITY` varchar(255) default NULL,
  `LONG_NAME` varchar(255) default NULL,
  `POSTAL_CODE` varchar(255) default NULL,
  `SHORT_NAME` varchar(255) default NULL,
  `STATE_PROVINCE` varchar(255) default NULL,
  `STREET` varchar(255) default NULL,
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
  `AFFILIATION` varchar(255) default NULL,
  `EMAIL` varchar(255) default NULL,
  `NAME` varchar(255) default NULL,
  `ROLE` varchar(255) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

DROP TABLE IF EXISTS `STATUS_CHANGE`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `STATUS_CHANGE` (
  `ID` bigint(20) NOT NULL,
  `CHANGE_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `NEW_STATUS` varchar(255) default NULL,
  `GRID_SERVICE_ID` bigint(20) NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

