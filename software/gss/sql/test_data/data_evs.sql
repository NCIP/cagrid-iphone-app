/*L
  Copyright SAIC and Capability Plus solutions

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/cagrid-iphone-app/LICENSE.txt for details.
L*/

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
    (4,
    "US",
    "Rockville",
    "National Cancer Institute Center for Bioinformatics",
    "20852",
    "NCICB",
    "MD",
    "6116 Executive Blvd, Suite 403");

INSERT INTO GRID_SERVICE 
    (ID, 
    DISCRIMINATOR,
    DESCRIPTION, 
    NAME, 
    TYPE,
    URL,
    VERSION,
    STATUS,
    HOSTING_CENTER_ID)
    values 
    (4, 
    "AnalyticalService",
    "The EVS grid service provides access to data semantics and controlled terminology as managed by the NCI Enterprise Vocabulary Service.", 
    "EVSGridService41", 
    "EVS",
    "http://cagrid-service.nci.nih.gov:8080/wsrf/services/cagrid/EVSGridService", 
    "1.2",
    "inactive",
    4
    );

INSERT INTO POINT_OF_CONTACT
    (ID,
    AFFILIATION,
    EMAIL,
    NAME,
    ROLE)
    values 
    (
    4,
    "NCICB Application Support",
    "ncicbmb@mail.nih.gov",
    "",
    "maintainer"
    );
    
INSERT INTO HOSTING_CENTER_POCS
    (HOSTING_CENTER_ID, POINT_OF_CONTACT_ID)
    values (4, 4);


