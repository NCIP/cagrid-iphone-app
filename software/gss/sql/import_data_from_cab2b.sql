
INSERT INTO HOSTING_CENTER
    (ID,
    LONG_NAME,
    SHORT_NAME)
SELECT 5000+URL_ID, HOSTING_CENTER, HOSTING_CENTER_SHORT_NAME
FROM cab2b.cab2b_service_url;


INSERT INTO GRID_SERVICE 
    (ID, 
    DISCRIMINATOR,
    DESCRIPTION, 
    NAME, 
    URL,
    VERSION,
    DATA_SERVICE_GROUP_ID
    HOSTING_CENTER_ID)
SELECT 5000+URL_ID, "DataService", DESCRIPTION, 
    DOMAIN_MODEL, URL, VERSION, 2, 5000+URL_ID
FROM cab2b.cab2b_service_url WHERE DOMAIN_MODEL = "caTissue_Core_1_2";


INSERT INTO GRID_SERVICE 
    (ID, 
    DISCRIMINATOR,
    DESCRIPTION, 
    NAME, 
    URL,
    VERSION,
    DATA_SERVICE_GROUP_ID
    HOSTING_CENTER_ID)
SELECT 5000+URL_ID, "DataService", DESCRIPTION, 
    DOMAIN_MODEL, URL, VERSION, 1, 5000+URL_ID
FROM cab2b.cab2b_service_url WHERE DOMAIN_MODEL = "caArray";


INSERT INTO GRID_SERVICE 
    (ID, 
    DISCRIMINATOR,
    DESCRIPTION, 
    NAME, 
    URL,
    VERSION,
    DATA_SERVICE_GROUP_ID
    HOSTING_CENTER_ID)
SELECT 5000+URL_ID, "DataService", DESCRIPTION, 
    DOMAIN_MODEL, URL, VERSION, 3, 5000+URL_ID
FROM cab2b.cab2b_service_url WHERE DOMAIN_MODEL = "NCIA_Model";



INSERT INTO STATUS_CHANGE
    (ID, CHANGE_DATE, NEW_STATUS, GRID_SERVICE_ID)
SELECT 5000+URL_ID, "2005-08-05 15:12:26", "ACTIVE", 5000+URL_ID
FROM cab2b.cab2b_service_url;


