
TRUNCATE TABLE DATA_SERVICE_GROUP;

INSERT INTO DATA_SERVICE_GROUP (NAME,CAB2B_NAME,DATA_PRIMARY_KEY,HOST_PRIMARY_KEY) 
    VALUES ('microarray','Microarray Data','Experiment Public Identifier','Hosting Institution');

INSERT INTO DATA_SERVICE_GROUP (NAME,CAB2B_NAME,DATA_PRIMARY_KEY,HOST_PRIMARY_KEY) 
    VALUES ('biospecimen','Biospecimen Data','Barcode','Hosting Institution');

INSERT INTO DATA_SERVICE_GROUP (NAME,CAB2B_NAME,DATA_PRIMARY_KEY,HOST_PRIMARY_KEY) 
    VALUES ('imaging','Imaging Data','Image Study Instance UID','Hosting Institution');
    
INSERT INTO DATA_SERVICE_GROUP (NAME,CAB2B_NAME,DATA_PRIMARY_KEY,HOST_PRIMARY_KEY) 
    VALUES ('nanoparticle','Nanoparticle data','','Hosting Institution');
