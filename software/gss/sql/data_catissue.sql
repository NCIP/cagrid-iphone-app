
INSERT INTO DOMAIN_MODEL
    (
    ID,
    LONG_NAME,
    VERSION,
    DESCRIPTION
    )
    values
    (
    3,
    "caTissue_Core_1_2",
    "1.2",
    "caTissue Core version 1.2.2"
    );
    
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
    (3,
    "US",
    "St.Louis",
    "Washington University in St.Louis",
    "63110",
    "Washu",
    "MO",
    "660 S Euclid Avenue");

INSERT INTO GRID_SERVICE 
    (ID, 
    DISCRIMINATOR,
    DESCRIPTION, 
    NAME, 
    TYPE,
    URL,
    VERSION, 
    STATUS,
    HOSTING_CENTER_ID,
    DOMAIN_MODEL_ID)
    values 
    (3, 
    "DataService",
    "", 
    "CaTissueCore", 
    "caTissue",
    "https://128.252.227.214:58443/wsrf/services/cagrid/CaTissueCore", 
    "1.1",
    "active",
    3,
    3);

INSERT INTO POINT_OF_CONTACT
    (ID,
    AFFILIATION,
    EMAIL,
    NAME,
    ROLE)
    values 
    (
    3,
    "washington University",
    "help@mga.wustl.edu",
    "Rekha Meyer",
    "maintainer"
    );
    
INSERT INTO HOSTING_CENTER_POCS
    (HOSTING_CENTER_ID, POINT_OF_CONTACT_ID)
    values (3, 3);
    
INSERT INTO GRID_SERVICE_POCS 
    (GRID_SERVICE_ID, POINT_OF_CONTACT_ID)
    values (3, 3);
    

