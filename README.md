# Using upgrades.sh

The goal of this script is to help make setting up local files for upgrading Liferay 7 less cumbersome. It is a work in progress. Only the Tomcat and JBoss, and Wildfly app servers are supported right now.

This script assumes: 
- A zipped liferay 7 DXP or CE bundle is present in the same directory
- The dependencies folder is present in the same directory
- A zip file named `data.zip` containing a `data` folder and `lportal.sql` is present in the same directory
- App server versions:
  - Tomcat 8.0.32
  - JBoss 6.4.0
  - Wildfly 10.0.0
  
Running the script accomplishes the following:
  1. Unzips the bundle in the directory
  2. Unzips upgrades document_library folder and lportal.sql into bundle home
  3. Writes portal-ext to bundle home
  4. Writes properties to portal-upgrade-ext in `tools/upgrade`
  5. Adds necessary dependencies to `lib/ext`
  6. Creates and imports database (currently, only importing lportal.sql into a local MySQL server is supported)

More to come...
- More app server support
- More db import support
- Remote db import support
- Modularity
- Patching tool automation