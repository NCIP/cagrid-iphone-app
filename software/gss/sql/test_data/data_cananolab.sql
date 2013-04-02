/*L
  Copyright SAIC and Capability Plus solutions

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/cagrid-iphone-app/LICENSE.txt for details.
L*/

INSERT INTO DOMAIN_MODEL
    (
    ID,
    LONG_NAME,
    VERSION,
    DESCRIPTION
    )
    values
    (
    2,
    "caNanoLab",
    "1.4",
    ""
    );
    
INSERT INTO HOSTING_CENTER
    (ID,
    COUNTRY_CODE,
    LOCALITY,
    LONG_NAME,
    POSTAL_CODE,
    SHORT_NAME,
    STATE_PROVINCE
    )
    values 
    (2,
    "US",
    "Frederick",
    "caNanoLab-NCL",
    "21702",
    "caNanoLab-NCL",
    "MD");

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
    (2, 
    "DataService",
    "", 
    "CaNanoLabService", 
    "caNanoLab",
    "http://cananolab.abcc.ncifcrf.gov:80/wsrf-canano/services/cagrid/CaNanoLabService", 
    "1.2",
    "active",
    2,
    2);


