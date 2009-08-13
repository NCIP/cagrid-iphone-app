
INSERT INTO DOMAIN_CLASS 
    (ID,
    CLASS_NAME,
    DESCRIPTION,
    DOMAIN_PACKAGE,
    DOMAIN_MODEL_ID)
SELECT u.id, u.className, u.description, u.packageName, u.model_id
FROM portal2.uml_class u
WHERE uml_class_type = "DataUMLClass";


INSERT INTO DOMAIN_MODEL
    (ID,
    DESCRIPTION,
    LONG_NAME,
    VERSION
    )
SELECT d.id, d.projectDescription, d.projectLongName, d.projectVersion
FROM portal2.domain_models d
WHERE d.projectLongName is not null;


INSERT INTO HOSTING_CENTER
    (ID,
    COUNTRY_CODE,
    LOCALITY,
    LONG_NAME,
    POSTAL_CODE,
    SHORT_NAME,
    STATE_PROVINCE,
    STREET)
SELECT rc.id, a.country, a.locality, rc.displayName, a.postalCode, rc.shortName,
a.stateProvince, concat(a.street1,a.street2) street
FROM portal2.res_ctr rc, portal2.addresses a
WHERE rc.addr_id = a.id
AND rc.displayName != "" AND rc.displayName is not null;


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
SELECT gs.id, gs.service_type, s.description, s.name, s.name, gs.url, s.version, "active", sm.host_res_ctr_id, d.id
FROM portal2.grid_services gs, portal2.svc_meta sm, (portal2.svc s left join portal2.domain_models d on s.id = d.service_id and d.projectLongName is not null)
WHERE gs.id = sm.service_id
AND sm.service_desc_id = s.id;

UPDATE GRID_SERVICE SET HOSTING_CENTER_ID = NULL WHERE NOT EXISTS (SELECT * FROM HOSTING_CENTER WHERE ID=HOSTING_CENTER_ID);
UPDATE GRID_SERVICE SET DISCRIMINATOR = "AnalyticalService" WHERE DISCRIMINATOR = "GridService";
UPDATE GRID_SERVICE SET DISCRIMINATOR = "DataService" WHERE DISCRIMINATOR = "GridDataService";
UPDATE GRID_SERVICE SET DESCRIPTION = NULL WHERE DESCRIPTION = "";


INSERT INTO STATUS_CHANGE
    (ID, CHANGE_DATE, NEW_STATUS, GRID_SERVICE_ID)
SELECT gs.id, "2005-08-05 15:12:26", "ACTIVE", gs.id
FROM portal2.grid_services gs;

INSERT INTO STATUS_CHANGE
    (ID, CHANGE_DATE, NEW_STATUS, GRID_SERVICE_ID)
SELECT 100+gs.id, "2006-08-05 15:12:26", "INACTIVE", gs.id
FROM portal2.grid_services gs;

INSERT INTO STATUS_CHANGE
    (ID, CHANGE_DATE, NEW_STATUS, GRID_SERVICE_ID)
SELECT 200+gs.id, "2009-08-05 15:12:26", "ACTIVE", gs.id
FROM portal2.grid_services gs
WHERE gs.id > 1;


INSERT INTO POINT_OF_CONTACT
    (ID,
    AFFILIATION,
    EMAIL,
    NAME,
    ROLE)
SELECT pocs.id, pocs.affiliation, p.emailAddress, concat(p.firstName, " ", p.lastName), pocs.role
FROM portal2.pocs, portal2.persons p
WHERE pocs.person_id = p.id;


INSERT INTO HOSTING_CENTER_POCS
    (HOSTING_CENTER_ID, POINT_OF_CONTACT_ID)
SELECT center_id, id 
FROM portal2.pocs
WHERE poc_type = "ResearchCenterPointOfContact";
    

INSERT INTO GRID_SERVICE_POCS 
    (GRID_SERVICE_ID, POINT_OF_CONTACT_ID)
SELECT sm.service_id, pocs.id
FROM portal2.pocs pocs, portal2.svc_meta sm
WHERE poc_type = "ServicePointOfContact"
AND pocs.service_desc_id = sm.service_desc_id;

