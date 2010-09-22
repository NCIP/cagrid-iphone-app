
TRUNCATE TABLE DATA_SERVICE_GROUP;

INSERT INTO DATA_SERVICE_GROUP (NAME,CAB2B_NAME,DATA_PRIMARY_KEY,HOST_PRIMARY_KEY,
    DATA_TITLE,DATA_DESCRIPTION,PRIMARY_CLASS) VALUES (
    'microarray','Microarray Data','Experiment Public Identifier','Hosting Institution',
    'Experiment Title','Experiment Description','gov.nih.nci.caarray.domain.project.Experiment'
);

INSERT INTO DATA_SERVICE_GROUP (NAME,CAB2B_NAME,DATA_PRIMARY_KEY,HOST_PRIMARY_KEY,
    DATA_TITLE,DATA_DESCRIPTION,PRIMARY_CLASS) VALUES (
    'imaging','Imaging Data','Image Study Instance UID','Hosting Institution',
    'Image Series Protocol Name','Anatomical Site','gov.nih.nci.ncia.domain.Series'
);
    
-- INSERT INTO DATA_SERVICE_GROUP (NAME,CAB2B_NAME,DATA_PRIMARY_KEY,HOST_PRIMARY_KEY,
--     DATA_TITLE,DATA_DESCRIPTION,PRIMARY_CLASS) VALUES (
--     'biospecimen','Biospecimen Data','Barcode','Hosting Institution',
--     'Clinical Diagnosis','Hosting Institution','edu.wustl.catissuecore.domain.Specimen'
-- );
    
INSERT INTO DATA_SERVICE_GROUP (NAME,CAB2B_NAME,DATA_PRIMARY_KEY,HOST_PRIMARY_KEY,
    DATA_TITLE,DATA_DESCRIPTION,PRIMARY_CLASS) VALUES (
    'nanoparticle','Nanoparticle data','Nanoparticle Sample Name','Hosting Institution',
    'Composing Element Name','Nanoparticle Sample Name','gov.nih.nci.cananolab.domain.particle.Sample'
);


TRUNCATE TABLE SEARCH_EXEMPLAR;

INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (1,'GBM');
INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (1,'Adenocarcinoma');
INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (1,'Methylation');
INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (1,'TCGA');
INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (1,'Copy Number');

INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (2,'Lung');
INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (2,'Breast');
INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (2,'Brain');

-- Note: when adding or removing a datatype, make sure to fix the ids here
-- INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (2,'Malignant');
-- INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (2,'Dentinoma');
-- INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (2,'Metastatic');

INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (3,'Brown');
INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (3,'Dendrimer');
INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (3,'iron oxide');
INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (3,'PASP');
INSERT INTO SEARCH_EXEMPLAR (DATA_SERVICE_GROUP_ID,SEARCH_STRING) VALUES (3,'SPION');


