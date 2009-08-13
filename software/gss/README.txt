GSS Build Instructions
----------------------

System Requirements:

caCORE SDK 4.1.1 (http://gforge.nci.nih.gov/frs/download.php/5732/caCORE_SDK_411.zip)
Ant 1.6.5 or greater


Steps to Build:

1) Extract the SDK at the same level as this gss directory, for example:
   ~/dev/gss
   ~/dev/SDK411

2) Run the build:
   ant -Dsdk.home.dir=../SDK411

3) Deploy output/webapp/gss10.war to a webapp container

