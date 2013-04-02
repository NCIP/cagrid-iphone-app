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
    1,
    "caCORE",
    "3.1",
    "caCORE 3.1 models"
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
    (1,
    "US",
    "Rockville",
    "NCI Center for Biomedical Informatics and Information Technology",
    "20852",
    "CBIIT",
    "MD",
    "2115 East Jefferson Street - Suite 5000");

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
    (1, 
    "DataService",
    "The CaBIOSvc grid service exposes the caBIO API hosted by NCICB.", 
    "CaBIOSvc", 
    "caBIO",
    "http://cabio-gridservice.nci.nih.gov:80/wsrf-cabio/services/cagrid/CaBIOSvc", 
    "1.0",
    "active",
    1,
    1);

INSERT INTO POINT_OF_CONTACT
    (ID,
    AFFILIATION,
    EMAIL,
    NAME,
    ROLE)
    values 
    (
    1,
    "NCICB Application Support",
    "ncicbmb@mail.nih.gov",
    "",
    "maintainer"
    );

INSERT INTO POINT_OF_CONTACT
    (ID,
    AFFILIATION,
    EMAIL,
    NAME,
    ROLE)
    values 
    (
    2,
    "SemanticBits",
    "joshua.phillips@semanticbits.com",
    "Joshua Phillips",
    "Developer"
    );
    
INSERT INTO HOSTING_CENTER_POCS
    (HOSTING_CENTER_ID, POINT_OF_CONTACT_ID)
    values (1, 1);
    
INSERT INTO GRID_SERVICE_POCS 
    (GRID_SERVICE_ID, POINT_OF_CONTACT_ID)
    values (1, 2);
    

