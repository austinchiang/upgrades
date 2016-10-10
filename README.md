# Using upgrades.sh

The goal of this script is to help make setting up local files for upgrading Liferay 7 less cumbersome. It is a work in progress. Only the Tomcat and JBoss app servers are supported right now.

This script assumes: 
- A zipped liferay 7 DXP or CE bundle is present in the same directory
- The dependencies folder is present in the same directory
- App server versions:
  - Tomcat 8.0.32
  - JBoss 6.4.0
  
Running the script accomplishes the following:
  1. Unzips the bundle in the directory
  2. Writes portal-ext to the bundle
  3. Writes to portal-upgrade-ext in `tools/upgrade`
  4. Adds necessary dependencies to `lib/ext`
