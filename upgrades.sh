baseDir=$(PWD)

# Input stuff

read -p "Please select which Liferay Portal to run (dxp, ce): `echo $'\n> '`" portalVersion

while [[ ${portalVersion} != "dxp" && ${portalVersion} != "ce" ]]; do
	read -p "Invalid input. Please select again (dxp, ce): `echo $'\n> '`" portalVersion
	portalVersion=$(echo ${portalVersion} | tr '[A-Z]' '[a-z]')
done

read -p "Please select a database (mysql, oracle, postgresql, sqlserver, db2, mariadb, sybase): `echo $'\n> '`" database

while [[ ${database} != "mysql" && ${database} != "oracle" && ${database} != "postgresql" && ${database} != "sqlserver" && ${database} != "db2" && ${database} != "mariadb" && ${database} != "sybase" ]]; do
	read -p "Invalid input. Please select again (mysql, oracle, postgresql, sqlserver, db2, mariadb, sybase): `echo $'\n> '`" database
	database=$(echo ${database} | tr '[A-Z]' '[a-z]')
done

read -p "Please select an app server (tomcat, jboss, wildfly): `echo $'\n> '`" appServer

while [[ ${appServer} != "tomcat" && ${appServer} != "jboss" && ${appServer} != "wildfly" ]]; do
	read -p "Please select an app server (tomcat, jboss, wildfly): `echo $'\n> '`" appServer
	appServer=$(echo ${appServer} | tr '[A-Z]' '[a-z]')
done

read -p "Specify database username: `echo $'\n> '`" dbUsername
dbUsername=$(echo $dbUsername | tr '[A-Z]' '[a-z]')

read -p "Specify database password: `echo $'\n> '`" dbPassword
dbPassword=$(echo $dbPassword | tr '[A-Z]' '[a-z]')

read -p "Specify vm ip (or use localhost): `echo $'\n> '`" vmIP
vmIP=$(echo $vmIP | tr '[A-Z]' '[a-z]')

read -p "Specify minor version (ga1, ga2, sp1, etc.): `echo $'\n> '`" minorVersion
minorVersion=$(echo $minorVersion | tr '[A-Z]' '[a-z]')

read -p "Please what version of Liferay Portal you are upgrading from (6.0, 6.1, 6.2; leave blank if none): `echo $'\n> '`" upgradeVersion

# Set portal-upgrade-ext properties

if [[ ${database} == mysql ]]; then
	jdbcDefaultDriver=com.mysql.jdbc.Driver
	jdbcDefaultUrl="jdbc:mysql://${vmIP}/lportal?characterEncoding=UTF-8&dontTrackOpenResources=true&holdResultsOpenOverStatementClose=true&useFastDateParsing=false&useUnicode=true"
	jdbcDefaultUsername=
	jdbcDefaultPassword=
elif [[ ${database} == oracle ]]; then
	jdbcDefaultDriver=oracle.jdbc.driver.OracleDriver
	jdbcDefaultUrl="jdbc:oracle:thin:@${vmIP}:1521:xe"
	jdbcDefaultUsername=lportal
	jdbcDefaultPassword=lportal
elif [[ ${database} == postgresql ]]; then
	jdbcDefaultDriver=org.postgresql.Driver
	jdbcDefaultUrl="jdbc:postgresql://${vmIP}:5432/lportal"
	jdbcDefaultUsername=sa
	jdbcDefaultPassword=
elif [[ ${database} == sqlserver ]]; then
	jdbcDefaultDriver=com.microsoft.sqlserver.jdbc.SQLServerDriver
	jdbcDefaultUrl="jdbc:sqlserver://${vmIP};databaseName=lportal"
	jdbcDefaultUsername=sa
	jdbcDefaultPassword=password
elif [[ ${database} == db2 ]]; then
	jdbcDefaultDriver=com.ibm.db2.jcc.DB2Driver
	jdbcDefaultUrl="jdbc:db2://${vmIP}:50000/lportal:deferPrepares=false;fullyMaterializeInputStreams=true;fullyMaterializeLobData=true;progresssiveLocators=2;progressiveStreaming=2;"
	jdbcDefaultUsername=db2admin
	jdbcDefaultPassword=lportal
