
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

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^(Center for Biomedical Informatics and Information Technology)$","NCI $1");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^.*?(National Cancer Institute)?\\s?(Center for (Bioinformatics|Biomedical Informatics and Information Technology)).*?$","NCI Center for Biomedical Informatics and Information Technology");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^.*?(NCI)?(\\s)?CB(IIT)?.*?$","NCI Center for Biomedical Informatics and Information Technology");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^(.*?)-\\s?WUSTL$","Washington University in St.Louis");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^(.*?)-\\s?NCL$","Nanotechnology Characterization Laboratory");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^(.*?)-\\s?GTEM$","GTEM");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^(.*?)-\\s?Stanford$","Stanford University Cancer Center");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^(The Broad Institute).+$","$1");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^Washington University( at St.\\s?Louis)?$","Washington University in St.Louis");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^Fred Hutch Cancer Research Center$","Fred Hutchinson Cancer Research Center");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^\"(.*?)\"$","$1");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^WESTAT$","Westat Inc.");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^The (Holden Comprehensive Cancer Center)$","$1");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","^UVA Medical School","UVA Cancer Center");


