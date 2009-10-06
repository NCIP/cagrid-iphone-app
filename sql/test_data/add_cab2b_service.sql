
DELETE FROM HOSTING_CENTER WHERE ID = 2000;
INSERT INTO HOSTING_CENTER
    (ID,
    COUNTRY_CODE,
    LOCALITY,
    LONG_NAME,
    POSTAL_CODE,
    SHORT_NAME,
    STATE_PROVINCE,
    STREET)
    values 
    (2000,
    "US",
    "Rockville",
    "NCI Center for Biomedical Informatics and Information Technology",
    "20852",
    "CBIIT",
    "MD",
    "2115 East Jefferson Street - Suite 5000");

DELETE FROM GRID_SERVICE WHERE ID = 2000;
INSERT INTO GRID_SERVICE 
    (ID, 
    DISCRIMINATOR,
    DESCRIPTION, 
    NAME, 
    SIMPLE_NAME,
    DATA_SERVICE_GROUP_ID,
    URL,
    VERSION,
    HOSTING_CENTER_ID)
    values 
    (2000, 
    "DataService",
    "A queryable caArray service",
    "CaArraySvc", 
    "caArray",
    1,
    "http://array.nci.nih.gov:80/wsrf/services/cagrid/CaArraySvc",
    "1.0",
    2000
    );

DELETE FROM STATUS_CHANGE WHERE GRID_SERVICE_ID = 2000;
INSERT INTO STATUS_CHANGE
    (ID, CHANGE_DATE, NEW_STATUS, GRID_SERVICE_ID)
    VALUES (200000, "2006-08-05 15:12:26", "ACTIVE", 2000);

     

UPDATE GRID_SERVICE SET DATA_SERVICE_GROUP_ID = 1 WHERE NAME = "CaArraySvc";


