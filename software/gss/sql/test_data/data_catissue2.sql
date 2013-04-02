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
    5,
    "SingleClassProject",
    "1.1",
    "SingleClassProject"
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
    (5,
    "US",
    "Nashville",
    "Vanderbilt-Ingram Cancer Center",
    "37232",
    "VICC",
    "TN",
    "365 21st Ave S.");

INSERT INTO GRID_SERVICE 
    (ID, 
    DISCRIMINATOR,
    DESCRIPTION, 
    NAME, 
    TYPE,
    URL,
    VERSION, 
    HOSTING_CENTER_ID,
    DOMAIN_MODEL_ID)
    values 
    (5, 
    "DataService",
    "", 
    "CaTissueCore", 
    "caTissue",
    "https://cabig.mc.vanderbilt.edu:8443/wsrf/services/cagrid/CaTissueCore", 
    "1.1",
    5,
    5);

INSERT INTO POINT_OF_CONTACT
    (ID,
    AFFILIATION,
    EMAIL,
    NAME,
    ROLE)
    values 
    (
    5,
    "Vanderbilt-Ingram Cancer Center",
    "Mik.Cantrell@Vanderbilt.edu",
    "Mik Cantrell",
    "Admin"
    );
    
INSERT INTO HOSTING_CENTER_POCS
    (HOSTING_CENTER_ID, POINT_OF_CONTACT_ID)
    values (5, 5);
   
    

