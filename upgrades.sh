baseDir=$(PWD)

	# Input stuff

	echo
	echo
	echo "Please select which Liferay Portal to run:"
	echo "	 dxp"
	echo "	 ce "
	echo
	echo

	read portalVersion

	echo
	echo
	echo "Select database: mysql, oracle, postgresql, sqlserver, db2, mariadb, sybase"
	echo
	echo

	read database

	echo
	echo
	echo "Specify vm ip:"
	echo
	echo

	read vmip

	echo
	echo
	echo "Specify minor version (ga1, ga2, etc.):"
	echo
	echo

	read minorVersion

	echo
	echo
	echo "Specify app server (tomcat):"
	echo
	echo

	read appServer

	echo
	echo
	echo "Please what version of Liferay Portal you are upgrading from:"
	echo "  6.0"
	echo "  6.1"
	echo "  6.2"
	echo
	echo

	read upgradeVersion

	# Set portal-upgrade-ext properties
	
	if [[ ${database} == mysql ]]; then
		jdbcDefaultDriver=com.mysql.jdbc.Driver
		jdbcDefaultUrl=jdbc:mysql://${vmip}/lportal?characterEncoding=UTF-8&dontTrackOpenResources=true&holdResultsOpenOverStatementClose=true&useFastDateParsing=false&useUnicode=true
		jdbcDefaultUsername=
		jdbcDefaultPassword=
	elif [[ ${database} == oracle ]]; then
		jdbcDefaultDriver=oracle.jdbc.driver.OracleDriver
		jdbcDefaultUrl=jdbc:oracle:thin:@${vmip}:1521:xe
		jdbcDefaultUsername=lportal
		jdbcDefaultPassword=lportal
	elif [[ ${database} == postgresql ]]; then
		jdbcDefaultDriver=org.postgresql.Driver
		jdbcDefaultUrl=jdbc:postgresql://${vmip}:5432/lportal
		jdbcDefaultUsername=sa
		jdbcDefaultPassword=
	elif [[ ${database} == sqlserver ]]; then
		jdbcDefaultDriver=com.microsoft.sqlserver.jdbc.SQLServerDriver
		jdbcDefaultUrl=jdbc:sqlserver://${vmip}/lportal
		jdbcDefaultUsername=sa
		jdbcDefaultPassword=
	elif [[ ${database} == db2 ]]; then
		jdbcDefaultDriver=com.ibm.db2.jcc.DB2Driver
		jdbcDefaultUrl=jdbc:db2://${vmip}:50000/lportal:deferPrepares=false;fullyMaterializeInputStreams=true;fullyMaterializeLobData=true;progresssiveLocators=2;progressiveStreaming=2;
		jdbcDefaultUsername=db2admin
		jdbcDefaultPassword=lportal
	elif [[ ${database} == mariadb ]]; then
		jdbcDefaultDriver=org.mariadb.jdbc.Driver
		jdbcDefaultUrl=jdbc:mariadb://${vmip}/lportal?useUnicode=true&characterEncoding=UTF-8&useFastDateParsing=false
		jdbcDefaultUsername=
		jdbcDefaultPassword=
	elif [[ ${database} == sybase ]]; then
		jdbcDefaultDriver=com.sybase.jdbc4.jdbc.SybDriver
		jdbcDefaultUrl=jdbc:sybase:Tds:${vmip}:5000/lportal
		jdbcDefaultUsername=
		jdbcDefaultPassword=
	fi

