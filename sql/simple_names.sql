
TRUNCATE TABLE SIMPLE_NAME;

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("ServiceName","Svc_v\\d+_\\d+$","");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("ServiceName","^(caBIO)\\d+$","$1");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("ServiceName","^camod$","caMOD");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("ServiceName","^Washu-CaTissueSuite$","caTissue Suite");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("ServiceName","^EVSGridService\d+$","EVS");

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,HIDE) VALUES ("ServiceName","^AuthenticationService$",1);
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,HIDE) VALUES ("ServiceName","^CredentialDelegationService$",1);
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,HIDE) VALUES ("ServiceName","^GTS$",1);
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,HIDE) VALUES ("ServiceName","^Dorian$",1);

-- Remove trailing whitespace

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"(.*?)\\w+$","$1");

-- Remove quotes

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^\"(.*?)\"$","$1");

-- Add a space after any punctuation

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"(\\w)[\\.,;]$(\\w)","$1. $2");

-- Fred Hutch Cancer Research Center

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^Fred Hutch Cancer Research Center$","Fred Hutchinson Cancer Research Center");

-- caNanoLab-GTEM

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^(.*?)-\\s?GTEM$","GTEM");

-- caNanoLab-NCICBIIT
-- NCI CBIIT
-- NCICBIIT

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^.*?NCI\\s?CBIIT.*?$","NCI Center for Biomedical Informatics and Information Technology");

-- Center for Biomedical Informatics and Information Technology

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^(Center for Biomedical Informatics and Information Technology)$","NCI $1");

-- National Cancer Institute Center for Bioinformatics

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^National Cancer Institute Center for (Bioinformatics|Biomedical Informatics and Information Technology)$","NCI Center for Biomedical Informatics and Information Technology");

-- The Broad Institute of MIT and Harvard

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^(The Broad Institute).+$","Broad Institute");

-- UVA Medical School - Public Health Sciences
-- UVA Cancer Center - Public Health Sciences

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^UVA (\\w+) - Public Health Sciences","University of Virginia Public Health Sciences");

-- University of Manchester, Computer Science, myGrid test services

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^University of Manchester.*?$","University of Manchester");

-- University of Virginia Public Health Sciences Admin

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^University of Virginia Public Health Sciences Admin$","University of Virginia Public Health Sciences");

-- Washington University
-- Washington University at St.Louis

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^Washington University( at St.Louis)?$","Washington University in St. Louis");

-- Center for Biomedical Informatics (actually WUSTL CBMI)

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^Center for Biomedical Informatics$","Washington University in St. Louis");

-- H.Lee. Moffitt Cancer Center
-- INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
-- "^H\.Lee\. Moffitt Cancer Center$","H. Lee. Moffitt Cancer Center");

-- nntc

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^nntc$","National NeuroAIDS Tissue Consortium");

-- bdarc

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^bda(rc)?$","Build and Deployment Automation");


-- Are these still used?

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^WESTAT$","Westat Inc.");

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",
"^The (Holden Comprehensive Cancer Center)$","$1");


