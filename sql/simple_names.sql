
TRUNCATE TABLE SIMPLE_NAME;

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("ServiceName","Svc_v\\d+_\\d+$","");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("ServiceName","(caBIO)\\d+","\\1");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("ServiceName","camod","caMOD");

INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","NCI(\\s)?CB(IIT)?","NCI Center for Biomedical Informatics and Information Technology");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",".*?-\\s?NCICB","NCI Center for Biomedical Informatics and Information Technology");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",".*?-\\s?WUSTL","Washington University in St.Louis");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",".*?-\\s?NCL","Nanotechnology Characterization Laboratory");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",".*?-\\s?GTEM","GTEM");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName",".*?-\\s?Stanford","Stanford University Cancer Center");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","The Broad Institute.+","The Broad Institute");
INSERT INTO SIMPLE_NAME (TYPE,PATTERN,SIMPLE_NAME) VALUES ("HostName","Center for Biomedical Informatics and Information Technology","NCI Center for Biomedical Informatics and Information Technology");