# Set bundle directory and unzip bundle

	if [[ ${portalVersion} == dxp ]]; then	
		liferayHome=${baseDir}/liferay-dxp-digital-enterprise-7.0-${minorVersion}
		zipFile=liferay-dxp-digital-enterprise-${appServer}-7.0-${minorVersion}*.zip
	elif [[ ${portalVersion} == ce ]]; then
		liferayHome=${baseDir}/liferay-ce-portal-7.0-${minorVersion}
		zipFile=liferay-ce-portal-${appServer}-7.0-${minorVersion}*.zip
	else
		echo "[ERROR] Please select a valid Liferay version."
		exit
	fi
	
	if [[ -e ${liferayHome} ]]; then
		echo "[STATUS] Deleting liferay home..."
		rm -rf ${liferayHome}
		echo "[STATUS] Done."
	fi

	echo
	echo
	echo "[STATUS] Unzipping a new bundle for Liferay Portal ${releaseVersion}..."
	echo
	echo

	for file in *.zip
	do
		unzip -q ${zipFile}
	done
	
	echo
	echo
	echo "[STATUS] Done."
	echo
	echo

	# Writes portal-ext to bundle home

	echo
	echo
	echo "[STATUS] Writing portal-ext.properties..."
	echo
	echo

	extFile=$baseDir/portal-ext.properties
	cp $extFile $liferayHome/
	_temp=${liferayHome/\//}
	temp=${_temp^}
	_liferayHome=${temp:0:1}":"${temp:1:${#temp}}
	
	echo -e "liferay.home=${_liferayHome}\njdbc.default.driverClassName=${jdbcDefaultDriver}\njdbc.default.url=${jdbcDefaultUrl}\njdbc.default.username=${jdbcDefaultUsername}\njdbc.default.password=${jdbcDefaultPassword}" > ${liferayHome}/portal-ext.properties

	echo
	echo
	echo "[STATUS] Done."
	echo
	echo

	# Writes portal-upgrade-ext + legacy properties to upgrades folder

	echo
	echo
	echo "[STATUS] Writing portal-upgrade-ext properties..."
	echo
	echo

	echo -e "liferay.home=${_liferayHome}\njdbc.default.driverClassName=${jdbcDefaultDriver}\njdbc.default.url=${jdbcDefaultUrl}\njdbc.default.username=${jdbcDefaultUsername}\njdbc.default.password=${jdbcDefaultPassword}" > ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties

	if [[ ${upgradeVersion} == 6.0 ]]; then
		echo -e "\nusers.last.name.required=true\nportal.security.manager.strategy=liferay\nlayout.types=portlet,panel,embedded,article,url,link_to_layout\nsetup.wizard.enabled=false\ndiscussion.subscribe.by.default=false" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\ndl.store.cmis.credentials.username=\${dl.hook.cmis.credentials.username}\ndl.store.cmis.credentials.password=\${dl.hook.cmis.credentials.password}\ndl.store.cmis.repository.url=\${dl.hook.cmis.repository.url}\ndl.store.cmis.system.root.dir=\${dl.hook.cmis.system.root.dir}" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\ndl.store.file.system.root.dir=\${dl.hook.file.system.root.dir}" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\ndl.store.jcr.fetch.delay=\${dl.hook.jcr.fetch.delay}\ndl.store.jcr.fetch.max.failures=\${dl.hook.jcr.fetch.max.failures}\ndl.store.jcr.move.version.labels=\${dl.hook.jcr.move.version.labels}" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\ndl.store.s3.access.key=\${dl.hook.s3.access.key}\ndl.store.s3.secret.key=\${dl.hook.s3.secret.key}\ndl.store.s3.bucket.name=\${dl.hook.s3.bucket.name}" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\nmessage.boards.subscribe.by.default=false" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\nhibernate.cache.use_query_cache=true\nhibernate.cache.use_second_level_cache=true" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\nlocale.prepend.friendly.url.style=1\npasswords.encryption.algorithm.legacy=SHA\nlayout.set.prototype.propagate.logo=true\nmobile.device.styling.wap.enabled=true" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\ndl.char.blacklist=\\\\,//,:,*,?,\",<,>,|,[,],../,/.." >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\ndl.char.last.blacklist=\ndl.name.blacklist=\njournal.articles.search.with.index=false" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\nusers.image.check.token=false\nlayout.set.prototype.propagate.logo=true\neditor.wysiwyg.portal-web.docroot.html.taglib.ui.discussion.jsp=simple\nweb.server.servlet.check.image.gallery=true\nblogs.trackback.enabled=true\ndiscussion.comments.format=bbcode\ndiscussion.max.comments=0" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\ndl.file.entry.thumbnail.max.height=128\ndl.file.entry.thumbnail.max.width=128" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
	elif [[ ${upgradeVersion} == 6.1 ]]; then
		echo -e "\nhibernate.cache.use_query_cache=true\nhibernate.cache.use_second_level_cache=true" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\nlocale.prepend.friendly.url.style=1\npasswords.encryption.algorithm.legacy=SHA\nlayout.set.prototype.propagate.logo=true\nmobile.device.styling.wap.enabled=true" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\ndl.char.blacklist=\\\\,//,:,*,?,\",<,>,|,[,],../,/.." >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\ndl.char.last.blacklist=\ndl.name.blacklist=\njournal.articles.search.with.index=false" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\nusers.image.check.token=false\nlayout.set.prototype.propagate.logo=true\neditor.wysiwyg.portal-web.docroot.html.taglib.ui.discussion.jsp=simple\nweb.server.servlet.check.image.gallery=true\nblogs.trackback.enabled=true\ndiscussion.comments.format=bbcode\ndiscussion.max.comments=0" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\ndl.file.entry.thumbnail.max.height=128\ndl.file.entry.thumbnail.max.width=128" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
	elif [[ ${upgradeVersion} == 6.2 ]]; then
		echo -e "\nusers.image.check.token=false\nlayout.set.prototype.propagate.logo=true\neditor.wysiwyg.portal-web.docroot.html.taglib.ui.discussion.jsp=simple\nweb.server.servlet.check.image.gallery=true\nblogs.trackback.enabled=true\ndiscussion.comments.format=bbcode\ndiscussion.max.comments=0" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
		echo -e "\ndl.file.entry.thumbnail.max.height=128\ndl.file.entry.thumbnail.max.width=128" >> ${liferayHome}/tools/portal-tools-db-upgrade-client/portal-upgrade-ext.properties
	fi	

	echo
	echo
	echo "[STATUS] Done."
	echo
	echo

	# Sets directory for dependencies based on app server (tomcat only for now)

	echo
	echo
	echo "[STATUS] Setting dependencies..."
	echo
	echo

	if [[ ${appServer} == tomcat ]]; then
		libExt=${liferayHome}/tomcat-8.0.32/lib/ext
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