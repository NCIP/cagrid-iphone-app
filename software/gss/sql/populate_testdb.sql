/*L
  Copyright SAIC and Capability Plus solutions

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/cagrid-iphone-app/LICENSE.txt for details.
L*/

source gss_schema.sql
source data_service_group.sql
source simple_names.sql
source import_data_from_portal.sql
update grid_service set url = concat(url,"/");
source import_data_from_cab2b.sql