elif [[ ${database} == mariadb ]]; then
	jdbcDefaultDriver=org.mariadb.jdbc.Driver
	jdbcDefaultUrl="jdbc:mariadb://${vmIP}/lportal?useUnicode=true&characterEncoding=UTF-8&useFastDateParsing=false"
	jdbcDefaultUsername=
	jdbcDefaultPassword=
elif [[ ${database} == sybase ]]; then
	jdbcDefaultDriver=com.sybase.jdbc4.jdbc.SybDriver
	jdbcDefaultUrl="jdbc:sybase:Tds:${vmIP}:5000/lportal"
	jdbcDefaultUsername=
	jdbcDefaultPassword=
else
	echo "[ERROR] The database ${database} is not a valid database; please provide a valid database."
	exit
fi

# Sets bundle directory and fix pack #

if [[ ${portalVersion} == dxp ]]; then
	liferayBundle=liferay-dxp-digital-enterprise-7.0-${minorVersion}
	liferayHome=${baseDir}/liferay-dxp-digital-enterprise-7.0-${minorVersion}
	zipFile=liferay-dxp-digital-enterprise-${appServer}-7.0-${minorVersion}*.zip

	read -p "Please select which fixpack to install (1-7): `echo $'\n> '`" fixpack

	while [[ ${fixpack} < 1 || ${fixpack} > 7 ]]; do
		read -p "Invalid input. Please select again (1-7): `echo $'\n> '`" fixpack
	done
elif [[ ${portalVersion} == ce ]]; then
	liferayBundle=liferay-ce-portal-7.0-${minorVersion}
	liferayHome=${baseDir}/liferay-ce-portal-7.0-${minorVersion}
	zipFile=liferay-ce-portal-${appServer}-7.0-${minorVersion}*.zip
else
	echo "[ERROR] Please select a valid Liferay version."
	exit
fi

# Deletes existing Liferay bundle

if [[ -e ${liferayHome} ]]; then
	echo "[STATUS] Deleting liferay home..."
	rm -rf ${liferayHome}
	echo "[STATUS] Done."
fi

# Unzip new Liferay bundle

echo -e "\n\n[STATUS] Unzipping a new bundle for Liferay Portal ${releaseVersion}...\n\n"

for file in *.zip; do
	unzip -q -o ${zipFile}
done

echo -e "\n\n[STATUS] Done.\n\n"

# Unzips patching tool and installs fix pack if using a DXP bundle

