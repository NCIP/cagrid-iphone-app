
INSERT INTO HOSTING_CENTER
    (ID,
    LONG_NAME,
    SHORT_NAME)
SELECT 5000+URL_ID, HOSTING_CENTER, HOSTING_CENTER_SHORT_NAME
FROM cab2b.cab2b_service_url;

UPDATE HOSTING_CENTER SET SHORT_NAME = substring(SHORT_NAME,11) where SHORT_NAME LIKE "caNanoLab-%"; 

INSERT INTO GRID_SERVICE 
    (ID, 
    DISCRIMINATOR,
    DESCRIPTION, 
    NAME, 
    SIMPLE_NAME,  
    URL,
    VERSION,
    DATA_SERVICE_GROUP_ID,
    HOSTING_CENTER_ID)
SELECT 5000+URL_ID, "DataService", DESCRIPTION, 
    DOMAIN_MODEL, "caArray", URL, VERSION, 1, 5000+URL_ID
FROM cab2b.cab2b_service_url WHERE DOMAIN_MODEL = "caArray";


INSERT INTO GRID_SERVICE 
    (ID, 
    DISCRIMINATOR,
    DESCRIPTION, 
    NAME,
    SIMPLE_NAME,  
    URL,
    VERSION,
    DATA_SERVICE_GROUP_ID,
    HOSTING_CENTER_ID)
SELECT 5000+URL_ID, "DataService", DESCRIPTION, 
    DOMAIN_MODEL, "caTissue", URL, VERSION, 2, 5000+URL_ID
FROM cab2b.cab2b_service_url WHERE DOMAIN_MODEL like "caTissue_%";


INSERT INTO GRID_SERVICE 
    (ID, 
    DISCRIMINATOR,
    DESCRIPTION, 
    NAME, 
    SIMPLE_NAME,  
    URL,
    VERSION,
    DATA_SERVICE_GROUP_ID,
    HOSTING_CENTER_ID)
SELECT 5000+URL_ID, "DataService", DESCRIPTION, 
    DOMAIN_MODEL, "NCIA", URL, VERSION, 3, 5000+URL_ID
FROM cab2b.cab2b_service_url WHERE DOMAIN_MODEL = "NCIA_Model";


INSERT INTO GRID_SERVICE 
    (ID, 
    DISCRIMINATOR,
    DESCRIPTION, 
    NAME, 
    SIMPLE_NAME,  
    URL,
    VERSION,
    DATA_SERVICE_GROUP_ID,
    HOSTING_CENTER_ID)
SELECT 5000+URL_ID, "DataService", DESCRIPTION, 
    DOMAIN_MODEL, "caNanoLab", URL, VERSION, 4, 5000+URL_ID
FROM cab2b.cab2b_service_url WHERE DOMAIN_MODEL = "caNanoLab";


UPDATE GRID_SERVICE SET SEARCH_DEFAULT = 1
WHERE ID IN ( 
    SELECT 5000+URL_ID FROM cab2b.cab2b_user_url_mapping u, cab2b.cab2b_service_url s 
    WHERE u.service_url_id = s.url_id
    AND u.user_id = 1
);
    
INSERT INTO STATUS_CHANGE
    (ID, CHANGE_DATE, NEW_STATUS, GRID_SERVICE_ID)
SELECT 5000+URL_ID, "2005-08-05 15:12:26", "ACTIVE", 5000+URL_ID
FROM cab2b.cab2b_service_url;



UPDATE grid_service g 
LEFT JOIN hosting_center hc on g.hosting_center_id=hc.id 
LEFT JOIN (select min(id) min_id,long_name from hosting_center group by long_name) min 
    on hc.long_name=min.long_name 
SET g.hosting_center_id = min.min_id;

DELETE h FROM hosting_center h 
LEFT JOIN grid_service g ON g.hosting_center_id = h.id 
WHERE g.id IS NULL;



