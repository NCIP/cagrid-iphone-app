source gss_schema.sql
source data_service_group.sql
source simple_names.sql
source import_data_from_portal.sql
update grid_service set url = concat(url,"/");
source import_data_from_cab2b.sql