if [[ ${portalVersion} == dxp ]]; then
	if [[ -e patching-tool-2.0.5 ]]; then
		echo "[STATUS] Deleting patching tool..."
		rm -rf patching-tool-2.0.5
		echo "[STATUS] Done."
	fi
	
	echo -e "\n\n[STATUS] Downloading patching tool 2.0.5...\n\n"
	
	wget -q http://mirrors/files.liferay.com/private/ee/fix-packs/patching-tool/patching-tool-2.0.5.zip

	echo -e "\n\n[STATUS] Unzipping patching tool 2.0.5...\n\n"

	unzip -q -o patching-tool-2.0.5 -d ${liferayHome}

	echo -e "\n\n[STATUS] Done.\n\n"

	echo -e "\n\n[STATUS] Downloading fix pack ${fixpack}...\n\n"
	
	(cd ${liferayHome}/patching-tool/patches && wget -q http://mirrors/files.liferay.com/private/ee/fix-packs/7.0.10/de/liferay-fix-pack-de-${fixpack}-7010-src.zip)

	echo -e "\n\n[STATUS] Installing fix pack ${fixpack}...\n\n"

	(cd ${liferayHome}/patching-tool && ./patching-tool.sh auto-discovery && ./patching-tool.sh install)
	
	echo -e "\n\n[STATUS] Done.\n\n"
fi

# Unzip data folder and .sql file to bundle

echo -e "\n\n[STATUS] Copying the document_library folder to data folder in ${liferayHome}...\n\n"

unzip data.zip

cp -r ./data/document_library ./${liferayBundle}/data

echo -e "\n\n[STATUS] Unzipped data folder.\n\n"

# Writes portal-ext to bundle home

echo -e "\n\n[STATUS] Writing portal-ext.properties...\n\n"

extFile=$baseDir/portal-ext.properties
cp $extFile $liferayHome/
_temp=${liferayHome/\//}
temp=${_temp^}
_liferayHome=${temp:0:1}":"${temp:1:${#temp}}

if [[ ${upgradeVersion} == 6.0 || ${upgradeVersion} == 6.1 ]]; then
	echo -e "liferay.home=${_liferayHome}\njdbc.default.driverClassName=${jdbcDefaultDriver}\njdbc.default.url=${jdbcDefaultUrl}\njdbc.default.username=${jdbcDefaultUsername}\njdbc.default.password=${jdbcDefaultPassword}\npasswords.encryption.algorithm.legacy=SHA" > ${liferayHome}/portal-ext.properties
else
	echo -e "liferay.home=${_liferayHome}\njdbc.default.driverClassName=${jdbcDefaultDriver}\njdbc.default.url=${jdbcDefaultUrl}\njdbc.default.username=${jdbcDefaultUsername}\njdbc.default.password=${jdbcDefaultPassword}" > ${liferayHome}/portal-ext.properties
fi

echo -e "\n\n[STATUS] Done.\n\n"

# Writes portal-upgrade-ext + legacy properties to upgrades folder

echo -e "\n\n[STATUS] Writing portal-upgrade-ext properties...\n\n"

echo -e "liferay.home=${_liferayHome}\njdbc.default.driverClassName=${jdbcDefaultDriver}\njdbc.default.url=${jdbcDefaultUrl}\njdbc.default.username=${jdbcDefaultUsername}\njdbc.default.password=${jdbcDefaultPassword}" > ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties

legacy61="hibernate.cache.use_query_cache=true
	hibernate.cache.use_second_level_cache=true
	locale.prepend.friendly.url.style=1
	passwords.encryption.algorithm.legacy=SHA
	layout.set.prototype.propagate.logo=true
	mobile.device.styling.wap.enabled=true
	dl.char.blacklist=\\\\,//,:,*,?,\",<,>,|,[,],../,/..
	dl.char.last.blacklist=
	dl.name.blacklist=
	journal.articles.search.with.index=false"

legacy62="users.image.check.token=false
	layout.set.prototype.propagate.logo=true
	editor.wysiwyg.portal-web.docroot.html.taglib.ui.discussion.jsp=simple
	web.server.servlet.check.image.gallery=true
	blogs.trackback.enabled=true
	discussion.comments.format=bbcode
	discussion.max.comments=0
	dl.file.entry.thumbnail.max.height=128
	dl.file.entry.thumbnail.max.width=128"

if [[ ${upgradeVersion} == 6.0 ]]; then
	echo -e "users.last.name.required=true
	portal.security.manager.strategy=liferay
	layout.types=portlet,panel,embedded,article,url,link_to_layout
	setup.wizard.enabled=false
	discussion.subscribe.by.default=false
	dl.store.cmis.credentials.username=\${dl.hook.cmis.credentials.username}
	dl.store.cmis.credentials.password=\${dl.hook.cmis.credentials.password}
	dl.store.cmis.repository.url=\${dl.hook.cmis.repository.url}
	dl.store.cmis.system.root.dir=\${dl.hook.cmis.system.root.dir}
	dl.store.file.system.root.dir=\${dl.hook.file.system.root.dir}
	dl.store.jcr.fetch.delay=\${dl.hook.jcr.fetch.delay}
	dl.store.jcr.fetch.max.failures=\${dl.hook.jcr.fetch.max.failures}
	dl.store.jcr.move.version.labels=\${dl.hook.jcr.move.version.labels}
	dl.store.s3.access.key=\${dl.hook.s3.access.key}
	dl.store.s3.secret.key=\${dl.hook.s3.secret.key}
	dl.store.s3.bucket.name=\${dl.hook.s3.bucket.name}
	message.boards.subscribe.by.default=false
	${legacy61}\n${legacy62}" |sed 's/^[ \t]*//' >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
elif [[ ${upgradeVersion} == 6.1 ]]; then
	echo -e "${legacy61}\n${legacy62}" |sed 's/^[ \t]*//' >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
elif [[ ${upgradeVersion} == 6.2 ]]; then
	echo -e "${legacy62}" |sed 's/^[ \t]*//' >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
fi

echo -e "\n\n[STATUS] Done.\n\n"

# Sets directory for dependencies based on app server

echo -e "\n\n[STATUS] Setting dependencies...\n\n"

if [[ ${appServer} == tomcat ]]; then
	libExt=${liferayHome}/tomcat-8.0.32/lib/ext
elif [[ ${appServer} == jboss ]]; then
	libExt=${liferayHome}/jboss-eap-6.4.0/modules/com/liferay/portal/main
elif [[ ${appServer} == wildfly ]]; then
	libExt=${liferayHome}/wildfly-10.0.0/modules/com/liferay/portal/main
fi

if [[ ${database} == mysql ]]; then
	cp ${baseDir}/dependencies/mysql.jar ${libExt}
	jarFile=mysql.jar
elif [[ ${database} == oracle ]]; then
	cp ${baseDir}/dependencies/ojdbc7.jar ${libExt}
	jarFile=ojdbc7.jar
elif [[ ${database} == postgresql ]]; then
	cp ${baseDir}/dependencies/postgresql.jar ${libExt}
	jarFile=postgresql.jar
elif [[ ${database} == sqlserver ]]; then
	cp ${baseDir}/dependencies/sqljdbc4.jar ${libExt}
	jarFile=sqljdbc4.jar
elif [[ ${database} == db2 ]]; then
	cp ${baseDir}/dependencies/db2jcc.jar ${libExt}
	cp ${baseDir}/dependencies/db2jcc_license_cu.jar ${libExt}
	cp ${baseDir}/dependencies/db2jcc4.jar ${libExt}
elif [[ ${database} == mariadb ]]; then
	cp ${baseDir}/dependencies/mariadb.jar ${libExt}
	jarFile=mariadb.jar
fi

# Extra setup for JBoss and Wildfly

if [[ ${appServer} == jboss || ${appServer} == wildfly ]]; then
	if [[ ${database} == db2 ]]; then
		sed -i '/<resources>*/ a\
	<resource-root path="db2jcc.jar" /> \
	<resource-root path="db2jcc_license_cu" /> \
	<resource-root path="db2jcc4" />' ${libExt}/module.xml
	fi
	else
		sed -i '/<resources>*/ a\
	<resource-root path="'${jarFile}'" />' ${libExt}/module.xml
fi

# Creates and imports MySQL database called lportal

if [[ ${database} == mysql ]]; then
	if [[ ${vmIP} == localhost ]]; then
		dbName=`mysql -u -p --skip-column-names -e "SHOW DATABASES LIKE 'lportal'"`

		if [[ ${dbName} == "lportal" ]]; then
			echo -e "\n\n[STATUS] Dropping 'lportal' because it exists...\n\n"
			mysql -u -p -e 'drop database lportal;'
			echo -e "\n\n[STATUS] 'lportal' dropped.\n\n"
		fi

		echo -e "\n\n[STATUS] Creating database 'lportal'...\n\n"
		mysql -u -p -e 'create database lportal character set utf8;'
		echo -e "\n\n[STATUS] 'lportal' created.\n\n"

		echo -e "\n\n[STATUS] Importing lportal.sql to 'lportal'...\n\n"
		mysql --user=${dbUsername} --password=${dbPassword} lportal < ${liferayHome}/lportal.sql
		echo -e "\n\n[STATUS] Import done.\n\n"
	fi
fi

# Delete extraneous files

echo -e "\n\n[STATUS] Deleting temp files...\n\n"

rm -rf data
rm -f lportal.sql

echo -e "\n\n[STATUS] Done.\n\n"

$SHELL